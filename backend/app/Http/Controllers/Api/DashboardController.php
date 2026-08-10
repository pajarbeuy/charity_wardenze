<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\User;
use App\Services\CashService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly CashService $cash,
    ) {}

    /**
     * GET /dashboard/member
     */
    public function member(Request $request): JsonResponse
    {
        $user = $request->user();
        $payments = Payment::where('user_id', $user->id);

        return $this->success([
            'total_donation' => (float) (clone $payments)
                ->where('payment_status', 'VERIFIED')
                ->sum('amount'),
            'payment_count' => (clone $payments)
                ->where('payment_status', 'VERIFIED')
                ->count(),
            'current_month' => (clone $payments)
                ->whereYear('payment_month', now()->year)
                ->whereMonth('payment_month', now()->month)
                ->latest()
                ->value('payment_status') ?? 'UNPAID',
            'recent_transactions' => (clone $payments)
                ->latest()
                ->take(5)
                ->get(),
        ]);
    }

    /**
     * GET /dashboard/admin
     */
    public function admin(): JsonResponse
    {
        return $this->success([
            'cash' => $this->cash->getCash(),
            'income' => $this->cash->getTotalIncome(),
            'expense' => $this->cash->getTotalExpense(),
            'pending_payment' => Payment::where('payment_status', 'PENDING')->count(),
            'member' => User::whereHas('role', fn ($q) => $q->where('name', 'Member'))->count(),
        ]);
    }
}
