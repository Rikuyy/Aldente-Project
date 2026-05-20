<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\DashboardController as ApiDashboardController;
use App\Http\Controllers\API\StockController;
<<<<<<< HEAD
aAuse App\Http\Controllers\API\SetupController;
use App\Http\Controllers\API\ConsultationController;
use App\Http\Controllers\DashboardController;
=======
=======
>>>>>>> d0ef53e (perubahan testing model dan resep web)
use App\Http\Controllers\API\KeuanganController;
use App\Http\Controllers\API\ProfileController;
use App\Http\Controllers\API\ConsultationController;
use App\Http\Controllers\ResepController;
use App\Http\Controllers\ChatbotController;
<<<<<<< HEAD
use Illuminate\Support\Facades\Password;

// AUTH PUBLIC
=======
>>>>>>> d0ef53e (perubahan testing model dan resep web)

/*
|--------------------------------------------------------------------------
| API Routes (Untuk Flutter - Menggunakan JWT)
|--------------------------------------------------------------------------
*/

<<<<<<< HEAD
// ── AUTH PUBLIC (Tidak Perlu Login) ─────────────────────────────
=======
// AUTH PUBLIC
>>>>>>> d0ef53e (perubahan testing model dan resep web)
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

<<<<<<< HEAD

// ── PROTECTED ROUTES (Wajib Login & Menggunakan JWT) ─────────────
// PROTECTED ROUTES (Wajib Login & Full Menggunakan JWT)
=======
// PROTECTED ROUTES (JWT)
>>>>>>> d0ef53e (perubahan testing model dan resep web)
Route::middleware('auth:api')->group(function () {

    Route::prefix('dashboard')->group(function () {
        // Menggunakan ApiDashboardController agar sesuai dengan alias import di atas
        Route::get('/summary', [ApiDashboardController::class, 'summary']);
        Route::get('/laporan', [ApiDashboardController::class, 'laporan']);
        Route::get('/', [ApiDashboardController::class, 'index']);
        Route::post('/budget', [ApiDashboardController::class, 'setBudget']);
    });

    Route::prefix('inventory')->group(function () {
<<<<<<< HEAD
        // Pastikan StockController kamu ada di folder App\Http\Controllers\API\StockController
        Route::get('/',               [StockController::class, 'index']);
        Route::get('/search',         [StockController::class, 'search']);
        Route::post('/',              [StockController::class, 'store']);
        Route::put('/{id}',           [StockController::class, 'update']);
        Route::delete('/{id}',        [StockController::class, 'deleteStock']);
=======
        Route::get('/', [StockController::class, 'index']);
        Route::get('/search', [StockController::class, 'search']);
        Route::post('/', [StockController::class, 'store']);
        Route::put('/{id}', [StockController::class, 'update']);
        Route::delete('/{id}', [StockController::class, 'deleteStock']);
>>>>>>> d0ef53e (perubahan testing model dan resep web)
        Route::post('/masak-selesai', [StockController::class, 'masakSelesai']);
    });

    Route::prefix('resep')->group(function () {
        Route::get('/', [ResepController::class, 'index']);
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

<<<<<<< HEAD
    
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
=======
    Route::prefix('keuangan')->group(function () {
        Route::get('/ringkasan', [KeuanganController::class, 'ringkasan']);
        Route::get('/grafik', [KeuanganController::class, 'grafik']);
        Route::get('/mutasi', [KeuanganController::class, 'mutasi']);
        Route::get('/{id}', [KeuanganController::class, 'detail']);
>>>>>>> d0ef53e (perubahan testing model dan resep web)
    });

    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'show']);
        Route::put('/', [ProfileController::class, 'update']);
    });
});