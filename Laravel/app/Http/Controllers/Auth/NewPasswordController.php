<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Admin; // GANTI: Pakai Admin
use App\Models\OtpCode;
use Carbon\Carbon;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\View\View;

class NewPasswordController extends Controller
{
    /**
     * Tampilkan halaman input password baru.
     */
    public function create(Request $request): View
    {
        return view('auth.reset-password', ['request' => $request]);
    }

    /**
     * Proses update password baru menggunakan verifikasi OTP.
     */
    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'token' => ['required'], // Ini adalah angka OTP dari URL
            'email' => ['required', 'email'],
            'password' => ['required', 'confirmed', 'min:8'],
        ]);

        // 1. Cek OTP-nya lagi (Gunakan 'Email' Kapital sesuai database)
        $otpRecord = OtpCode::where('Email', $request->email)
                            ->where('otp', (int)$request->token)
                            ->where('expires_at', '>', Carbon::now())
                            ->first();

        if (!$otpRecord) {
            return back()->withErrors(['email' => 'Sesi OTP tidak valid atau sudah kedaluwarsa! Silakan minta OTP baru.']);
        }

        // 2. Cari Admin (Gunakan model Admin dan field 'Email' Kapital)
        $admin = Admin::where('Email', $request->email)->first();
        
        if ($admin) {
            // Update menggunakan field 'Password' (Huruf Kapital)
            $admin->Password = Hash::make($request->password);
            $admin->save();

            // 3. Hapus OTP dari database biar tidak bisa dipakai lagi
            $otpRecord->delete();

            // 4. Sukses! Kembali ke halaman Login
            return redirect()->route('login')->with('status', 'Password berhasil direset! Silakan login menggunakan password baru.');
        }

        return back()->withErrors(['email' => 'Admin tidak ditemukan.']);
    }
}