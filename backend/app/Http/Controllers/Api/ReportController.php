<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Withdrawal;
use App\Services\CashService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly CashService $cash,
    ) {}

    /**
     * GET /reports/pdf
     */
    public function pdf(Request $request): JsonResponse
    {
        $request->validate([
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        $data = $this->getReportData($request);

        // For now, return JSON data. PDF generation can be added with dompdf package.
        // When dompdf is installed, this will return a PDF download response.
        return $this->success($data, 'Report data generated');
    }

    /**
     * GET /reports/excel
     */
    public function excel(Request $request): JsonResponse
    {
        $request->validate([
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        $data = $this->getReportData($request);

        // For now, return JSON data. Excel export can be added with maatwebsite/excel package.
        return $this->success($data, 'Report data generated');
    }

    /**
     * Build report data with date filters.
     */
    private function getReportData(Request $request): array
    {
        $startDate = $request->start_date;
        $endDate = $request->end_date;

        $incomeQuery = Payment::where('payment_status', 'VERIFIED')
            ->when($startDate, fn ($q, $d) => $q->whereDate('verified_at', '>=', $d))
            ->when($endDate, fn ($q, $d) => $q->whereDate('verified_at', '<=', $d));

        $expenseQuery = Withdrawal::query()
            ->when($startDate, fn ($q, $d) => $q->whereDate('withdraw_date', '>=', $d))
            ->when($endDate, fn ($q, $d) => $q->whereDate('withdraw_date', '<=', $d));

        return [
            'period' => [
                'start_date' => $startDate ?? 'All time',
                'end_date' => $endDate ?? 'All time',
            ],
            'summary' => [
                'total_income' => (float) (clone $incomeQuery)->sum('amount'),
                'total_expense' => (float) (clone $expenseQuery)->sum('amount'),
                'current_cash' => $this->cash->getCash(),
            ],
            'donations' => (clone $incomeQuery)->with('user')->latest()->get()->map(fn ($p) => [
                'date' => $p->verified_at?->format('Y-m-d'),
                'member' => $p->user->name,
                'amount' => (float) $p->amount,
                'type' => $p->allocation_type,
            ]),
            'withdrawals' => (clone $expenseQuery)->with('creator')->latest('withdraw_date')->get()->map(fn ($w) => [
                'date' => $w->withdraw_date->format('Y-m-d'),
                'amount' => (float) $w->amount,
                'description' => $w->description,
            ]),
        ];
    }
}
