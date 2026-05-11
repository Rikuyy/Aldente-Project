<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\OtpCode;
use App\Models\Admin; // <-- GANTI: Gunakan Admin, bukan User
use App\Notifications\SendOtpNotification;
use Carbon\Carbon;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PasswordResetLinkController extends Controller
{
    /**
     * Tampilan 1: Form input email
     */
    public function create(): View
    {
        return view('auth.forgot-password');
    }

    /**
     * Proses 1: Generate OTP dan Kirim ke Email
     */
    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'email' => ['required', 'email'],
        ]);

        // MENCARI ADMIN: Sesuaikan dengan field 'Email' (E kapital)
        $admin = Admin::where('Email', $request->email)->first();

        if (!$admin) {
            return back()->withErrors(['email' => 'Email admin tidak ditemukan di sistem!']);
        }

        // Generate 6 angka random
        $otp = rand(100000, 999999);

        // Simpan ke database (koleksi otp_codes)
        // Kita gunakan 'Email' (kapital) supaya konsisten dengan tabel Admin
        OtpCode::updateOrCreate(
            ['Email' => $request->email], 
            [
                'otp' => (int)$otp,
                'expires_at' => Carbon::now()->addMinutes(5)
            ]
        );

        // Kirim email notifikasi
        $admin->notify(new SendOtpNotification($otp));

        // Pindah ke halaman input kode
        return redirect()->route('password.otp.view', ['email' => $request->email])
                         ->with('status', 'Kode OTP sudah dikirim ke email kamu.');
    }

    /**
     * Proses 2: Verifikasi OTP
     */
    public function verifyOtp(Request $request): RedirectResponse
    {
        $request->validate([
            'email' => ['required', 'email'],
            'otp'   => ['required', 'numeric'],
        ]);

        // Cek kode OTP di database
        $check = OtpCode::where('Email', $request->email)
                        ->where('otp', (int)$request->otp)
                        ->where('expires_at', '>', Carbon::now())
                        ->first();

        if (!$check) {
            return back()->withErrors(['otp' => 'Kode OTP salah atau sudah kedaluwarsa!']);
        }

        // Jika benar, lanjut ke halaman reset password
        // Token kita isi dengan kode OTP-nya saja untuk sementara
        return redirect()->route('password.reset', [
            'token' => $request->otp, 
            'email' => $request->email
        ]);
    }
}