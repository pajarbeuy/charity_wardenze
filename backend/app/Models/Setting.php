<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    protected $fillable = [
        'monthly_fee',
        'target_per_child',
        'qris_image',
        'organization_name',
        'organization_logo',
    ];

    protected function casts(): array
    {
        return [
            'monthly_fee' => 'decimal:2',
            'target_per_child' => 'decimal:2',
        ];
    }
}
