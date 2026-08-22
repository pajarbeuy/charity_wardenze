<?php

namespace Tests\Feature;

use App\Models\Payment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CharityTargetTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seedSettings();
    }

    public function test_charity_target_calculates_correct_orphan_count(): void
    {
        $user = $this->createMemberUser();

        // 420.000 / 70.000 = 6 anak (BR-011 Example)
        Payment::create([
            'user_id' => $user->id,
            'amount' => 420000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'VERIFIED',
            'payment_month' => now()->startOfMonth(),
        ]);

        $response = $this->actingAs($user)
            ->getJson('/api/v1/charity-target');

        $response->assertStatus(200)
            ->assertJsonPath('data.cash', 420000)
            ->assertJsonPath('data.target_per_child', 70000)
            ->assertJsonPath('data.children', 6);
    }

    public function test_admin_can_update_target_per_child(): void
    {
        $admin = $this->createAdminUser();

        $response = $this->actingAs($admin)
            ->putJson('/api/v1/charity-target', [
                'target_per_child' => 100000,
            ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('settings', [
            'target_per_child' => 100000,
        ]);
    }
}
