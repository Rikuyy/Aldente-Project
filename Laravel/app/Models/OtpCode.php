<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class OtpCode extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'otp_codes';

    protected $fillable = [
        'Email', // Gunakan E kapital agar konsisten dengan model Admin
        'otp',
        'expires_at'
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'otp' => 'integer'
    ];
}