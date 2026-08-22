<?php

namespace Tests\Feature;

use App\Models\Payment;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class SecurityAndAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seedSettings();
    }

    public function test_idor_user_a_cannot_access_user_b_payment(): void
    {
        $userA = $this->createMemberUser(['email' => 'usera@example.com']);
        $userB = $this->createMemberUser(['email' => 'userb@example.com']);

        $paymentB = Payment::create([
            'user_id' => $userB->id,
            'amount' => 10000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'PENDING',
            'payment_month' => now()->startOfMonth(),
        ]);

        // User A attempts to view User B's payment
        $responseShow = $this->actingAs($userA)->getJson("/api/v1/payments/{$paymentB->id}");
        $responseShow->assertStatus(403);

        // User A attempts to cancel User B's payment
        $responseCancel = $this->actingAs($userA)->deleteJson("/api/v1/payments/{$paymentB->id}");
        $responseCancel->assertStatus(403);

        // User A attempts to upload proof to User B's payment
        Storage::fake('private');
        $fakeProof = UploadedFile::fake()->image('proof.png', 500, 500);
        $responseUpload = $this->actingAs($userA)->postJson("/api/v1/payments/{$paymentB->id}/proof", [
            'proof' => $fakeProof,
        ]);
        $responseUpload->assertStatus(403);
    }

    public function test_parameter_tampering_payment_creation_ignores_injected_user_id_and_status(): void
    {
        $userA = $this->createMemberUser(['email' => 'usera@example.com']);
        $userB = $this->createMemberUser(['email' => 'userb@example.com']);

        // User A attempts to create a payment on behalf of User B with status VERIFIED
        $response = $this->actingAs($userA)->postJson('/api/v1/payments', [
            'amount' => 50000,
            'allocation_type' => 'DONATION',
            'user_id' => $userB->id,            // Injected user_id
            'payment_status' => 'VERIFIED',    // Injected status
        ]);

        $response->assertStatus(201);

        $paymentId = $response->json('data.id');
        $payment = Payment::find($paymentId);

        // MUST be assigned to User A (authenticated user), NOT User B
        $this->assertEquals($userA->id, $payment->user_id);

        // MUST be PENDING, NOT VERIFIED
        $this->assertEquals('PENDING', $payment->payment_status);
    }

    public function test_mass_assignment_protection_member_cannot_promote_self_to_admin(): void
    {
        $member = $this->createMemberUser();
        [, $adminRole] = $this->seedRoles();

        $response = $this->actingAs($member)->putJson('/api/v1/profile', [
            'name' => 'Hacker',
            'role_id' => $adminRole->id,
            'role' => 'Admin',
        ]);

        $response->assertStatus(200);

        $member->refresh();
        $this->assertFalse($member->isAdmin());
    }

    public function test_non_admin_cannot_access_admin_dashboard_or_settings(): void
    {
        $member = $this->createMemberUser();

        $this->actingAs($member)->getJson('/api/v1/dashboard/admin')->assertStatus(403);
        $this->actingAs($member)->getJson('/api/v1/settings')->assertStatus(403);
        $this->actingAs($member)->putJson('/api/v1/settings', ['monthly_fee' => 0])->assertStatus(403);
    }
}
