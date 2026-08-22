<?php

namespace Tests\Feature;

use App\Models\Payment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StatisticsTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_get_income_and_expense_statistics(): void
    {
        $admin = $this->createAdminUser();

        $responseIncome = $this->actingAs($admin)->getJson('/api/v1/statistics/income');
        $responseIncome->assertStatus(200);

        $responseExpense = $this->actingAs($admin)->getJson('/api/v1/statistics/expense');
        $responseExpense->assertStatus(200);

        $responseDashboard = $this->actingAs($admin)->getJson('/api/v1/statistics/dashboard');
        $responseDashboard->assertStatus(200)->assertJsonStructure(['data' => ['income', 'expense']]);
    }

    public function test_monthly_status_member_classification_invariant(): void
    {
        $admin = $this->createAdminUser();

        $member1 = $this->createMemberUser(['name' => 'Member Verified']);
        $member2 = $this->createMemberUser(['name' => 'Member Pending']);
        $member3 = $this->createMemberUser(['name' => 'Member Rejected']);
        $member4 = $this->createMemberUser(['name' => 'Member Unpaid']);

        // 1. Verified
        Payment::create([
            'user_id' => $member1->id,
            'amount' => 10000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'VERIFIED',
            'payment_month' => now()->startOfMonth(),
        ]);

        // 2. Pending
        Payment::create([
            'user_id' => $member2->id,
            'amount' => 10000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'PENDING',
            'payment_month' => now()->startOfMonth(),
        ]);

        // 3. Rejected
        Payment::create([
            'user_id' => $member3->id,
            'amount' => 10000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'REJECTED',
            'payment_month' => now()->startOfMonth(),
        ]);

        // 4. Member4 has no payment (UNPAID)

        $response = $this->actingAs($admin)
            ->getJson('/api/v1/statistics/monthly-status?month=' . now()->format('Y-m'));

        $response->assertStatus(200);

        $summary = $response->json('data.summary');

        $this->assertEquals(1, $summary['verified']);
        $this->assertEquals(1, $summary['pending']);
        $this->assertEquals(1, $summary['rejected']);
        $this->assertEquals(1, $summary['unpaid']);
        $this->assertEquals(4, $summary['total']);

        // Invariant Assertion: verified + pending + rejected + unpaid MUST equal total eligible members
        $sum = $summary['verified'] + $summary['pending'] + $summary['rejected'] + $summary['unpaid'];
        $this->assertEquals($summary['total'], $sum);
    }
}
