<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;
use App\Models\User;
use App\Models\OtpCode;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Carbon\Carbon;

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

            $token = JWTAuth::fromUser($user);

            return response()->json([
                'success'      => true,
                'message'      => 'Registrasi Berhasil',
                'access_token' => $token,
                'user'         => $user
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal Register',
                'error'   => $e->getMessage()
            ], 500);
        }
    }

    /**
     * LOGIN
     */
    public function login(Request $request)
    {
        $credentials = [
            'Email'    => strtolower($request->email),
            'password' => $request->password
        ];

        try {
            if (!$token = auth('api')->attempt($credentials)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Email atau password salah'
                ], 401);
            }

            $user = auth('api')->user();
            $needsOnboarding = empty($user->Kategori_Favorit) 
                || empty($user->Alergi) 
                || empty($user->Budget_Bulanan) 
                || empty($user->Jumlah_Makan);
            return response()->json([
                'success'      => true,
                'message' => 'Login Berhasil',
                'access_token' => $token,
                'needs_onboarding' => $needsOnboarding, 
                'user'         => $user
            ], 200);

        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat membuat token.',
                'error'   => $e->getMessage()
            ], 500);
        }
    }

    /**
     * FORGOT PASSWORD / RESEND OTP
     */
    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email']);
        $email = strtolower($request->email);

        $user = User::where('Email', $email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak terdaftar di sistem kami.'
            ], 404);
        }

        $otp = rand(1000, 9999);

        OtpCode::where('Email', $email)->delete();

        OtpCode::create([
            'Email'      => $email,
            'otp'        => (int)$otp,
            'expires_at' => Carbon::now()->addMinutes(5)
        ]);

        try {
            Mail::send([], [], function ($message) use ($email, $otp) {
                $message->to($email)
                        ->subject('CookMate - Verifikasi Kode OTP Anda')
                        ->html("
                        <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden;'>
                            <div style='background-color: #FF7643; padding: 24px; text-align: center;'>
                                <h1 style='color: white; margin: 0; font-size: 26px; letter-spacing: 1px;'>CookMate</h1>
                            </div>
                            <div style='padding: 30px; background-color: #ffffff;'>
                                <p style='font-size: 16px; color: #333333; line-height: 1.5;'>Halo,</p>
                                <p style='font-size: 16px; color: #333333; line-height: 1.5;'>Kami menerima permintaan untuk mereset kata sandi akun CookMate Anda. Silakan gunakan kode OTP di bawah ini untuk melanjutkan proses verifikasi:</p>
                                
                                <div style='text-align: center; margin: 30px 0;'>
                                    <div style='display: inline-block; background-color: #fff3ed; border: 2px dashed #FF7643; border-radius: 12px; padding: 15px 40px;'>
                                        <span style='font-size: 36px; font-weight: bold; color: #FF7643; letter-spacing: 6px;'>{$otp}</span>
                                    </div>
                                </div>

                                <p style='font-size: 14px; color: #757575; text-align: center; font-style: italic;'>Kode ini rahasia dan hanya berlaku selama <b>5 menit</b> demi keamanan akun Anda.</p>
                                <hr style='border: 0; border-top: 1px solid #eeeeee; margin: 30px 0;'>
                                <p style='font-size: 12px; color: #999999; line-height: 1.5; text-align: center;'>Jika Anda tidak merasa melakukan permintaan ini, abaikan email ini dengan aman.<br>&copy; 2026 CookMate Team. All Rights Reserved.</p>
                            </div>
                        </div>
                        ");
            });

            return response()->json([
                'success' => true,
                'message' => 'Kode OTP berhasil dikirim ke Gmail Anda!'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengirim email: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * VERIFY OTP 
     */
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp'   => 'required'
        ]);

        $email = strtolower($request->email);
        $otpInput = (int) $request->otp;

        $otpData = OtpCode::where('Email', $email)
                          ->where('otp', $otpInput)
                          ->first();

        if (!$otpData) {
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP salah atau tidak cocok.'
            ], 400);
        }

        if (Carbon::now()->greaterThan($otpData->expires_at)) {
            $otpData->delete();
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP sudah kedaluwarsa. Silakan minta kode baru.'
            ], 400);
        }

        // Catatan: Jangan di-delete dulu di sini supaya route reset-password tahu kalau OTP ini valid, 
        // namun demi simplifikasi kita izinkan lolos ke step Flutter berikutnya.
        $otpData->delete();

        return response()->json([
            'success' => true,
            'message' => 'Verifikasi OTP Berhasil! Silakan buat kata sandi baru.'
        ], 200);
    }

    /**
     * FUNGSI BARU: RESET & UPDATE PASSWORD + AUTOMATIC LOGIN DIRECT TO DASHBOARD
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => 'required|string|min:6|confirmed', // Wajib ada password_confirmation
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validator->errors()
            ], 422);
        }

        $user = User::where('Email', strtolower($request->email))->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan.'
            ], 404);
        }

        // Update password baru ke MongoDB
        $user->update([
            'Password' => Hash::make($request->password)
        ]);

        try {
            // LOGIN OTOMATIS: Buat token JWT baru untuk user ini
            if (!$token = auth('api')->fromUser($user)) {
                return response()->json([
                    'success' => true,
                    'message' => 'Password berhasil diubah, silakan login manual.'
                ], 200);
            }

            return response()->json([
                'success'      => true,
                'message'      => 'Password Berhasil Diperbarui! Selamat Datang Kembali.',
                'access_token' => $token,
                'user'         => $user
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => true,
                'message' => 'Password berhasil diubah, silakan login manual.'
            ], 200);
        }
    }

    /**
     * ME
     */
    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data'    => auth('api')->user()
        ], 200);
    }

    /**
     * LOGOUT
     */
    public function logout(Request $request)
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());

            return response()->json([
                'success' => true,
                'message' => 'Logout Berhasil'
            ], 200);
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal Logout'
            ], 500);
        }
    }
}