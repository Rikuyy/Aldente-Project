<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User; // Pakai User karena ini target Admin
use Illuminate\Support\Facades\Hash;

class SetupController extends Controller
{
    /**
     * Mendaftarkan Admin pertama kali via API
     */
    public function registerAdmin(Request $request)
    {
        // Proteksi: Cek apakah sudah ada admin di koleksi 'admin'
        if (User::count() > 0) {
            return response()->json([
                'message' => 'Akses ditolak! Admin sudah terdaftar di sistem.'
            ], 403);
        }

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:admin,email',
            'password' => 'required|min:8'
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'admin',
            'is_setup_done' => true,
            'username' => strtolower(str_replace(' ', '', $request->name)),
        ]);

        return response()->json([
            'message' => 'Admin Berhasil Dibuat!',
            'data' => $user
        ], 201);
    }
}