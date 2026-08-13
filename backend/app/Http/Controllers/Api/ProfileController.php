<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AuditService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly AuditService $audit,
    ) {}

    /**
     * GET /profile
     */
    public function show(Request $request): JsonResponse
    {
        return $this->success($request->user()->load('role'));
    }

    /**
     * PUT /profile
     */
    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => 'sometimes|required|string|max:150',
            'phone' => 'nullable|string|max:30',
            'avatar' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $user = $request->user();

        if ($request->hasFile('avatar')) {
            // Delete old avatar if exists
            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }
            $data['avatar'] = $request->file('avatar')->store('avatars', 'public');
        }

        $user->update($data);

        $this->audit->log($request, 'UPDATE_PROFILE', $user);

        return $this->success($user->fresh()->load('role'), 'Profile Updated');
    }

    /**
     * PATCH /profile/password
     */
    public function changePassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (! Hash::check($data['current_password'], $user->password)) {
            return $this->fail('Password saat ini salah', null, 422);
        }

        $user->update(['password' => $data['new_password']]);

        $this->audit->log($request, 'CHANGE_PASSWORD', $user);

        return $this->success(null, 'Password Changed');
    }
    // delete profile/avatar
    public function deleteAvatar(Request $request)
    {
        $user = $request->user();
        if ($user->avatar && Storage::disk('public')->exists($user->avatar) ){
            Storage::disk('public')->delete($user->avatar);
        }
        $user->update(['avatar' => null]);
        $this->audit->log($request, 'DELETE_AVATAR', $user);

        return $this->success($user->fresh()->load('role'), 'Avatar deleted');
    }

    /**
     * GET /profile/avatar/{filename}
     */
    public function serveAvatar(string $filename)
    {
        $path = 'avatars/' . $filename;
        if (! Storage::disk('public')->exists($path)) {
            abort(404, 'Avatar not found');
        }

        return response()->file(Storage::disk('public')->path($path), [
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        ]);
    }
}
