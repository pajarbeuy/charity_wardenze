<?php

namespace Tests\Feature;

use App\Models\Payment;
use App\Models\Withdrawal;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_member_dashboard_empty_state_does_not_fail(): void
    {
        $member = $this->createMemberUser();

        // 0 payments in database
        $response = $this->actingAs($member)
            ->getJson('/api/v1/dashboard/member');

        $response->assertStatus(200)
            ->assertJsonPath('data.total_donation', 0)
            ->assertJsonPath('data.payment_count', 0)
            ->assertJsonPath('data.current_month', 'UNPAID');
    }

    public function test_admin_dashboard_empty_state_does_not_fail(): void
    {
        $admin = $this->createAdminUser();

        // 0 payments, 0 withdrawals, 0 members
        $response = $this->actingAs($admin)
            ->getJson('/api/v1/dashboard/admin');

        $response->assertStatus(200)
            ->assertJsonPath('data.cash', 0)
            ->assertJsonPath('data.income', 0)
            ->assertJsonPath('data.expense', 0)
            ->assertJsonPath('data.pending_payment', 0)
            ->assertJsonPath('data.member', 0);
    }

    public function test_member_dashboard_returns_correct_user_stats(): void
    {
        $member = $this->createMemberUser();

        Payment::create([
            'user_id' => $member->id,
            'amount' => 50000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'VERIFIED',
            'payment_month' => now()->startOfMonth(),
        ]);

        $response = $this->actingAs($member)
            ->getJson('/api/v1/dashboard/member');

        $response->assertStatus(200)
            ->assertJsonPath('data.total_donation', 50000)
            ->assertJsonPath('data.payment_count', 1)
            ->assertJsonPath('data.current_month', 'VERIFIED');
    }

    public function test_admin_dashboard_returns_correct_financial_summary(): void
    {
        $admin = $this->createAdminUser();
        $member = $this->createMemberUser();

        Payment::create([
            'user_id' => $member->id,
            'amount' => 100000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'VERIFIED',
            'payment_month' => now()->startOfMonth(),
        ]);

        Withdrawal::create([
            'user_id' => $admin->id,
            'amount' => 30000,
            'withdraw_date' => now()->toDateString(),
            'description' => 'Operasional',
        ]);

        $response = $this->actingAs($admin)
            ->getJson('/api/v1/dashboard/admin');

        $response->assertStatus(200)
            ->assertJsonPath('data.cash', 70000)
            ->assertJsonPath('data.income', 100000)
            ->assertJsonPath('data.expense', 30000);
    }
}
