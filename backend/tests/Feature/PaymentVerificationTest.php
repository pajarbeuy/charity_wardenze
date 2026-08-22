<?php

namespace Tests\Feature;

use App\Models\Payment;
use App\Services\CashService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PaymentVerificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_view_pending_payments(): void
    {
        $admin = $this->createAdminUser();
        $user = $this->createMemberUser();

        Payment::create([
            'user_id' => $user->id,
            'amount' => 10000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'PENDING',
            'payment_month' => now()->startOfMonth(),
        ]);

        $response = $this->actingAs($admin)
            ->getJson('/api/v1/admin/payments/pending');

        $response->assertStatus(200)
            ->assertJsonPath('data.total', 1);
    }

    public function test_admin_can_verify_pending_payment_and_increments_cash(): void
    {
        $admin = $this->createAdminUser();
        $user = $this->createMemberUser();
        $cashService = new CashService();

        $this->assertEquals(0, $cashService->getCash());

        $payment = Payment::create([
            'user_id' => $user->id,
            'amount' => 50000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'PENDING',
            'payment_month' => now()->startOfMonth(),
        ]);

        $response = $this->actingAs($admin)
            ->patchJson("/api/v1/admin/payments/{$payment->id}/verify", [
                'note' => 'Transfer sesuai',
            ]);

        $response->assertStatus(200);

        $payment->refresh();
        $this->assertEquals('VERIFIED', $payment->payment_status);
        $this->assertEquals($admin->id, $payment->verified_by);
        $this->assertNotNull($payment->verified_at);

        // Cash incremented to 50,000
        $this->assertEquals(50000, $cashService->getCash());
    }

    public function test_state_machine_prevents_verifying_already_verified_or_rejected_payment(): void
    {
        $admin = $this->createAdminUser();
        $user = $this->createMemberUser();
        $cashService = new CashService();

        $payment = Payment::create([
            'user_id' => $user->id,
            'amount' => 50000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'VERIFIED', // Already verified
            'payment_month' => now()->startOfMonth(),
        ]);

        // Attempting to verify again MUST fail with 422
        $responseReverify = $this->actingAs($admin)
            ->patchJson("/api/v1/admin/payments/{$payment->id}/verify");
        $responseReverify->assertStatus(422);

        // Verify cash is NOT double counted (remains 50,000, not 100,000)
        $this->assertEquals(50000, $cashService->getCash());

        // Attempting to reject an already VERIFIED payment MUST fail with 422
        $responseReject = $this->actingAs($admin)
            ->patchJson("/api/v1/admin/payments/{$payment->id}/reject", [
                'reason' => 'Rejecting verified payment',
            ]);
        $responseReject->assertStatus(422);
    }

    public function test_admin_can_reject_pending_payment(): void
    {
        $admin = $this->createAdminUser();
        $user = $this->createMemberUser();
        $cashService = new CashService();

        $payment = Payment::create([
            'user_id' => $user->id,
            'amount' => 50000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'PENDING',
            'payment_month' => now()->startOfMonth(),
        ]);

        $response = $this->actingAs($admin)
            ->patchJson("/api/v1/admin/payments/{$payment->id}/reject", [
                'reason' => 'Nominal transfer tidak sesuai',
            ]);

        $response->assertStatus(200);

        $payment->refresh();
        $this->assertEquals('REJECTED', $payment->payment_status);
        $this->assertEquals('Nominal transfer tidak sesuai', $payment->rejection_reason);

        // Cash remains 0 for rejected payment
        $this->assertEquals(0, $cashService->getCash());
    }

    public function test_member_cannot_verify_or_reject_payment(): void
    {
        $member = $this->createMemberUser();

        $payment = Payment::create([
            'user_id' => $member->id,
            'amount' => 10000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'PENDING',
            'payment_month' => now()->startOfMonth(),
        ]);

        $response = $this->actingAs($member)
            ->patchJson("/api/v1/admin/payments/{$payment->id}/verify");

        $response->assertStatus(403);
    }
}
