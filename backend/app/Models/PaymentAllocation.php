<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PaymentAllocation extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'payment_id',
        'user_id',
        'allocation_month',
        'amount',
        'allocation_type',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'allocation_month' => 'date',
            'created_at' => 'datetime',
        ];
    }

    public function payment(): BelongsTo
    {
        return $this->belongsTo(Payment::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
