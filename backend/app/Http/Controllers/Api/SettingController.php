<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use App\Services\AuditService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SettingController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly AuditService $audit,
    ) {}

    /**
     * GET /settings
     */
    public function show(): JsonResponse
    {
        return $this->success(Setting::first());
    }

    /**
     * PUT /settings
     */
    public function update(Request $request, \App\Services\ImageService $imageService): JsonResponse
    {
        $data = $request->validate([
            'monthly_fee' => 'sometimes|required|numeric|min:1000',
            'target_per_child' => 'sometimes|required|numeric|min:1000',
            'organization_name' => 'nullable|string|max:255',
            'qris_image' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
            'organization_logo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
        ]);

        $setting = Setting::first();

        if ($request->hasFile('qris_image')) {
            if ($setting->qris_image && Storage::disk('public')->exists($setting->qris_image)) {
                Storage::disk('public')->delete($setting->qris_image);
            }
            $data['qris_image'] = $imageService->storeAsWebp(
                file: $request->file('qris_image'),
                folder: 'settings',
                disk: 'public',
                maxWidth: 1200,
                quality: 85
            );
        }

        if ($request->hasFile('organization_logo')) {
            if ($setting->organization_logo && Storage::disk('public')->exists($setting->organization_logo)) {
                Storage::disk('public')->delete($setting->organization_logo);
            }
            $data['organization_logo'] = $imageService->storeAsWebp(
                file: $request->file('organization_logo'),
                folder: 'settings',
                disk: 'public',
                maxWidth: 500,
                quality: 85
            );
        }

        $setting->update($data);

        $this->audit->log($request, 'SETTINGS_UPDATED', $setting);

        return $this->success($setting->fresh(), 'Settings Updated');
    }
}
