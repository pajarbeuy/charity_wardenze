<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuditLogController extends Controller
{
    use ApiResponse;

    /**
     * GET /audit-logs
     */
    public function index(Request $request): JsonResponse
    {
        $query = AuditLog::with('user')
            ->when($request->user_id, fn ($q, $id) => $q->where('user_id', $id))
            ->when($request->action, fn ($q, $a) => $q->where('action', $a))
            ->when($request->start_date, fn ($q, $d) => $q->whereDate('created_at', '>=', $d))
            ->when($request->end_date, fn ($q, $d) => $q->whereDate('created_at', '<=', $d))
            ->latest('created_at');

        return $this->success($query->paginate(20));
    }

    /**
     * GET /audit-logs/{auditLog}
     */
    public function show(AuditLog $auditLog): JsonResponse
    {
        return $this->success($auditLog->load('user'));
    }
}
