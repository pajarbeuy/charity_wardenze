<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_login_with_valid_credentials(): void
    {
        $user = $this->createMemberUser([
            'email' => 'member@example.com',
            'password' => Hash::make('password123'),
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'member@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'token',
                    'user' => ['id', 'name', 'email', 'role'],
                ],
            ]);
    }

    public function test_user_cannot_login_with_invalid_password(): void
    {
        $this->createMemberUser([
            'email' => 'member@example.com',
            'password' => Hash::make('password123'),
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'member@example.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401)
            ->assertJson(['success' => false]);
    }

    public function test_user_cannot_login_with_non_existent_email(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'nonexistent@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(401);
    }

    public function test_login_validation_fails_with_empty_or_invalid_fields(): void
    {
        // Empty fields
        $response1 = $this->postJson('/api/v1/auth/login', [
            'email' => '',
            'password' => '',
        ]);
        $response1->assertStatus(422);

        // Invalid email format
        $response2 = $this->postJson('/api/v1/auth/login', [
            'email' => 'invalid-email-format',
            'password' => 'password123',
        ]);
        $response2->assertStatus(422);
    }

    public function test_authenticated_user_can_get_profile_me(): void
    {
        $user = $this->createMemberUser();

        $response = $this->actingAs($user)
            ->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
            ->assertJsonPath('data.id', $user->id)
            ->assertJsonPath('data.email', $user->email);
    }

    public function test_unauthenticated_user_cannot_access_protected_endpoint(): void
    {
        // No token
        $response = $this->getJson('/api/v1/auth/me');
        $response->assertStatus(401);

        // Invalid token
        $responseInvalid = $this->withHeader('Authorization', 'Bearer invalid_token_xyz')
            ->getJson('/api/v1/auth/me');
        $responseInvalid->assertStatus(401);
    }

    public function test_token_is_revoked_after_logout_and_cannot_be_reused(): void
    {
        $user = $this->createMemberUser();
        $token = $user->createToken('test_token')->plainTextToken;

        // 1. Verify token works before logout
        $responseBefore = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/v1/auth/me');
        $responseBefore->assertStatus(200);

        // 2. Perform logout
        $responseLogout = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/v1/auth/logout');
        $responseLogout->assertStatus(200);

        // Assert token deleted from database
        $this->assertCount(0, $user->fresh()->tokens);

        // Forget cached auth guard in test environment so next request re-authenticates from DB
        $this->app->make('auth')->forgetGuards();

        // 3. Verify token NO LONGER works after logout (Must return 401)
        $responseAfter = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/v1/auth/me');
        $responseAfter->assertStatus(401);
    }
}
