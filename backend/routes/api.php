<?php

use App\Http\Controllers\Api\AuditLogController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CharityTargetController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\PaymentVerificationController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SettingController;
use App\Http\Controllers\Api\StatisticsController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\WithdrawalController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — /api/v1
|--------------------------------------------------------------------------
| Total: 39 REST Endpoints
*/

// ── Authentication (3 endpoints) ────────────────────────────────────────
Route::post('/auth/login', [AuthController::class, 'login'])->name('login');
Route::get('/profile/avatar/{filename}', [ProfileController::class, 'serveAvatar']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // ── Dashboard (2 endpoints) ─────────────────────────────────────────
    Route::get('/dashboard/member', [DashboardController::class, 'member']);

    // ── Payments (5 endpoints) ──────────────────────────────────────────
    Route::get('/payments', [PaymentController::class, 'index']);
    Route::post('/payments', [PaymentController::class, 'store']);
    Route::get('/payments/{payment}', [PaymentController::class, 'show']);
    Route::get('/payments/{payment}/proof', [PaymentController::class, 'serveProof']);
    Route::post('/payments/{payment}/proof', [PaymentController::class, 'uploadProof']);
    Route::delete('/payments/{payment}', [PaymentController::class, 'cancel']);

    // ── Charity Target (1 public endpoint) ──────────────────────────────
    Route::get('/charity-target', [CharityTargetController::class, 'show']);

    // ── Profile (3 endpoints) ───────────────────────────────────────────
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::patch('/profile/password', [ProfileController::class, 'changePassword']);
    Route::post('/profile', [ProfileController::class, 'update']);
    Route::delete('/profile/avatar', [ProfileController::class, 'deleteAvatar']);

    // ── Notifications (2 endpoints) ─────────────────────────────────────
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{notification}/read', [NotificationController::class, 'markAsRead']);

    // ── Admin Only Routes ───────────────────────────────────────────────
    Route::middleware('admin')->group(function () {
        // Dashboard Admin (1 endpoint)
        Route::get('/dashboard/admin', [DashboardController::class, 'admin']);

        // Payment Verification (3 endpoints)
        Route::get('/admin/payments/pending', [PaymentVerificationController::class, 'pending']);
        Route::patch('/admin/payments/{payment}/verify', [PaymentVerificationController::class, 'verify']);
        Route::patch('/admin/payments/{payment}/reject', [PaymentVerificationController::class, 'reject']);

        // Withdrawals (5 endpoints)
        Route::get('/withdrawals', [WithdrawalController::class, 'index']);
        Route::post('/withdrawals', [WithdrawalController::class, 'store']);
        Route::get('/withdrawals/{withdrawal}', [WithdrawalController::class, 'show']);
        Route::put('/withdrawals/{withdrawal}', [WithdrawalController::class, 'update']);
        Route::delete('/withdrawals/{withdrawal}', [WithdrawalController::class, 'destroy']);

        // Users (5 endpoints)
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::get('/users/{user}', [UserController::class, 'show']);
        Route::put('/users/{user}', [UserController::class, 'update']);
        Route::delete('/users/{user}', [UserController::class, 'destroy']);

        // Statistics (3 endpoints)
        Route::get('/statistics/income', [StatisticsController::class, 'income']);
        Route::get('/statistics/expense', [StatisticsController::class, 'expense']);
        Route::get('/statistics/dashboard', [StatisticsController::class, 'dashboard']);
        Route::get('/statistics/monthly-status', [StatisticsController::class, 'monthlyStatus']);

        // Charity Target Update (1 endpoint)
        Route::put('/charity-target', [CharityTargetController::class, 'update']);

        // Reports (2 endpoints)
        Route::get('/reports/pdf', [ReportController::class, 'pdf']);
        Route::get('/reports/excel', [ReportController::class, 'excel']);

        // Audit Logs (2 endpoints)
        Route::get('/audit-logs', [AuditLogController::class, 'index']);
        Route::get('/audit-logs/{auditLog}', [AuditLogController::class, 'show']);

        // Settings (2 endpoints)
        Route::get('/settings', [SettingController::class, 'show']);
        Route::put('/settings', [SettingController::class, 'update']);
    });
});
