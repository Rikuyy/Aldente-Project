<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class AuthController extends Controller
{
    /**
     * REGISTER
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string|min:3',
            'email'    => 'required|email|unique:users,Email',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors'  => $validator->errors()
            ], 422);
        }

        try {
            $user = User::create([
                'Username'         => $request->username,
                'Email'            => strtolower($request->email),
                'Password'         => Hash::make($request->password),
                'Kategori_Favorit' => $request->kategori_favorit ?? null,
                'Jumlah_Makan'     => (int) ($request->jumlah_makan ?? 0),
                'Budget_Bulanan'   => (float) ($request->budget_bulanan ?? 0),
                'Alergi'           => $request->alergi ?? null,
            ]);

            // Generate JWT token
            $token = JWTAuth::fromUser($user);

            return response()->json([
                'success' => true,
                'message' => 'Registrasi Berhasil',
                'token'   => $token,
                'user'    => $user
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success'      => false,
                'message'      => 'Gagal menyimpan data ke MongoDB. Pastikan MongoDB berjalan.',
                'error_detail' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * LOGIN
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors'  => $validator->errors()
            ], 422);
        }

        try {
            // Kredensial disesuaikan dengan field di MongoDB
            $credentials = [
                'Email'    => strtolower($request->email),
                'password' => $request->password,
            ];

            // Attempt login menggunakan guard 'api' (JWT)
            if (!$token = auth('api')->attempt($credentials)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Email atau password salah'
                ], 401);
            }

            $user = auth('api')->user();

            return response()->json([
                'success' => true,
                'message' => 'Login Berhasil',
                'token'   => $token,
                'user'    => $user
            ]);

        } catch (JWTException $e) {
            return response()->json([
                'success'      => false,
                'message'      => 'Tidak dapat membuat token.',
                'error_detail' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * ME (Get Profile)
     */
    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data'    => auth('api')->user()
        ]);
    }

    /**
     * LOGOUT
     */
    public function logout(Request $request)
    {
        try {
            // Invalidate token saat ini
            JWTAuth::invalidate(JWTAuth::getToken());

            return response()->json([
                'success' => true,
                'message' => 'Logout Berhasil'
            ]);
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal logout',
                'error_detail' => $e->getMessage()
            ], 500);
        }
    }
}