<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule; 
use Illuminate\Validation\Rules\Password; 
use Illuminate\View\View;

class RegisteredUserController extends Controller
{
    public function create(): View|RedirectResponse
    {
        if (Admin::count() > 0) {
            return redirect()->route('login')->with('status', 'Setup sudah selesai, silakan login.');
        }

        return view('auth.register');
    }

    public function store(Request $request): RedirectResponse
    {
        if (Admin::count() > 0) {
            return redirect()->route('login');
        }

        $request->validate([
            'name'  => ['required', 'string', 'max:255'],
            'email' => [
                'required', 
                'string', 
                'email', 
                'max:255', 
                Rule::unique('mongodb.admins', 'Email') 
            ],
            'password' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()], 
        ], [
            'name.required' => 'Nama admin tidak boleh kosong.',
            'email.required' => 'Email tidak boleh kosong.',
            'email.unique' => 'Email ini sudah terdaftar sebelumnya.',
            'password.required' => 'Kata sandi tidak boleh kosong.',
            'password.confirmed' => 'Konfirmasi kata sandi tidak cocok.',
            // Pesan simpel:
            'password.min' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.mixed' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.numbers' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
            'password.symbols' => 'Sandi min. 8 karakter, huruf besar, kecil, angka dan simbol.',
        ]);

        try {
            $admin = Admin::create([ 
                'Username' => $request->name,
                'Email'    => strtolower($request->email), 
                'Password' => Hash::make($request->password), 
            ]);

            return redirect()->route('login')->with('status', 'Registrasi admin berhasil! Silakan login.'); 

        } catch (\Exception $e) {
            return back()->withErrors(['email' => 'Gagal menyimpan data: ' . $e->getMessage()]);
        }
    }
}