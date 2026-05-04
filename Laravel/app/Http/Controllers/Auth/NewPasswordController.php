<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules;
use Illuminate\View\View;
use App\Models\User;
use App\Models\OtpCode;

use Carbon\Carbon;

class NewPasswordController extends Controller
{
    /**
     * Display the password reset view.
     */
    public function create(Request $request): View
    {
        return view('auth.reset-password', ['request' => $request]);
    }

    /**
     * Handle an incoming new password request.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function store(Request $request): \Illuminate\Http\RedirectResponse
    {
        $request->validate([
            'token' => ['required'], // Ini adalah angka OTP dari URL
            'email' => ['required', 'email'],
            'password' => ['required', 'confirmed', 'min:8'],
        ]);

        // 1. Cek OTP-nya lagi untuk keamanan (biar link nggak dibajak)
        $otpRecord = OtpCode::where('email', $request->email)
                            ->where('otp', (int)$request->token)
                            ->where('expires_at', '>', Carbon::now())
                            ->first();

        if (!$otpRecord) {
            return back()->withErrors(['email' => 'Sesi OTP tidak valid atau sudah kedaluwarsa! Silakan minta OTP baru.']);
        }

        // 2. Cari user dan Update Passwordnya
        $user = User::where('email', $request->email)->first();
        if ($user) {
            $user->password = Hash::make($request->password);
            $user->save();
        }

        // 3. Hapus OTP dari database biar aman dan tidak bisa dipakai dua kali
        $otpRecord->delete();

        // 4. Sukses! Kembali ke halaman Login
        return redirect()->route('login')->with('status', 'Password berhasil direset! Silakan login menggunakan password baru.');
    }
}
