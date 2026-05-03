<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;

class UserController extends Controller
{
    public function index(Request $request)
    {
        // Panggil user yang berperan sebagai 'user' (Anak Kos)
        $query = User::where('role', 'user');

        // Jika ada inputan di kolom pencarian
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        // withQueryString() biar kalau pindah halaman (pagination), hasil pencariannya gak hilang
        $users = $query->latest()->paginate(10)->withQueryString();
        
        return view('users', compact('users'));
    }

    public function store(Request $request) 
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:'.User::class],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'user', // Otomatis diset sebagai anak kos
        ]);

        return redirect()->route('users.index')->with('success', 'Berhasil! Anak kos baru sudah ditambahkan.');
    }

    public function show(string $id) 
    {
        // Biasanya dipakai buat lihat detail, tapi kita skip dulu karena di tabel udah cukup
    }

    public function update(Request $request, string $id) 
    {
        $user = User::findOrFail($id);

        // Validasi (Email unik kecuali buat user ini sendiri)
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:users,email,'.$user->id],
        ]);

        // Update nama dan email
        $user->name = $request->name;
        $user->email = $request->email;

        // Kalau password diisi, berarti dia mau ganti password. Kalau kosong, abaikan.
        if ($request->filled('password')) {
            // Hapus rule 'confirmed' karena di modal edit tidak ada input konfirmasi password
            $request->validate([
                'password' => [Rules\Password::defaults()],
            ]);
            $user->password = Hash::make($request->password);
        }

        $user->save();

        return redirect()->route('users.index')->with('success', 'Data anak kos berhasil diupdate!');
    }

    public function destroy(string $id) 
    {
        $user = User::findOrFail($id);
        $user->delete();

        return redirect()->route('users.index')->with('success', 'Sip, user berhasil dihapus dari sistem.');
    }
}