<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
use App\Models\OtpCode;
use App\Helpers\OtpHelper;
use App\Notifications\SendOtpNotification;
use Carbon\Carbon;

class UserAuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string|unique:users,Username|min:3|max:50',
            'email'    => 'required|email|unique:users,Email',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) return response()->json(['success' => false, 'errors' => $validator->errors()], 422);

        $user = User::create([
            'Username' => $request->username,
            'Email'    => $request->email,
            'Password' => Hash::make($request->password),
            'Jumlah_Makan' => $request->jumlah_makan ?? 0,
            'Budget_Bulanan' => $request->budget_bulanan ?? 0,
        ]);

        return response()->json([
            'success' => true,
            'token' => $user->createToken('auth_token')->plainTextToken
        ], 201);
    }

    public function login(Request $request)
    {
        $user = User::where('Email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->Password)) {
            return response()->json(['success' => false, 'message' => 'Email atau password salah'], 401);
        }

        return response()->json([
            'success' => true,
            'token' => $user->createToken('auth_token')->plainTextToken,
            'user' => $user
        ]);
    }

    public function forgotPassword(Request $request)
    {
        $user = User::where('Email', $request->email)->first();
        if (!$user) return response()->json(['success' => false, 'message' => 'Email tidak terdaftar'], 404);

        // Pakai Helper biar kodenya rapi
        $otp = OtpHelper::generateOtp($request->email);
        $user->notify(new SendOtpNotification($otp));

        return response()->json(['success' => true, 'message' => 'OTP terkirim!']);
    }
}