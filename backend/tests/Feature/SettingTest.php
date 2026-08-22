<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class SettingTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seedSettings();
    }

    public function test_admin_can_view_settings(): void
    {
        $admin = $this->createAdminUser();

        $response = $this->actingAs($admin)
            ->getJson('/api/v1/settings');

        $response->assertStatus(200)
            ->assertJsonPath('data.monthly_fee', "10000.00");
    }

    public function test_admin_can_update_settings_and_upload_qris_webp(): void
    {
        Storage::fake('public');
        $admin = $this->createAdminUser();

        $fakeQris = UploadedFile::fake()->image('qris.png', 1000, 1000);

        $response = $this->actingAs($admin)
            ->putJson('/api/v1/settings', [
                'monthly_fee' => 15000,
                'target_per_child' => 80000,
                'organization_name' => 'Komunitas Wardenze',
                'qris_image' => $fakeQris,
            ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('settings', [
            'monthly_fee' => 15000,
            'target_per_child' => 80000,
            'organization_name' => 'Komunitas Wardenze',
        ]);
    }
}
