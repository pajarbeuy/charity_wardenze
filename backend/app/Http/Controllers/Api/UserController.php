<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Role;
use App\Models\User;
use App\Services\AuditService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly AuditService $audit,
    ) {}

    /**
     * GET /users
     */
    public function index(Request $request): JsonResponse
    {
        $query = User::with('role')
            ->when($request->search, fn ($q, $s) => $q->where('name', 'like', "%{$s}%")->orWhere('email', 'like', "%{$s}%"))
            ->when($request->status === 'active', fn ($q) => $q->whereNull('deleted_at'))
            ->when($request->status === 'inactive', fn ($q) => $q->onlyTrashed())
            ->latest();

        return $this->success($query->paginate(15));
    }

    /**
     * GET /users/{user}
     */
    public function show(User $user): JsonResponse
    {
        return $this->success($user->load('role'));
    }

    /**
     * POST /users
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => 'required|string|max:150',
            'email' => 'required|email|unique:users,email',
            'password' => 'nullable|string|min:8',
            'phone' => 'nullable|string|max:30',
            'role' => 'nullable|in:Admin,Member',
        ]);

        $role = Role::where('name', $data['role'] ?? 'Member')->first();

        $user = User::create([
            'role_id' => $role->id,
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'] ?? Str::random(12),
            'phone' => $data['phone'] ?? null,
        ]);

        $this->audit->log($request, 'USER_CREATED', $user);

        return $this->success($user->load('role'), 'User Created', 201);
    }

    /**
     * PUT /users/{user}
     */
    public function update(Request $request, User $user): JsonResponse
    {
        $data = $request->validate([
            'name' => 'sometimes|required|string|max:150',
            'email' => ['sometimes', 'required', 'email', Rule::unique('users')->ignore($user->id)],
            'phone' => 'nullable|string|max:30',
            'role' => 'nullable|in:Admin,Member',
        ]);

        if (isset($data['role'])) {
            $role = Role::where('name', $data['role'])->first();
            $data['role_id'] = $role->id;
            unset($data['role']);
        }

        $user->update($data);

        $this->audit->log($request, 'USER_UPDATED', $user);

        return $this->success($user->fresh()->load('role'), 'User Updated');
    }

    /**
     * DELETE /users/{user} — Soft Delete
     */
    public function destroy(Request $request, User $user): JsonResponse
    {
        abort_unless($user->id !== $request->user()->id, 422, 'Cannot delete yourself.');

        $user->delete();

        $this->audit->log($request, 'USER_DELETED', $user);

        return response()->json(null, 204);
    }
}
