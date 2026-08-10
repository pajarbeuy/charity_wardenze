<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\PaymentAllocation;
use App\Models\Setting;
use App\Services\AuditService;
use App\Support\ApiResponse;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class PaymentController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly AuditService $audit,
    ) {}

    /**
     * GET /payments
     */
    public function index(Request $request): JsonResponse
    {
        $query = Payment::with('user')
            ->when(! $request->user()->isAdmin(), fn ($q) => $q->where('user_id', $request->user()->id))
            ->when($request->status, fn ($q, $s) => $q->where('payment_status', strtoupper($s)))
            ->latest();

        return $this->success($query->paginate(15));
    }

    /**
     * POST /payments
     * Implements BR-004: allocation logic for overpayment
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'amount' => 'required|numeric|min:10000',
            'allocation_type' => 'required|in:DONATION,NEXT_MONTH',
        ]);

        $setting = Setting::first();
        $fee = (float) $setting->monthly_fee;

        return DB::transaction(function () use ($request, $data, $fee) {
            $payment = Payment::create([
                'user_id' => $request->user()->id,
                'amount' => $data['amount'],
                'mandatory_fee' => $fee,
                'allocation_type' => $data['allocation_type'],
                'payment_status' => 'PENDING',
                'payment_month' => now()->startOfMonth(),
            ]);

            // Create allocations based on BR-004
            $amount = (float) $data['amount'];

            if ($data['allocation_type'] === 'NEXT_MONTH') {
                // Split into monthly payments
                $months = (int) floor($amount / $fee);
                $remainder = $amount - ($months * $fee);
                $currentMonth = Carbon::now()->startOfMonth();

                for ($i = 0; $i < $months; $i++) {
                    PaymentAllocation::create([
                        'payment_id' => $payment->id,
                        'user_id' => $request->user()->id,
                        'allocation_month' => $currentMonth->copy()->addMonths($i),
                        'amount' => $fee,
                        'allocation_type' => 'MONTHLY',
                        'created_at' => now(),
                    ]);
                }

                if ($remainder > 0) {
                    PaymentAllocation::create([
                        'payment_id' => $payment->id,
                        'user_id' => $request->user()->id,
                        'allocation_month' => $currentMonth->copy()->addMonths($months),
                        'amount' => $remainder,
                        'allocation_type' => 'DONATION',
                        'created_at' => now(),
                    ]);
                }
            } else {
                // DONATION: current month fee + extra as donation
                PaymentAllocation::create([
                    'payment_id' => $payment->id,
                    'user_id' => $request->user()->id,
                    'allocation_month' => now()->startOfMonth(),
                    'amount' => min($amount, $fee),
                    'allocation_type' => 'MONTHLY',
                    'created_at' => now(),
                ]);

                if ($amount > $fee) {
                    PaymentAllocation::create([
                        'payment_id' => $payment->id,
                        'user_id' => $request->user()->id,
                        'allocation_month' => now()->startOfMonth(),
                        'amount' => $amount - $fee,
                        'allocation_type' => 'DONATION',
                        'created_at' => now(),
                    ]);
                }
            }

            $this->audit->log($request, 'PAYMENT_CREATED', $payment);

            return $this->success($payment->load('allocations'), 'Payment Created', 201);
        });
    }

    /**
     * GET /payments/{payment}
     */
    public function show(Request $request, Payment $payment): JsonResponse
    {
        abort_unless(
            $request->user()->isAdmin() || $payment->user_id === $request->user()->id,
            403
        );

        return $this->success($payment->load(['user', 'allocations']));
    }

    /**
     * POST /payments/{payment}/proof
     */
    public function uploadProof(Request $request, Payment $payment): JsonResponse
    {
        abort_unless(
            $payment->user_id === $request->user()->id && $payment->payment_status === 'PENDING',
            403
        );

        $request->validate([
            'proof' => 'required|image|mimes:jpg,jpeg,png|max:5120',
        ]);

        $payment->update([
            'proof_image' => $request->file('proof')->store('payment-proofs', 'private'),
        ]);

        return $this->success($payment, 'Proof uploaded');
    }

    /**
     * GET /payments/{payment}/proof
     * Serve proof image securely (auth required, owner or admin only)
     */
    public function serveProof(Request $request, Payment $payment): Response
    {
        abort_unless(
            $request->user()->isAdmin() || $payment->user_id === $request->user()->id,
            403
        );

        abort_if($payment->proof_image === null, 404);
        abort_unless(Storage::disk('private')->exists($payment->proof_image), 404);

        $mimeType = 'image/png'; // default safe fallback
        try {
            $mimeType = Storage::disk('private')->mimeType($payment->proof_image) ?: 'image/png';
        } catch (\Exception) {}

        return response(
            Storage::disk('private')->get($payment->proof_image),
            200,
            [
                'Content-Type'                => $mimeType,
                'Access-Control-Allow-Origin' => '*',
                'Cache-Control'               => 'private, no-store',
            ]
        );
    }

    /**
     * DELETE /payments/{payment}
     */
    public function cancel(Request $request, Payment $payment): JsonResponse
    {
        abort_unless(
            $payment->user_id === $request->user()->id && $payment->payment_status === 'PENDING',
            403
        );

        $payment->allocations()->delete();
        $payment->delete();

        $this->audit->log($request, 'PAYMENT_CANCELLED', $payment);

        return response()->json(null, 204);
    }
}
