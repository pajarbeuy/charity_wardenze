<?php

namespace Tests\Feature;

use App\Models\Payment;
use App\Models\Withdrawal;
use App\Services\CashService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WithdrawalTest extends TestCase
{
    use RefreshDatabase;

    private function createSufficientCash(float $amount = 100000.0): void
    {
        $member = $this->createMemberUser();
        Payment::create([
            'user_id' => $member->id,
            'amount' => $amount,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'VERIFIED',
            'payment_month' => now()->startOfMonth(),
        ]);
    }

    public function test_exact_cash_boundary_withdrawal(): void
    {
        $admin = $this->createAdminUser();
        $cashService = new CashService();

        // 1. Create exactly 100,000 cash
        $this->createSufficientCash(100000);
        $this->assertEquals(100000, $cashService->getCash());

        // 2. Attempting to withdraw 100,001 (exceeding by 1 rupiah) -> MUST FAIL 422
        $responseExceed = $this->actingAs($admin)
            ->postJson('/api/v1/withdrawals', [
                'amount' => 100001,
                'withdraw_date' => '2026-08-15',
                'description' => 'Mencoba Melebihi Saldo',
            ]);
        $responseExceed->assertStatus(422)
            ->assertJsonPath('message', 'Saldo kas tidak mencukupi');

        // 3. Attempting to withdraw EXACTLY 100,000 -> MUST SUCCEED 201
        $responseExact = $this->actingAs($admin)
            ->postJson('/api/v1/withdrawals', [
                'amount' => 100000,
                'withdraw_date' => '2026-08-15',
                'description' => 'Pencairan Seluruh Saldo',
            ]);
        $responseExact->assertStatus(201);

        // 4. Remaining cash must be exactly 0
        $this->assertEquals(0, $cashService->getCash());
    }

    public function test_member_cannot_create_withdrawal(): void
    {
        $member = $this->createMemberUser();

        $response = $this->actingAs($member)
            ->postJson('/api/v1/withdrawals', [
                'amount' => 50000,
                'withdraw_date' => '2026-08-15',
                'description' => 'Pencairan Ilegal',
            ]);

        $response->assertStatus(403);
    }

    public function test_admin_can_view_withdrawal_list_and_detail(): void
    {
        $admin = $this->createAdminUser();
        $this->createSufficientCash(500000);

        $withdrawal = Withdrawal::create([
            'user_id' => $admin->id,
            'amount' => 140000,
            'withdraw_date' => '2026-08-15',
            'description' => 'Santunan 2 Anak Yatim',
        ]);

        $responseList = $this->actingAs($admin)->getJson('/api/v1/withdrawals');
        $responseList->assertStatus(200);

        $responseDetail = $this->actingAs($admin)->getJson("/api/v1/withdrawals/{$withdrawal->id}");
        $responseDetail->assertStatus(200)->assertJsonPath('data.id', $withdrawal->id);
    }

    public function test_admin_can_update_and_delete_withdrawal(): void
    {
        $admin = $this->createAdminUser();
        $this->createSufficientCash(500000);

        $withdrawal = Withdrawal::create([
            'user_id' => $admin->id,
            'amount' => 140000,
            'withdraw_date' => '2026-08-15',
            'description' => 'Santunan 2 Anak Yatim',
        ]);

        $responseUpdate = $this->actingAs($admin)
            ->putJson("/api/v1/withdrawals/{$withdrawal->id}", [
                'amount' => 210000,
                'withdraw_date' => '2026-08-15',
                'description' => 'Santunan 3 Anak Yatim',
            ]);
        $responseUpdate->assertStatus(200);

        $responseDelete = $this->actingAs($admin)
            ->deleteJson("/api/v1/withdrawals/{$withdrawal->id}");
        $responseDelete->assertStatus(204);

        $this->assertDatabaseMissing('withdrawals', ['id' => $withdrawal->id]);
    }
}
