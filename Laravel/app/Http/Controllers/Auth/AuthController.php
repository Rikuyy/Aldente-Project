<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
use App\Models\OtpCode;
use Carbon\Carbon;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username'              => 'required|string|unique:users,username|min:3|max:50',
            'name'                  => 'required|string|max:100',
            'email'                 => 'required|email|unique:users,email',
            'password'              => 'required|string|min:6|confirmed',
            'password_confirmation' => 'required',
        ], [
            'username.required'     => 'Username tidak boleh kosong',
            'username.unique'       => 'Username sudah digunakan',
            'username.min'          => 'Username minimal 3 karakter',
            'name.required'         => 'Nama lengkap tidak boleh kosong',
            'email.required'        => 'Email tidak boleh kosong',
            'email.email'           => 'Format email tidak valid',
            'email.unique'          => 'Email sudah terdaftar',
            'password.required'     => 'Password tidak boleh kosong',
            'password.min'          => 'Password minimal 6 karakter',
            'password.confirmed'    => 'Konfirmasi password tidak cocok',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $user = User::create([
            'username' => $request->username,
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil!',
            'data'    => [
                'user'  => [
                    'id'       => $user->id,
                    'username' => $user->username,
                    'name'     => $user->name,
                    'email'    => $user->email,
                ],
                'token' => $token,
            ],
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => 'required|string',
        ], [
            'email.required'    => 'Email tidak boleh kosong',
            'email.email'       => 'Format email tidak valid',
            'password.required' => 'Password tidak boleh kosong',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah',
            ], 401);
        }

        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil!',
            'data'    => [
                'user'  => [
                    'id'       => $user->id,
                    'username' => $user->username,
                    'name'     => $user->name,
                    'email'    => $user->email,
                ],
                'token' => $token,
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->tokens()->delete();
        return response()->json(['success' => true, 'message' => 'Logout berhasil!']);
    }

    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email',
        ], [
            'email.required' => 'Email tidak boleh kosong',
            'email.email'    => 'Format email tidak valid',
            'email.exists'   => 'Email tidak terdaftar',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        OtpCode::where('email', $request->email)->delete();
        $kode = str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);

        OtpCode::create([
            'email'      => $request->email,
            'kode'       => $kode,
            'expired_at' => Carbon::now()->addMinutes(2),
            'is_used'    => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Kode OTP telah dikirim ke email kamu',
            'otp'     => $kode, // Hapus di production!
        ]);
    }

    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'kode'  => 'required|string|size:4',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $otp = OtpCode::where('email', $request->email)
            ->where('kode', $request->kode)
            ->where('is_used', false)
            ->where('expired_at', '>', Carbon::now())
            ->first();

        if (!$otp) {
            return response()->json(['success' => false, 'message' => 'Kode OTP tidak valid atau sudah kadaluarsa'], 400);
        }

        $otp->update(['is_used' => true]);

        return response()->json(['success' => true, 'message' => 'OTP valid! Silakan reset password kamu', 'email' => $request->email]);
    }

    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'                 => 'required|email|exists:users,email',
            'password'              => 'required|string|min:6|confirmed',
            'password_confirmation' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $user = User::where('email', $request->email)->first();
        $user->update(['password' => Hash::make($request->password)]);
        OtpCode::where('email', $request->email)->delete();

        return response()->json(['success' => true, 'message' => 'Password berhasil direset! Silakan login']);
    }

    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data'    => [
                'id'       => $request->user()->id,
                'username' => $request->user()->username,
                'name'     => $request->user()->name,
                'email'    => $request->user()->email,
            ],
        ]);
    }
}