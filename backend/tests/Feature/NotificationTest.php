<?php

namespace Tests\Feature;

use App\Models\Notification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_get_notifications_and_mark_as_read(): void
    {
        $user = $this->createMemberUser();

        $notification = Notification::create([
            'user_id' => $user->id,
            'title' => 'Pembayaran Diverifikasi',
            'message' => 'Donasi Anda telah diverifikasi.',
            'is_read' => false,
            'created_at' => now(),
        ]);

        $responseGet = $this->actingAs($user)
            ->getJson('/api/v1/notifications');

        $responseGet->assertStatus(200)
            ->assertJsonPath('data.total', 1);

        $responseRead = $this->actingAs($user)
            ->patchJson("/api/v1/notifications/{$notification->id}/read");

        $responseRead->assertStatus(200);

        $notification->refresh();
        $this->assertTrue((bool) $notification->is_read);
    }

    public function test_user_a_cannot_mark_user_b_notification_as_read(): void
    {
        $userA = $this->createMemberUser(['email' => 'usera@example.com']);
        $userB = $this->createMemberUser(['email' => 'userb@example.com']);

        $notifB = Notification::create([
            'user_id' => $userB->id,
            'title' => 'Notifikasi User B',
            'message' => 'Pesan rahasia User B',
            'is_read' => false,
            'created_at' => now(),
        ]);

        // User A attempts to mark User B's notification as read -> MUST FAIL 403
        $response = $this->actingAs($userA)
            ->patchJson("/api/v1/notifications/{$notifB->id}/read");

        $response->assertStatus(403);

        $notifB->refresh();
        $this->assertFalse((bool) $notifB->is_read);
    }
}
