<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\AuditService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly AuditService $audit,
    ) {}

    /**
     * POST /auth/login
     */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::with('role')->where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return $this->fail('Invalid credentials', null, 401);
        }

        $token = $user->createToken('cfms')->plainTextToken;

        $this->audit->log($request, 'LOGIN', $user);

        return $this->success([
            'token' => $token,
            'user' => $user,
        ], 'Login Success');
    }

    /**
     * POST /auth/logout
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        $this->audit->log($request, 'LOGOUT');

        return $this->success(null, 'Logout Success');
    }

    /**
     * GET /auth/me
     */
    public function me(Request $request): JsonResponse
    {
        return $this->success($request->user()->load('role'));
    }
}
