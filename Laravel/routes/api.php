<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\DashboardController as ApiDashboardController;
use App\Http\Controllers\API\StockController;
use App\Http\Controllers\API\ConsultationController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\API\KeuanganController;
use App\Http\Controllers\API\ProfileController;
use App\Http\Controllers\ResepController;
use App\Http\Controllers\ChatbotController;
use Illuminate\Support\Facades\Password;

// AUTH PUBLIC

/*
|--------------------------------------------------------------------------
| API Routes (Untuk Flutter - Menggunakan JWT)
|--------------------------------------------------------------------------
*/

// ── AUTH PUBLIC (Tidak Perlu Login) ─────────────────────────────
// AUTH PUBLIC
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);

    // Menggunakan guard JWT
    Route::middleware('auth:api')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

Route::post('/consultation', [ConsultationController::class, 'send']);


// ── PROTECTED ROUTES (Wajib Login & Menggunakan JWT) ─────────────
// PROTECTED ROUTES (Wajib Login & Full Menggunakan JWT)
// PROTECTED ROUTES (JWT)
Route::middleware('auth:api')->group(function () {

    Route::prefix('dashboard')->group(function () {
        // Menggunakan ApiDashboardController agar sesuai dengan alias import di atas
        Route::get('/summary', [ApiDashboardController::class, 'summary']);
        Route::get('/laporan', [ApiDashboardController::class, 'laporan']);
        Route::get('/', [ApiDashboardController::class, 'index']);
        Route::post('/budget', [ApiDashboardController::class, 'setBudget']);
    });

    Route::prefix('stok')->group(function () {
        // Pastikan StockController kamu ada di folder App\Http\Controllers\API\StockController
        Route::get('/',               [StockController::class, 'index']);
        Route::get('/cari',           [StockController::class, 'cari']);
        Route::post('/',              [StockController::class, 'simpan']);
        Route::put('/{id}',           [StockController::class, 'perbarui']);
        Route::delete('/{id}',        [StockController::class, 'hapus']);
        Route::post('/masak-selesai', [StockController::class, 'masakSelesai']);
    });

    Route::prefix('resep')->group(function () {
        Route::get('/', [ResepController::class, 'index']);
        Route::get('/categories', [ResepController::class,      'getCategories']);
        Route::post('/', [ResepController::class, 'store']);
        Route::put('/{id}', [ResepController::class, 'update']);
        Route::delete('/{id}', [ResepController::class, 'destroy']);
    });

    Route::prefix('chatbot')->group(function () {
        Route::post('/rekomendasi', [ChatbotController::class, 'rekomendasi']);
        Route::post('/update-ai', [ChatbotController::class, 'updateModel']);
        // Evaluasi untuk Flutter tetap disini (menggunakan JWT)
        Route::post('/evaluasi', [ChatbotController::class, 'evaluasi']); 
    });

    
});

Route::post('/consultation', [ConsultationController::class, 'send']);
    // ── Laporan Keuangan ────────────────────────
    Route::prefix('keuangan')->group(function () {
        Route::get('/ringkasan', [KeuanganController::class, 'ringkasan']);
        Route::get('/grafik',    [KeuanganController::class, 'grafik']);
        Route::get('/mutasi',    [KeuanganController::class, 'mutasi']);
        // Ringkasan bulan: total, rata2, prediksi, komposisi
        Route::get('/ringkasan', [KeuanganController::class, 'ringkasan']);
        // Data grafik tren harian
        Route::get('/grafik',    [KeuanganController::class, 'grafik']);
        // List mutasi (pagination)
        Route::get('/mutasi',    [KeuanganController::class, 'mutasi']);
        // Detail 1 transaksi
        Route::get('/{id}',      [KeuanganController::class, 'detail']);
    Route::prefix('keuangan')->group(function () {
        Route::get('/ringkasan', [KeuanganController::class, 'ringkasan']);
        Route::get('/grafik', [KeuanganController::class, 'grafik']);
        Route::get('/mutasi', [KeuanganController::class, 'mutasi']);
        Route::get('/{id}', [KeuanganController::class, 'detail']);
    });

    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'show']);
        Route::put('/', [ProfileController::class, 'update']);
        Route::put('/profile',          [UserProfileController::class, 'saveOnboarding']);
    });
});