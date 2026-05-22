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
        // KUNCI: Kalau admin sudah ada di MongoDB, jangan boleh buka halaman daftar
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
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
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