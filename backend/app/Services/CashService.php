<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\Withdrawal;

class CashService
{
    /**
     * Calculate current cash balance.
     * Cash = Total Verified Payments - Total Withdrawals
     */
    public function getCash(): float
    {
        $income = (float) Payment::where('payment_status', 'VERIFIED')->sum('amount');
        $expense = (float) Withdrawal::sum('amount');

        return $income - $expense;
    }

    /**
     * Get total verified income.
     */
    public function getTotalIncome(): float
    {
        return (float) Payment::where('payment_status', 'VERIFIED')->sum('amount');
    }

    /**
     * Get total expenses (withdrawals).
     */
    public function getTotalExpense(): float
    {
        return (float) Withdrawal::sum('amount');
    }
}
