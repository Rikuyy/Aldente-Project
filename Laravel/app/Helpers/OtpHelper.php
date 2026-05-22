<?php

namespace App\Helpers;

use App\Models\OtpCode;
use Carbon\Carbon;

class OtpHelper
{
    public static function generateOtp($email)
    {
        // Generate 6 angka
        $otp = rand(100000, 999999);

        // Simpan ke MongoDB (Pastikan model OtpCode sudah ada)
        OtpCode::updateOrCreate(
            ['Email' => $email],
            [
                'otp' => (int)$otp,
                'expires_at' => Carbon::now()->addMinutes(5),
            ]
        );

        return $otp;
    }
}