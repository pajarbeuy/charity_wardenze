<?php

namespace Tests\Unit;

use App\Models\AuditLog;
use App\Models\Notification;
use App\Services\AuditService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Request;
use Tests\TestCase;

class AuditServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_audit_service_logs_action_and_creates_notification(): void
    {
        $user = $this->createMemberUser();

        $request = Request::create('/api/v1/payments', 'POST');
        $request->setUserResolver(fn () => $user);

        $auditService = new AuditService();

        // 1. Test log creation
        $log = $auditService->log($request, 'TEST_ACTION', $user, ['foo' => 'bar']);

        $this->assertInstanceOf(AuditLog::class, $log);
        $this->assertEquals($user->id, $log->user_id);
        $this->assertEquals('TEST_ACTION', $log->action);
        $this->assertEquals($user->getMorphClass(), $log->auditable_type);
        $this->assertEquals($user->id, $log->auditable_id);
        $this->assertEquals(['foo' => 'bar'], $log->metadata);

        // 2. Test notify creation
        $notification = $auditService->notify($user->id, 'Judul Test', 'Pesan Test');

        $this->assertInstanceOf(Notification::class, $notification);
        $this->assertEquals($user->id, $notification->user_id);
        $this->assertEquals('Judul Test', $notification->title);
        $this->assertEquals('Pesan Test', $notification->message);
        $this->assertFalse($notification->is_read);
    }
}
