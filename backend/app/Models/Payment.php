<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Payment extends Model
{
    protected $fillable = [
        'user_id',
        'amount',
        'mandatory_fee',
        'allocation_type',
        'payment_status',
        'payment_month',
        'proof_image',
        'verified_by',
        'verified_at',
        'rejection_reason',
    ];

    protected $appends = ['proof_image_url'];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'mandatory_fee' => 'decimal:2',
            'payment_month' => 'date',
            'verified_at' => 'datetime',
        ];
    }

    /**
     * Secure API URL for the proof image — requires auth to access.
     * Returns null if no proof has been uploaded yet.
     */
    protected function proofImageUrl(): Attribute
    {
        return Attribute::get(
            fn () => $this->proof_image
                ? rtrim(config('app.url'), '/') . "/api/v1/payments/{$this->id}/proof"
                : null
        );
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function allocations(): HasMany
    {
        return $this->hasMany(PaymentAllocation::class);
    }
}
