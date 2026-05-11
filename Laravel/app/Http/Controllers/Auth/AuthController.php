<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Notification;
use App\Models\User;
use App\Models\OtpCode;
use App\Notifications\SendOtpNotification;
use Carbon\Carbon;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username'              => 'required|string|unique:users,Username|min:3|max:50',
            'email'                 => 'required|email|unique:users,Email',
            'password'              => 'required|string|min:6|confirmed',
            'password_confirmation' => 'required',
            'jumlah_makan'          => 'required|integer|min:1',
            'budget_bulanan'        => 'required|numeric|min:0',
        ], [
            'username.unique'       => 'Username sudah digunakan',
            'email.unique'          => 'Email sudah terdaftar',
            'password.confirmed'    => 'Konfirmasi password tidak cocok',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $user = User::create([
            'Username'       => $request->username,
            'Email'          => $request->email,
            'Password'       => Hash::make($request->password),
            'Jumlah_Makan'   => $request->jumlah_makan,
            'Budget_Bulanan' => $request->budget_bulanan,
            'Kategori_Favorit' => $request->kategori_favorit ?? null,
            'Alergi'         => $request->alergi ?? null,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil!',
            'data'    => ['user' => $user, 'token' => $token],
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $user = User::where('Email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->Password)) {
            return response()->json(['success' => false, 'message' => 'Email atau password salah'], 401);
        }

        // Hapus token lama biar ga numpuk
        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil!',
            'data'    => ['user' => $user, 'token' => $token],
        ]);
    }

    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,Email',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => 'Email tidak terdaftar'], 422);
        }

        // 1. Generate OTP
        $kode = str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);

        // 2. Simpan ke koleksi otp_codes
        OtpCode::updateOrCreate(
            ['email' => $request->email],
            [
                'kode' => $kode,
                'expired_at' => Carbon::now()->addMinutes(5),
                'is_used' => false,
            ]
        );

        // 3. Kirim Email pakai Notification yang kamu punya
        $user = User::where('Email', $request->email)->first();
        try {
            $user->notify(new SendOtpNotification($kode));
            return response()->json([
                'success' => true,
                'message' => 'Kode OTP telah dikirim ke email kamu',
                'otp_debug' => $kode // Hapus line ini jika sudah siap rilis
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Gagal kirim email: ' . $e->getMessage()], 500);
        }
    }

    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'kode'  => 'required|string|size:4',
        ]);

        if ($validator->fails()) return response()->json(['success' => false, 'errors' => $validator->errors()], 422);

        $otp = OtpCode::where('email', $request->email)
            ->where('kode', $request->kode)
            ->where('is_used', false)
            ->where('expired_at', '>', Carbon::now())
            ->first();

        if (!$otp) {
            return response()->json(['success' => false, 'message' => 'OTP salah atau kadaluarsa'], 400);
        }

        $otp->update(['is_used' => true]);

        return response()->json(['success' => true, 'message' => 'OTP valid!']);
    }

    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email|exists:users,Email',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) return response()->json(['success' => false, 'errors' => $validator->errors()], 422);

        $user = User::where('Email', $request->email)->first();
        $user->update(['Password' => Hash::make($request->password)]);
        
        OtpCode::where('email', $request->email)->delete();

        return response()->json(['success' => true, 'message' => 'Password berhasil diubah']);
    }

    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data'    => $request->user(),
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['success' => true, 'message' => 'Berhasil logout']);
    }
}