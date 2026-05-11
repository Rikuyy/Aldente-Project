<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Admin; // 1. WAJIB GANTI IMPORT JADI MODEL ADMIN
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
     * Menampilkan halaman Setup (Hanya jika belum ada admin).
     */
    public function create(): View|RedirectResponse
    {
        // 2. Cek ke model Admin, bukan User
        // Jika sudah ada admin di database, kunci akses dan lempar ke login
        if (Admin::exists()) {
            return redirect()->route('login')->with('info', 'Registrasi ditutup karena sistem sudah dikonfigurasi (Admin sudah terdaftar).');
        }

        return view('auth.register');
    }

    /**
     * Proses pendaftaran Admin Pertama.
     */
    public function store(Request $request): RedirectResponse
    {
        // 3. Validasi
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            // unique:admin,Email -> pastikan cek ke tabel 'admin' dan kolom 'Email' (huruf besar)
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:admins,Email'],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        // 4. Gunakan Model Admin dan sesuaikan nama field huruf besarnya
        $admin = Admin::create([ 
            'Username' => $request->name,      // Map input 'name' dari form ke 'Username'
            'Email'    => $request->email,     // Map input 'email' dari form ke 'Email'
            'Password' => Hash::make($request->password), // Map 'password' ke 'Password'
        ]);

        event(new Registered($admin));

        // 5. Login otomatis sebagai admin
        Auth::login($admin);

        // Lempar ke dashboard (sesuaikan dengan nama routemu)
        return redirect()->route('dashboard'); 
    }
}