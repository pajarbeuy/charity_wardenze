<?php

namespace Tests\Feature;

use App\Models\AuditLog;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuditLogTest extends TestCase
{
    use RefreshDatabase;

    public function test_audit_logs_record_critical_system_actions(): void
    {
        $admin = $this->createAdminUser();

        // 1. Create User
        $this->actingAs($admin)->postJson('/api/v1/users', [
            'name' => 'Member Baru',
            'email' => 'memberbaru@example.com',
            'password' => 'password123',
            'role' => 'Member',
        ]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'USER_CREATED']);

        // 2. Update Settings
        $this->seedSettings();
        $this->actingAs($admin)->putJson('/api/v1/settings', [
            'monthly_fee' => 12000,
        ]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'SETTINGS_UPDATED']);
    }

    public function test_admin_can_view_audit_log_list_and_detail(): void
    {
        $admin = $this->createAdminUser();

        $log = AuditLog::create([
            'user_id' => $admin->id,
            'action' => 'TEST_LOG',
            'created_at' => now(),
        ]);

        $responseList = $this->actingAs($admin)->getJson('/api/v1/audit-logs');
        $responseList->assertStatus(200)->assertJsonPath('data.total', 1);

        $responseDetail = $this->actingAs($admin)->getJson("/api/v1/audit-logs/{$log->id}");
        $responseDetail->assertStatus(200)->assertJsonPath('data.action', 'TEST_LOG');
    }

    public function test_member_cannot_view_audit_logs(): void
    {
        $member = $this->createMemberUser();

        $response = $this->actingAs($member)
            ->getJson('/api/v1/audit-logs');

        $response->assertStatus(403);
    }
}
