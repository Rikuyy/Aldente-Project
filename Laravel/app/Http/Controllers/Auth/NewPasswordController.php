<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Models\OtpCode;
use Carbon\Carbon;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;
use Illuminate\View\View;

class NewPasswordController extends Controller
{
    public function create(Request $request): View
    {
        return view('auth.reset-password', ['request' => $request]);
    }

    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'token' => ['required'], 
            'email' => ['required', 'email'],
            'password' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()],
        ], [
            'password.required' => 'Kata sandi tidak boleh kosong.',
            'password.confirmed' => 'Konfirmasi kata sandi tidak cocok.',
            // Semua jenis error kata sandi disatukan ke pesan simpel ini:
            'password.min' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.mixed' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.numbers' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.symbols' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
        ]);

        $otpRecord = OtpCode::where('Email', $request->email)
                            ->where('otp', (int)$request->token)
                            ->where('expires_at', '>', Carbon::now())
                            ->first();

        if (!$otpRecord) {
            return back()->withErrors(['email' => 'Sesi OTP tidak valid atau sudah kedaluwarsa! Silakan minta OTP baru.']);
        }

        $admin = Admin::where('Email', $request->email)->first();
        
        if ($admin) {
            $admin->Password = Hash::make($request->password);
            $admin->save();

            $otpRecord->delete();

            return redirect()->route('login')->with('status', 'Password berhasil direset! Silakan login menggunakan password baru.');
        }

        return back()->withErrors(['email' => 'Admin tidak ditemukan.']);
    }
}