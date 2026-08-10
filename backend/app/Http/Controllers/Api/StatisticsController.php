<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Withdrawal;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class StatisticsController extends Controller
{
    use ApiResponse;

    /**
     * GET /statistics/income
     * Monthly income (verified payments) grouped by month
     */
    public function income(): JsonResponse
    {
        $data = Payment::select(
                DB::raw('MONTH(payment_month) as month'),
                DB::raw('SUM(amount) as amount')
            )
            ->where('payment_status', 'VERIFIED')
            ->whereYear('payment_month', now()->year)
            ->groupBy('month')
            ->orderBy('month')
            ->pluck('amount', 'month');

        return $this->success($data);
    }

    /**
     * GET /statistics/expense
     * Monthly expense (withdrawals) grouped by month
     */
    public function expense(): JsonResponse
    {
        $data = Withdrawal::select(
                DB::raw('MONTH(withdraw_date) as month'),
                DB::raw('SUM(amount) as amount')
            )
            ->whereYear('withdraw_date', now()->year)
            ->groupBy('month')
            ->orderBy('month')
            ->pluck('amount', 'month');

        return $this->success($data);
    }

    /**
     * GET /statistics/dashboard
     * Combined chart data for dashboard
     */
    public function dashboard(): JsonResponse
    {
        $income = Payment::select(
                DB::raw('MONTH(payment_month) as month'),
                DB::raw('SUM(amount) as amount')
            )
            ->where('payment_status', 'VERIFIED')
            ->whereYear('payment_month', now()->year)
            ->groupBy('month')
            ->orderBy('month')
            ->pluck('amount', 'month');

        $expense = Withdrawal::select(
                DB::raw('MONTH(withdraw_date) as month'),
                DB::raw('SUM(amount) as amount')
            )
            ->whereYear('withdraw_date', now()->year)
            ->groupBy('month')
            ->orderBy('month')
            ->pluck('amount', 'month');

        return $this->success([
            'income' => $income,
            'expense' => $expense,
        ]);
    }
}
