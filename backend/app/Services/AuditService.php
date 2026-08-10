<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\Notification;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;

class AuditService
{
    /**
     * Record an audit log entry.
     */
    public function log(Request $request, string $action, ?Model $model = null, ?array $metadata = null): AuditLog
    {
        return AuditLog::create([
            'user_id' => $request->user()?->id,
            'action' => $action,
            'auditable_type' => $model ? $model->getMorphClass() : null,
            'auditable_id' => $model?->id,
            'metadata' => $metadata,
            'ip_address' => $request->ip(),
            'created_at' => now(),
        ]);
    }

    /**
     * Send an in-app notification to a user.
     */
    public function notify(int $userId, string $title, string $message): Notification
    {
        return Notification::create([
            'user_id' => $userId,
            'title' => $title,
            'message' => $message,
            'is_read' => false,
            'created_at' => now(),
        ]);
    }
}
