<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\OtpCode;
use App\Models\User;
use App\Notifications\SendOtpNotification;
use Carbon\Carbon;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PasswordResetLinkController extends Controller
{
    /**
     * Tampilan 1: Form input email (Halaman Lupa Password)
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

        // Cari user di koleksi admin
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return back()->withErrors(['email' => 'Email admin tidak ditemukan di sistem!']);
        }

        // Generate 6 angka random
        $otp = rand(100000, 999999);

        // Simpan ke database MongoDB (koleksi otp_codes)
        OtpCode::updateOrCreate(
            ['email' => $request->email],
            [
                'otp' => (int)$otp,
                'expires_at' => Carbon::now()->addMinutes(5) // Berlaku 5 menit
            ]
        );

        // Kirim email notifikasi
        $user->notify(new SendOtpNotification($otp));

        // Pindah ke halaman input kode
        return redirect()->route('password.otp.view', ['email' => $request->email])
                         ->with('status', 'Kode OTP sudah dikirim ke email kamu.');
    }

    /**
     * Proses 2: Cek apakah kode yang diinput user bener/salah
     */
    public function verifyOtp(Request $request): \Illuminate\Http\RedirectResponse
    {
        $request->validate([
            'email' => ['required', 'email'],
            'otp'   => ['required', 'numeric'],
        ]);

        $check = \App\Models\OtpCode::where('email', $request->email)
                        ->where('otp', (int)$request->otp)
                        ->where('expires_at', '>', \Carbon\Carbon::now())
                        ->first();

        if (!$check) {
            return back()->withErrors(['otp' => 'Kode OTP salah atau sudah kedaluwarsa!']);
        }

        // JANGAN MENGHAPUS OTP DI SINI. Kita hapus nanti setelah password berhasil diganti.

        // Lanjut ke halaman reset password bawaan Breeze
        return redirect()->route('password.reset', [
            'token' => $request->otp, 
            'email' => $request->email
        ]);
    
    }
}