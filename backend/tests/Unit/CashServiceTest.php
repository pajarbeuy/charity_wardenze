<?php

namespace Tests\Unit;

use App\Models\Payment;
use App\Models\Withdrawal;
use App\Services\CashService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CashServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_cash_service_calculates_income_expense_and_balance_correctly(): void
    {
        $user = $this->createMemberUser();
        $admin = $this->createAdminUser();

        // 1. Create VERIFIED payment (Income)
        Payment::create([
            'user_id' => $user->id,
            'amount' => 50000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'VERIFIED',
            'payment_month' => now()->startOfMonth(),
        ]);

        // 2. Create PENDING payment (Should NOT be included in income)
        Payment::create([
            'user_id' => $user->id,
            'amount' => 30000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'PENDING',
            'payment_month' => now()->startOfMonth(),
        ]);

        // 3. Create Withdrawal (Expense)
        Withdrawal::create([
            'user_id' => $admin->id,
            'amount' => 15000,
            'withdraw_date' => now()->toDateString(),
            'description' => 'Santunan Anak Yatim',
        ]);

        $cashService = new CashService();

        // Income = 50,000 (only VERIFIED)
        $this->assertEquals(50000, $cashService->getTotalIncome());

        // Expense = 15,000
        $this->assertEquals(15000, $cashService->getTotalExpense());

        // Cash Balance = 50,000 - 15,000 = 35,000
        $this->assertEquals(35000, $cashService->getCash());
    }
}
