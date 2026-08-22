<?php

namespace Tests\Feature;

use App\Models\Payment;
use App\Models\Withdrawal;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ReportTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_generate_pdf_and_excel_report_data_with_filters(): void
    {
        $admin = $this->createAdminUser();
        $member = $this->createMemberUser(['name' => 'Budi Donatur']);

        // Create verified payment
        Payment::create([
            'user_id' => $member->id,
            'amount' => 50000,
            'mandatory_fee' => 10000,
            'allocation_type' => 'DONATION',
            'payment_status' => 'VERIFIED',
            'payment_month' => now()->startOfMonth(),
            'verified_at' => now(),
        ]);

        // Create withdrawal
        Withdrawal::create([
            'user_id' => $admin->id,
            'amount' => 20000,
            'withdraw_date' => now()->toDateString(),
            'description' => 'Santunan',
        ]);

        // 1. PDF Endpoint verification
        $responsePdf = $this->actingAs($admin)->getJson('/api/v1/reports/pdf?start_date=' . now()->subDays(7)->toDateString() . '&end_date=' . now()->toDateString());

        $responsePdf->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'period' => ['start_date', 'end_date'],
                    'summary' => ['total_income', 'total_expense', 'current_cash'],
                    'donations',
                    'withdrawals',
                ],
            ])
            ->assertJsonPath('data.summary.total_income', 50000)
            ->assertJsonPath('data.summary.total_expense', 20000)
            ->assertJsonPath('data.summary.current_cash', 30000);

        // 2. Excel Endpoint verification
        $responseExcel = $this->actingAs($admin)->getJson('/api/v1/reports/excel');

        $responseExcel->assertStatus(200)
            ->assertJsonPath('data.summary.current_cash', 30000);
    }

    public function test_report_fails_when_end_date_is_before_start_date(): void
    {
        $admin = $this->createAdminUser();

        $response = $this->actingAs($admin)->getJson('/api/v1/reports/pdf?start_date=2026-08-10&end_date=2026-08-01');

        $response->assertStatus(422);
    }

    public function test_member_cannot_access_reports(): void
    {
        $member = $this->createMemberUser();

        $this->actingAs($member)->getJson('/api/v1/reports/pdf')->assertStatus(403);
        $this->actingAs($member)->getJson('/api/v1/reports/excel')->assertStatus(403);
    }
}
