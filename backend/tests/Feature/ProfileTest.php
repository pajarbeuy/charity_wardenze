<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_view_own_profile(): void
    {
        $user = $this->createMemberUser();

        $response = $this->actingAs($user)
            ->getJson('/api/v1/profile');

        $response->assertStatus(200)
            ->assertJsonPath('data.id', $user->id);
    }

    public function test_user_can_update_profile_name_and_phone(): void
    {
        $user = $this->createMemberUser();

        $response = $this->actingAs($user)
            ->putJson('/api/v1/profile', [
                'name' => 'Nama Baru',
                'phone' => '081234567890',
            ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Nama Baru',
            'phone' => '081234567890',
        ]);
    }

    public function test_user_can_upload_avatar_converted_to_webp(): void
    {
        Storage::fake('public');
        $user = $this->createMemberUser();

        $fakeAvatar = UploadedFile::fake()->image('avatar.jpg', 800, 800);

        $response = $this->actingAs($user)
            ->postJson('/api/v1/profile', [
                'name' => $user->name,
                'avatar' => $fakeAvatar,
                '_method' => 'PUT',
            ]);

        $response->assertStatus(200);

        $user->refresh();
        $this->assertNotNull($user->avatar);
        $this->assertStringEndsWith('.webp', $user->avatar);
        Storage::disk('public')->assertExists($user->avatar);
    }

    public function test_user_can_change_password_with_correct_current_password(): void
    {
        $user = $this->createMemberUser([
            'password' => Hash::make('oldpassword123'),
        ]);

        $response = $this->actingAs($user)
            ->patchJson('/api/v1/profile/password', [
                'current_password' => 'oldpassword123',
                'new_password' => 'newpassword123',
                'new_password_confirmation' => 'newpassword123',
            ]);

        $response->assertStatus(200);
    }

    public function test_user_cannot_change_password_with_wrong_current_password(): void
    {
        $user = $this->createMemberUser([
            'password' => Hash::make('oldpassword123'),
        ]);

        $response = $this->actingAs($user)
            ->patchJson('/api/v1/profile/password', [
                'current_password' => 'wrongpassword',
                'new_password' => 'newpassword123',
                'new_password_confirmation' => 'newpassword123',
            ]);

        $response->assertStatus(422);
    }
}
