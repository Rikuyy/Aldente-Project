<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model; // Pastikan pakai model MongoDB

class OtpCode extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'otp_codes';

    protected $fillable = [
        'email', 'kode', 'expired_at', 'is_used'
    ];

    protected $casts = [
        'expired_at' => 'datetime',
        'is_used' => 'boolean'
    ];
}