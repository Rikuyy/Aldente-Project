<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UserFlutter; // <-- HARUS PAKAI MODEL INI
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // CEK DI SINI: Dia nyarinya ke UserFlutter, bukan User bawaan Breeze
        $user = UserFlutter::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Email atau Password salah'], 401);
        }

        // Generate Token pakai Sanctum (kalau sudah setup)
        $token = $user->createToken('flutter-token')->plainTextToken;

        return response()->json([
            'message' => 'Login Berhasil',
            'user' => $user,
            'token' => $token
        ]);
    }
}