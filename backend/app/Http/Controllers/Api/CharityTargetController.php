<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use App\Services\CashService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CharityTargetController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly CashService $cash,
    ) {}

    /**
     * GET /charity-target
     */
    public function show(): JsonResponse
    {
        $setting = Setting::first();
        $cash = $this->cash->getCash();
        $targetPerChild = (float) $setting->target_per_child;

        return $this->success([
            'cash' => $cash,
            'target_per_child' => $targetPerChild,
            'children' => $targetPerChild > 0 ? (int) floor($cash / $targetPerChild) : 0,
        ]);
    }

    /**
     * PUT /charity-target (Admin)
     */
    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'target_per_child' => 'required|numeric|min:1',
        ]);

        $setting = Setting::first();
        $setting->update($data);

        return $this->success($setting, 'Target updated');
    }
}
