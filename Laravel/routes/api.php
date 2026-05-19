<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\DashboardController as ApiDashboardController;
use App\Http\Controllers\API\StockController;
<<<<<<< HEAD

// Import semua controller yang dibutuhkan 
use App\Http\Controllers\API\Auth\AuthController;
use App\Http\Controllers\API\SetupController;
use App\Http\Controllers\API\ConsultationController;
use App\Http\Controllers\DashboardController;
=======
use App\Http\Controllers\API\KeuanganController;
use App\Http\Controllers\API\ProfileController;
use App\Http\Controllers\DashboardController as WebDashboardController;
>>>>>>> 22ce2f3 (menambahkan backend stok,dashboard,keuangan di laravel)
use App\Http\Controllers\ResepController;
use App\Http\Controllers\ChatbotController;
use Illuminate\Support\Facades\Password;

// AUTH PUBLIC
<<<<<<< HEAD
=======
use App\Http\Controllers\API\ConsultationController;

>>>>>>> 80a03bc (backend auth flutter)

/*
|--------------------------------------------------------------------------
| API Routes (Untuk Flutter)
|--------------------------------------------------------------------------
*/

<<<<<<< HEAD
// Auth routes (tidak perlu login)
=======
// ── AUTH PUBLIC (Tidak Perlu Login) ─────────────────────────────
>>>>>>> 80a03bc (backend auth flutter)
Route::prefix('auth')->group(function () {
    Route::post('/register',        [AuthController::class, 'register']);
    Route::post('/login',           [AuthController::class, 'login']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/verify-otp',      [AuthController::class, 'verifyOtp']);
    Route::post('/reset-password',  [AuthController::class, 'resetPassword']);

    // Routes auth yang memerlukan token JWT
    Route::middleware('auth:api')->group(function () {
        Route::get('/me',      [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

// Rute Konsultasi (Publik - Dari Versi Atas)
Route::post('/consultation', [ConsultationController::class, 'send']);


// ── PROTECTED ROUTES (Wajib Login & Menggunakan JWT) ─────────────
Route::middleware('auth:api')->group(function () {

    // ── Dashboard ─────────────────────────────
    Route::prefix('dashboard')->group(function () {
        Route::get('/summary', [ApiDashboardController::class, 'summary']);
        Route::get('/laporan', [ApiDashboardController::class, 'laporan']);
        Route::get('/',        [ApiDashboardController::class, 'index']);
        Route::post('/budget', [ApiDashboardController::class, 'setBudget']);
    });

    // ── Inventory / Stock ──────────────────────
    Route::prefix('inventory')->group(function () {
        Route::get('/',               [StockController::class, 'index']);
        Route::get('/search',         [StockController::class, 'search']);
        Route::post('/',              [StockController::class, 'store']);
        Route::put('/{id}',           [StockController::class, 'update']);
        Route::delete('/{id}',        [StockController::class, 'deleteStock']);
        Route::post('/masak-selesai', [StockController::class, 'masakSelesai']);
    });

    // ── Resep ──────────────────────────────────
    Route::prefix('resep')->group(function () {
        Route::get('/',     [ResepController::class, 'index']);
        Route::post('/',    [ResepController::class, 'store']);
        Route::put('/{id}', [ResepController::class, 'update']);
        Route::delete('/{id}', [ResepController::class, 'destroy']);
    });

    // ── Chatbot AI ─────────────────────────────
    Route::prefix('chatbot')->group(function () {
        Route::post('/rekomendasi', [ChatbotController::class, 'rekomendasi']);
        Route::post('/update-ai',   [ChatbotController::class, 'updateModel']);
        Route::post('/evaluasi',    [ChatbotController::class, 'evaluasi']);
    });

<<<<<<< HEAD
    
});

Route::post('/consultation', [ConsultationController::class, 'send']);
=======
    // ── Laporan Keuangan ────────────────────────
    Route::prefix('keuangan')->group(function () {
        Route::get('/ringkasan', [KeuanganController::class, 'ringkasan']);
        Route::get('/grafik',    [KeuanganController::class, 'grafik']);
        Route::get('/mutasi',    [KeuanganController::class, 'mutasi']);
        Route::get('/{id}',      [KeuanganController::class, 'detail']);
    });

    // ── Profil User ─────────────────────────────
    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'show']);
        Route::put('/', [ProfileController::class, 'update']);
    });
});
>>>>>>> 22ce2f3 (menambahkan backend stok,dashboard,keuangan di laravel)
