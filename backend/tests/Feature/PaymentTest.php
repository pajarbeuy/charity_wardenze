<?php

namespace Tests\Feature;

use App\Models\Payment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class PaymentTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seedSettings();
    }

    public function test_payment_financial_boundaries(): void
    {
        $user = $this->createMemberUser();

        // 1. Rp9.999 (Below minimum Rp10.000) -> MUST FAIL 422
        $responseBelow = $this->actingAs($user)
            ->postJson('/api/v1/payments', [
                'amount' => 9999,
                'allocation_type' => 'DONATION',
            ]);
        $responseBelow->assertStatus(422);

        // 2. Exact Rp10.000 -> MUST SUCCEED 201
        $responseExact = $this->actingAs($user)
            ->postJson('/api/v1/payments', [
                'amount' => 10000,
                'allocation_type' => 'DONATION',
            ]);
        $responseExact->assertStatus(201);
        $this->assertDatabaseHas('payment_allocations', [
            'payment_id' => $responseExact->json('data.id'),
            'amount' => 10000,
            'allocation_type' => 'MONTHLY',
        ]);

        // 3. Rp10.001 (Boundary above minimum) -> MUST SUCCEED 201
        $responseAbove = $this->actingAs($user)
            ->postJson('/api/v1/payments', [
                'amount' => 10001,
                'allocation_type' => 'DONATION',
            ]);
        $responseAbove->assertStatus(201);
        $this->assertDatabaseHas('payment_allocations', [
            'payment_id' => $responseAbove->json('data.id'),
            'amount' => 1,
            'allocation_type' => 'DONATION',
        ]);
    }

    public function test_donation_allocation_breakdown(): void
    {
        $user = $this->createMemberUser();

        // Rp25.000 dengan DONATION -> 1x MONTHLY Rp10.000 + 1x DONATION Rp15.000
        $response = $this->actingAs($user)
            ->postJson('/api/v1/payments', [
                'amount' => 25000,
                'allocation_type' => 'DONATION',
            ]);

        $response->assertStatus(201);
        $paymentId = $response->json('data.id');

        $this->assertDatabaseHas('payment_allocations', [
            'payment_id' => $paymentId,
            'amount' => 10000,
            'allocation_type' => 'MONTHLY',
        ]);
        $this->assertDatabaseHas('payment_allocations', [
            'payment_id' => $paymentId,
            'amount' => 15000,
            'allocation_type' => 'DONATION',
        ]);
    }

    public function test_next_month_allocation_breakdown(): void
    {
        $user = $this->createMemberUser();

        // Rp25.000 dengan NEXT_MONTH -> 2x MONTHLY Rp10.000 + 1x DONATION Rp5.000
        $response = $this->actingAs($user)
            ->postJson('/api/v1/payments', [
                'amount' => 25000,
                'allocation_type' => 'NEXT_MONTH',
            ]);

        $response->assertStatus(201);
        $paymentId = $response->json('data.id');

        $this->assertDatabaseCount('payment_allocations', 3);
        $this->assertDatabaseHas('payment_allocations', [
            'payment_id' => $paymentId,
            'amount' => 5000,
            'allocation_type' => 'DONATION',
        ]);
    }

    public function test_user_can_upload_payment_proof_converted_to_webp(): void
    {
        Storage::fake('private');
        $user = $this->createMemberUser();

        $payment = Payment::create([
            'user_id' => $user->id,
            'amount' => 10000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'PENDING',
            'payment_month' => now()->startOfMonth(),
        ]);

        $fakeProof = UploadedFile::fake()->image('bukti_transfer.jpg', 1600, 1200);

        $response = $this->actingAs($user)
            ->postJson("/api/v1/payments/{$payment->id}/proof", [
                'proof' => $fakeProof,
            ]);

        $response->assertStatus(200);

        $payment->refresh();
        $this->assertNotNull($payment->proof_image);
        $this->assertStringEndsWith('.webp', $payment->proof_image);
        Storage::disk('private')->assertExists($payment->proof_image);
    }

    public function test_user_can_cancel_pending_payment(): void
    {
        $user = $this->createMemberUser();

        $payment = Payment::create([
            'user_id' => $user->id,
            'amount' => 10000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'PENDING',
            'payment_month' => now()->startOfMonth(),
        ]);

        $response = $this->actingAs($user)
            ->deleteJson("/api/v1/payments/{$payment->id}");

        $response->assertStatus(204);

        $this->assertDatabaseMissing('payments', ['id' => $payment->id]);
    }
}
