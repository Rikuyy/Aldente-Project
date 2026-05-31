<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;
use Illuminate\View\View;

class RegisteredUserController extends Controller
{
    public function create(): View|RedirectResponse
    {
        if (Admin::count() > 0) {
            return redirect()->route('login');
        }
        return view('auth.register');
    }

    public function store(Request $request): RedirectResponse
    {
        if (Admin::count() > 0) return redirect()->route('login');

        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:admins,Email'],
            'password' => ['required', 'confirmed', Rules\Password::min(8)->mixedCase()->numbers()->symbols()],
        ], [
            'name.required' => 'Nama tidak boleh kosong.',
            'email.required' => 'Email tidak boleh kosong.',
            'email.unique' => 'Email ini sudah terdaftar.',
            'password.required' => 'Kata sandi tidak boleh kosong.',
            'password.confirmed' => 'Konfirmasi kata sandi tidak cocok.',
            // Pesan simpel:
            'password.min' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.mixed' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.numbers' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.symbols' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
        ]);

        $admin = Admin::create([
            'Username' => $request->name,
            'Email' => $request->email,
            'Password' => Hash::make($request->password),
        ]);

        Auth::login($admin);
        return redirect()->route('dashboard');
    }
}