<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\User;
use App\Models\Withdrawal;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StatisticsController extends Controller
{
    use ApiResponse;

    /**
     * GET /statistics/income
     * Monthly income (verified payments) grouped by month — tahun berjalan.
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
     * Monthly expense (withdrawals) grouped by month — tahun berjalan.
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
     * Combined chart data: income + expense per bulan untuk tahun berjalan.
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
            'income'  => $income,
            'expense' => $expense,
        ]);
    }

    /**
     * GET /statistics/monthly-status?month=2026-08
     *
     * Daftar seluruh member + status pembayaran pada bulan tertentu.
     * Default: bulan berjalan.
     *
     * Per member:
     *   status     : "VERIFIED" | "PENDING" | "REJECTED" | "UNPAID"
     *   amount     : nominal yang dibayar (0 jika UNPAID)
     *   payment_id : id transaksi (null jika UNPAID)
     *
     * Juga mengembalikan summary (total, verified, pending, unpaid, rejected, total_income).
     */
    public function monthlyStatus(Request $request): JsonResponse
    {
        // Parse bulan dari query string, default bulan ini
        $monthParam = $request->query('month', now()->format('Y-m'));
        try {
            $date = \Carbon\Carbon::createFromFormat('Y-m', $monthParam)->startOfMonth();
        } catch (\Exception) {
            $date = now()->startOfMonth();
        }

        $year  = $date->year;
        $month = $date->month;

        // Semua member aktif (tidak soft-deleted)
        $members = User::whereHas('role', fn ($q) => $q->where('name', 'Member'))
            ->orderBy('name')
            ->get(['id', 'name', 'email']);

        // Pembayaran pada bulan ini, prioritas VERIFIED > PENDING > REJECTED
        $payments = Payment::whereYear('payment_month', $year)
            ->whereMonth('payment_month', $month)
            ->get(['id', 'user_id', 'amount', 'payment_status'])
            ->groupBy('user_id')
            ->map(fn ($group) => $group->sortBy(fn ($p) => match ($p->payment_status) {
                'VERIFIED' => 0,
                'PENDING'  => 1,
                'REJECTED' => 2,
                default    => 3,
            })->first());

        $result = $members->map(fn ($member) => [
            'id'         => $member->id,
            'name'       => $member->name,
            'email'      => $member->email,
            'status'     => $payments->has($member->id) ? $payments[$member->id]->payment_status : 'UNPAID',
            'amount'     => $payments->has($member->id) ? (float) $payments[$member->id]->amount : 0,
            'payment_id' => $payments->has($member->id) ? $payments[$member->id]->id : null,
        ]);

        $summary = [
            'total'        => $result->count(),
            'verified'     => $result->where('status', 'VERIFIED')->count(),
            'pending'      => $result->where('status', 'PENDING')->count(),
            'unpaid'       => $result->where('status', 'UNPAID')->count(),
            'rejected'     => $result->where('status', 'REJECTED')->count(),
            'total_income' => $result->where('status', 'VERIFIED')->sum('amount'),
        ];

        return $this->success([
            'month'   => $monthParam,
            'summary' => $summary,
            'members' => $result->values(),
        ]);
    }
}
