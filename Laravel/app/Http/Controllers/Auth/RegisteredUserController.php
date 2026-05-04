<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Providers\RouteServiceProvider;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;
use Illuminate\View\View;

class RegisteredUserController extends Controller
{
    /**
     * Menampilkan halaman Setup (Hanya jika belum ada akun).
     */
    public function create(): View|RedirectResponse
    {
        // Jika sudah ada akun di database, kunci akses dan lempar ke login
        // Serta kirimkan pesan 'info' untuk ditampilkan di halaman login
        if (User::exists()) {
            return redirect()->route('login')->with('info', 'Registrasi ditutup karena sistem sudah dikonfigurasi (Admin sudah terdaftar).');
        }

        return view('auth.register');
    }

    /**
     * Proses pendaftaran Admin Pertama.
     */
public function store(Request $request): RedirectResponse
{
    $request->validate([
        'name' => ['required', 'string', 'max:255'],
        'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:admin,email'],
        'password' => ['required', 'confirmed', Rules\Password::defaults()],
    ]);

    // Pastikan ini menggunakan model yang sudah kamu set ke collection 'admins'
    $user = User::create([  // Pastikan pakai Model User
        'name' => $request->name,
        'email' => $request->email,
        'password' => Hash::make($request->password),
        'role' => 'admin', // Tambahkan ini kalau mau kasih tanda role
    ]);

    event(new Registered($user));

    Auth::login($user);

    return redirect(RouteServiceProvider::HOME);
}
}