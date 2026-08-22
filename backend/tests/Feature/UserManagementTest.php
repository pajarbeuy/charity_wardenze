<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserManagementTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_view_user_list(): void
    {
        $admin = $this->createAdminUser();
        $this->createMemberUser(['name' => 'John Doe']);

        $response = $this->actingAs($admin)
            ->getJson('/api/v1/users');

        $response->assertStatus(200)
            ->assertJsonStructure(['data' => ['data', 'total', 'current_page']]);
    }

    public function test_member_cannot_view_user_list(): void
    {
        $member = $this->createMemberUser();

        $response = $this->actingAs($member)
            ->getJson('/api/v1/users');

        $response->assertStatus(403);
    }

    public function test_admin_can_create_new_member(): void
    {
        $admin = $this->createAdminUser();

        $response = $this->actingAs($admin)
            ->postJson('/api/v1/users', [
                'name' => 'Budi Santoso',
                'email' => 'budi@example.com',
                'password' => 'password123',
                'role' => 'Member',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.email', 'budi@example.com');

        $this->assertDatabaseHas('users', ['email' => 'budi@example.com']);
    }

    public function test_admin_can_reset_member_password(): void
    {
        $admin = $this->createAdminUser();
        $member = $this->createMemberUser();

        $response = $this->actingAs($admin)
            ->putJson("/api/v1/users/{$member->id}", [
                'password' => 'newpassword123',
            ]);

        $response->assertStatus(200);

        // Verify password changed
        $loginRes = $this->postJson('/api/v1/auth/login', [
            'email' => $member->email,
            'password' => 'newpassword123',
        ]);
        $loginRes->assertStatus(200);
    }

    public function test_admin_can_soft_delete_user(): void
    {
        $admin = $this->createAdminUser();
        $member = $this->createMemberUser();

        $response = $this->actingAs($admin)
            ->deleteJson("/api/v1/users/{$member->id}");

        $response->assertStatus(204);

        $this->assertSoftDeleted('users', ['id' => $member->id]);
    }

    public function test_admin_cannot_delete_himself(): void
    {
        $admin = $this->createAdminUser();

        $response = $this->actingAs($admin)
            ->deleteJson("/api/v1/users/{$admin->id}");

        $response->assertStatus(422);
    }
}
