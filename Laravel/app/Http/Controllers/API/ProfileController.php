<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProfileController extends Controller
{
    /**
     * 1. GET: Mengambil data profil user
     */
    public function show(Request $request)
    {
        // Hubungkan ke sistem auth kamu (contoh memakai Sanctum/Passport)
        // $user = $request->user(); 

        // Ini data dummy dulu agar Flutter-mu bisa ngetes koneksi API
        $profileData = [
            'name' => 'Budi',
            'fav_foods' => ['Pedas', 'Ayam', 'Gurih'],
            'allergies' => ['Kacang'],
            'budget_cycle' => 'Mingguan',
            'missing_tools' => ['Oven', 'Blender'],
            'eat_frequency' => 3,
        ];

        return response()->json([
            'success' => true,
            'message' => 'Data profil berhasil diambil',
            'data' => $profileData
        ], 200);
    }

    /**
     * 2. PUT/POST: Menyimpan perubahan profil dari Flutter
     */
    public function update(Request $request)
    {
        // Validasi data yang masuk dari Flutter agar tidak merusak database
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'fav_foods' => 'array',
            'allergies' => 'array',
            'budget_cycle' => 'required|in:Harian,Mingguan,Bulanan',
            'missing_tools' => 'array',
            'eat_frequency' => 'required|integer|min:1|max:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // TODO: Simpan data ke Database kamu di sini
        // $user = $request->user();
        // $user->update([...]);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'data' => $request->all() // Mengembalikan data yang baru disimpan
        ], 200);
    }
}