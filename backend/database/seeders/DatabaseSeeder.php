<?php

namespace Database\Seeders;

use App\Models\Payment;
use App\Models\Role;
use App\Models\Setting;
use App\Models\User;
use App\Models\Withdrawal;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Roles
        $adminRole = Role::firstOrCreate(['name' => 'Admin']);
        $memberRole = Role::firstOrCreate(['name' => 'Member']);

        // 2. Settings
        Setting::firstOrCreate([], [
            'monthly_fee' => 10000,
            'target_per_child' => 70000,
            'organization_name' => 'Komunitas Peduli Yatim',
        ]);

        // 3. Admin User
        $admin = User::firstOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'Admin Utama',
                'password' => Hash::make('password'),
                'role_id' => $adminRole->id,
                'phone' => '081234567890',
            ]
        );

        // 4. Member Users
        $members = [
            ['name' => 'Pajar', 'email' => 'pajar@wardanze.com'],
            ['name' => 'Muhamad Danu', 'email' => 'danu@wardanze.com'],
            ['name' => 'Yaumil Dzikri', 'email' => 'yaumil@wardanze.com'],
            ['name' =>  'Egi Rizky Legi Akbar', 'email' => 'egoy@wardanze.com'],
            ['name' => 'Bilal Kahfi', 'email' => 'bilal@wardanze.com'],
        ];

        foreach ($members as $m) {
            $user = User::firstOrCreate(
                ['email' => $m['email']],
                [
                    'name' => $m['name'],
                    'password' => Hash::make('password'),
                    'role_id' => $memberRole->id,
                    'phone' => '081987654321',
                ]
            );

            // Sample verified payment
            Payment::create([
                'user_id' => $user->id,
                'amount' => 30000,
                'mandatory_fee' => 10000,
                'allocation_type' => 'NEXT_MONTH',
                'payment_status' => 'VERIFIED',
                'payment_month' => now()->startOfMonth(),
                'verified_by' => $admin->id,
                'verified_at' => now(),
            ]);
        }

        // 5. Sample Withdrawal
        Withdrawal::create([
            'user_id' => $admin->id,
            'amount' => 70000,
            'withdraw_date' => now()->subDays(2)->format('Y-m-d'),
            'description' => 'Santunan 1 Anak Yatim Bulan Ini',
        ]);
    }
}
