<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Services\AuditService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentVerificationController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly AuditService $audit,
    ) {}

    /**
     * GET /admin/payments/pending
     */
    public function pending(): JsonResponse
    {
        return $this->success(
            Payment::with('user')
                ->where('payment_status', 'PENDING')
                ->latest()
                ->paginate(15)
        );
    }

    /**
     * PATCH /admin/payments/{payment}/verify
     */
    public function verify(Request $request, Payment $payment): JsonResponse
    {
        abort_unless($payment->payment_status === 'PENDING', 422);

        $request->validate([
            'note' => 'nullable|string|max:1000',
        ]);

        $payment->update([
            'payment_status' => 'VERIFIED',
            'verified_by' => $request->user()->id,
            'verified_at' => now(),
        ]);

        $this->audit->log($request, 'PAYMENT_VERIFIED', $payment);

        // Notify the member
        $this->audit->notify(
            $payment->user_id,
            'Pembayaran Diverifikasi',
            "Pembayaran sebesar Rp" . number_format($payment->amount, 0, ',', '.') . " telah diverifikasi."
        );

        return $this->success($payment->fresh(), 'Payment Verified');
    }

    /**
     * PATCH /admin/payments/{payment}/reject
     */
    public function reject(Request $request, Payment $payment): JsonResponse
    {
        abort_unless($payment->payment_status === 'PENDING', 422);

        $data = $request->validate([
            'reason' => 'required|string|max:1000',
        ]);

        $payment->update([
            'payment_status' => 'REJECTED',
            'verified_by' => $request->user()->id,
            'verified_at' => now(),
            'rejection_reason' => $data['reason'],
        ]);

        $this->audit->log($request, 'PAYMENT_REJECTED', $payment);

        // Notify the member
        $this->audit->notify(
            $payment->user_id,
            'Pembayaran Ditolak',
            "Pembayaran sebesar Rp" . number_format($payment->amount, 0, ',', '.') . " ditolak. Alasan: {$data['reason']}"
        );

        return $this->success($payment->fresh(), 'Payment Rejected');
    }
}
