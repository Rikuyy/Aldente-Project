<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule; // Menggunakan Rule class lebih aman untuk MongoDB
use Illuminate\View\View;

class RegisteredUserController extends Controller
{
    /**
     * Menampilkan halaman registrasi.
     */
    public function create(): View|RedirectResponse
    {
        // Proteksi: Hanya boleh ada 1 Admin (Setup pertama kali)
        if (Admin::count() > 0) {
            return redirect()->route('login')->with('status', 'Setup sudah selesai, silakan login.');
        }

        return view('auth.register');
    }

    /**
     * Proses pendaftaran admin baru.
     */
    public function store(Request $request): RedirectResponse
    {
        if (Admin::count() > 0) {
            return redirect()->route('login');
        }

        // REVISI VALIDASI: Menggunakan Rule::unique untuk memaksa koneksi mongodb
        $request->validate([
            'name'  => ['required', 'string', 'max:255'],
            'email' => [
                'required', 
                'string', 
                'email', 
                'max:255', 
                Rule::unique('mongodb.admins', 'Email') // Memastikan validator menunjuk ke mongodb
            ],
            // REVISI PASSWORD: Menghindari Rules\Password::defaults() 
            // karena sering memicu query SQL tersembunyi
            'password' => ['required', 'confirmed', 'min:8'], 
        ]);

        try {
            // Simpan data dengan field yang sesuai di MongoDB
            $admin = Admin::create([ 
                'Username' => $request->name,
                'Email'    => strtolower($request->email), // Konsistensi huruf kecil
                'Password' => Hash::make($request->password), // Hash manual
            ]);

            Auth::login($admin);

            return redirect()->route('dashboard'); 

        } catch (\Exception $e) {
            return back()->withErrors(['email' => 'Gagal menyimpan data: ' . $e->getMessage()]);
        }
    }
}