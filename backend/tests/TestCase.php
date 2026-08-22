<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    protected static ?array $cachedRoles = null;

    protected function seedRoles(): array
    {
        $memberRole = \App\Models\Role::where('name', 'Member')->first()
            ?? \App\Models\Role::create(['name' => 'Member']);
        $adminRole = \App\Models\Role::where('name', 'Admin')->first()
            ?? \App\Models\Role::create(['name' => 'Admin']);

        return [$memberRole, $adminRole];
    }

    protected function createMemberUser(array $attributes = []): \App\Models\User
    {
        [$memberRole] = $this->seedRoles();

        return \App\Models\User::factory()->create(array_merge([
            'role_id' => $memberRole->id,
        ], $attributes));
    }

    protected function createAdminUser(array $attributes = []): \App\Models\User
    {
        [, $adminRole] = $this->seedRoles();

        return \App\Models\User::factory()->create(array_merge([
            'role_id' => $adminRole->id,
        ], $attributes));
    }

    protected function seedSettings(): \App\Models\Setting
    {
        return \App\Models\Setting::first() ?? \App\Models\Setting::create([
            'monthly_fee' => 10000,
            'target_per_child' => 70000,
        ]);
    }
}


