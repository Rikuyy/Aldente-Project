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
        // Keamanan ekstra: Jika ditembak via API/Postman tetap ditolak kalau user sudah ada
        if (User::exists()) {
            abort(403, 'Sistem sudah dikonfigurasi. Registrasi ditutup.');
        }

        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:'.User::class],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        event(new Registered($user));

        Auth::login($user);

        return redirect(RouteServiceProvider::HOME);
    }
}