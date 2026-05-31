<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class PasswordController extends Controller
{
   public function update(Request $request): RedirectResponse
    {
        $validated = $request->validateWithBag('updatePassword', [
            'current_password' => ['required', 'current_password'],
            'password' => ['required', Password::min(8)->mixedCase()->numbers()->symbols(), 'confirmed'],
        ], [
            'current_password.required' => 'Kata sandi saat ini tidak boleh kosong.',
            'current_password.current_password' => 'Kata sandi saat ini yang Anda masukkan salah.',
            'password.required' => 'Kata sandi baru tidak boleh kosong.',
            'password.confirmed' => 'Konfirmasi kata sandi baru tidak cocok.',
            // Pesan simpel:
            'password.min' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.mixed' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.numbers' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.symbols' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
        ]);

        $request->user()->update([
            'Password' => Hash::make($validated['password']),
        ]);

        return back()->with('status', 'password-updated');
    }
}