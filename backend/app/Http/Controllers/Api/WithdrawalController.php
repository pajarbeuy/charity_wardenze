<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Withdrawal;
use App\Services\AuditService;
use App\Services\CashService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WithdrawalController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly AuditService $audit,
        private readonly CashService $cash,
    ) {}

    /**
     * GET /withdrawals
     */
    public function index(): JsonResponse
    {
        return $this->success(
            Withdrawal::with('creator')
                ->latest('withdraw_date')
                ->paginate(15)
        );
    }

    /**
     * POST /withdrawals
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'amount' => 'required|numeric|min:1',
            'withdraw_date' => 'required|date',
            'description' => 'required|string|max:2000',
        ]);

        if ($data['amount'] > $this->cash->getCash()) {
            return $this->fail('Saldo kas tidak mencukupi', null, 422);
        }

        $withdrawal = Withdrawal::create([
            ...$data,
            'user_id' => $request->user()->id,
        ]);

        $this->audit->log($request, 'WITHDRAWAL_CREATED', $withdrawal);

        return $this->success($withdrawal, 'Withdrawal Created', 201);
    }

    /**
     * GET /withdrawals/{withdrawal}
     */
    public function show(Withdrawal $withdrawal): JsonResponse
    {
        return $this->success($withdrawal->load('creator'));
    }

    /**
     * PUT /withdrawals/{withdrawal}
     */
    public function update(Request $request, Withdrawal $withdrawal): JsonResponse
    {
        $data = $request->validate([
            'amount' => 'required|numeric|min:1',
            'withdraw_date' => 'required|date',
            'description' => 'required|string|max:2000',
        ]);

        // Check if new amount doesn't exceed available cash
        // Available = current cash + old withdrawal amount (since we're replacing)
        $available = $this->cash->getCash() + (float) $withdrawal->amount;
        if ($data['amount'] > $available) {
            return $this->fail('Saldo kas tidak mencukupi', null, 422);
        }

        $withdrawal->update($data);

        $this->audit->log($request, 'WITHDRAWAL_UPDATED', $withdrawal);

        return $this->success($withdrawal->fresh(), 'Withdrawal Updated');
    }

    /**
     * DELETE /withdrawals/{withdrawal}
     */
    public function destroy(Request $request, Withdrawal $withdrawal): JsonResponse
    {
        $this->audit->log($request, 'WITHDRAWAL_DELETED', $withdrawal);

        $withdrawal->delete();

        return response()->json(null, 204);
    }
}
