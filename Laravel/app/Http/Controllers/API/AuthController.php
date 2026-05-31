<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\Rules\Password; // <-- Ditambahkan ini
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
            'password' => ['required', 'string', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()], // <-- Diubah ini
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors'  => $validator->errors()
            ], 422);
        }

        try {
            // Membuat data ke MongoDB dengan ID khas Mongo NoSQL
            $user = User::create([
                'Id_User'          => (string) new \MongoDB\BSON\ObjectId(), 
                'Username'         => $request->username,
                'Email'            => strtolower($request->email),
                'Password'         => Hash::make($request->password),
                'Kategori_Favorit' => $request->kategori_favorit ?? null,
                'Jumlah_Makan'     => (int) ($request->jumlah_makan ?? 0),
                'Budget_Bulanan'   => (float) ($request->budget_bulanan ?? 0),
                'Saldo_Budget'     => (float) ($request->budget_bulanan ?? 0), // Default otomatis menyamai Budget_Bulanan
                'Alergi'           => $request->alergi ?? null,
            ]);

            // Gunakan metode login() yang adaptif terhadap MongoDB ObjectId string
            $token = auth('api')->login($user);

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
     * LOGIN - menggunakan username (case-insensitive) untuk MongoDB
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validator->errors()
            ], 422);
        }

        // Query MongoDB dengan regex case-insensitive
        $user = User::where('Username', 'regex', '/' . preg_quote($request->username, '/') . '/i')->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Username tidak ditemukan'
            ], 401);
        }

        if (!Hash::check($request->password, $user->Password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password salah'
            ], 401);
        }

        try {
            $token = auth('api')->login($user);
            $needsOnboarding = $this->checkNeedsOnboarding($user);

            return response()->json([
                'success'          => true,
                'message'          => 'Login Berhasil',
                'access_token'     => $token,
                'needs_onboarding' => $needsOnboarding,
                'user'             => $user
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
     * Cek apakah user perlu onboarding
     */
    private function checkNeedsOnboarding($user): bool
    {
        $kategori = $user->Kategori_Favorit ?? [];
        if (!is_array($kategori) || count($kategori) < 2) {
            return true;
        }

        $budget = (float) ($user->Budget_Bulanan ?? 0);
        if ($budget <= 0) {
            return true;
        }

        $jumlahMakan = (int) ($user->Jumlah_Makan ?? 0);
        if ($jumlahMakan < 2 || $jumlahMakan > 4) {
            return true;
        }

        return false;
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
                        ->subject('CookCash - Verifikasi Kode OTP Anda')
                        ->html("
                        <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden;'>
                            <div style='background-color: #FF7643; padding: 24px; text-align: center;'>
                                <h1 style='color: white; margin: 0; font-size: 26px; letter-spacing: 1px;'>CookCash</h1>
                            </div>
                            <div style='padding: 30px; background-color: #ffffff;'>
                                <p style='font-size: 16px; color: #333333; line-height: 1.5;'>Halo,</p>
                                <p style='font-size: 16px; color: #333333; line-height: 1.5;'>Kami menerima permintaan untuk mereset kata sandi akun CookCash Anda. Silakan gunakan kode OTP di bawah ini untuk melanjutkan proses verifikasi:</p>
                                
                                <div style='text-align: center; margin: 30px 0;'>
                                    <div style='display: inline-block; background-color: #fff3ed; border: 2px dashed #FF7643; border-radius: 12px; padding: 15px 40px;'>
                                        <span style='font-size: 36px; font-weight: bold; color: #FF7643; letter-spacing: 6px;'>{$otp}</span>
                                    </div>
                                </div>

                                <p style='font-size: 14px; color: #757575; text-align: center; font-style: italic;'>Kode ini rahasia dan hanya berlaku selama <b>5 menit</b> demi keamanan akun Anda.</p>
                                <hr style='border: 0; border-top: 1px solid #eeeeee; margin: 30px 0;'>
                                <p style='font-size: 12px; color: #999999; line-height: 1.5; text-align: center;'>Jika Anda tidak merasa melakukan permintaan ini, abaikan email ini dengan aman.<br>&copy; 2026 CookCash Team. All Rights Reserved.</p>
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

        $otpData->delete();

        return response()->json([
            'success' => true,
            'message' => 'Verifikasi OTP Berhasil! Silakan buat kata sandi baru.'
        ], 200);
    }

    /**
     * RESET PASSWORD
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => ['required', 'string', 'confirmed', Password::min(8)->mixedCase()->numbers()->symbols()], // <-- Diubah ini
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

        $user->update([
            'Password' => Hash::make($request->password)
        ]);

        try {
            if (!$token = auth('api')->login($user)) {
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
     * GET AUTHENTICATED USER
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