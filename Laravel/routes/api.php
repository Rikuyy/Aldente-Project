<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\DashboardController as ApiDashboardController;
use App\Http\Controllers\API\StockController;
use App\Http\Controllers\API\KeuanganController;
use App\Http\Controllers\API\ProfileController;
use App\Http\Controllers\DashboardController as WebDashboardController;
use App\Http\Controllers\ResepController;
use App\Http\Controllers\ChatbotController;
use Illuminate\Support\Facades\Password;

// AUTH PUBLIC
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login',    [AuthController::class, 'login']);
    
    // API Forgot Password
    Route::post('/forgot-password', function (Request $request) {
        $request->validate(['email' => 'required|email']);
        
        // Menggunakan fitur bawaan Laravel untuk kirim link reset via Gmail
        $status = Password::sendResetLink($request->only('email'));

        return $status === Password::RESET_LINK_SENT
            ? response()->json(['message' => 'Link reset password telah dikirim ke email kamu!'])
            : response()->json(['message' => 'Gagal mengirim email reset'], 400);
    });

    // Routes yang memerlukan token JWT
    Route::middleware('auth:api')->group(function () {
        Route::get('/me',      [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

// PROTECTED ROUTES (Wajib Login & Full Menggunakan JWT)
Route::middleware('auth:api')->group(function () {

    // ── Dashboard ─────────────────────────────
    Route::prefix('dashboard')->group(function () {
        // Menggunakan ApiDashboardController agar sesuai dengan alias import di atas
        Route::get('/summary', [ApiDashboardController::class, 'summary']);
        Route::get('/laporan', [ApiDashboardController::class, 'laporan']);
        Route::get('/',        [ApiDashboardController::class, 'index']);
        Route::post('/budget', [ApiDashboardController::class, 'setBudget']);
    });

    // ── Inventory / Stock ──────────────────────
    Route::prefix('inventory')->group(function () {
        // Pastikan StockController kamu ada di folder App\Http\Controllers\API\StockController
        Route::get('/',               [StockController::class, 'index']);
        Route::get('/search',         [StockController::class, 'search']);
        Route::post('/',              [StockController::class, 'store']);
        Route::put('/{id}',           [StockController::class, 'update']);
        Route::delete('/{id}',        [StockController::class, 'deleteStock']);
        Route::post('/masak-selesai', [StockController::class, 'masakSelesai']);
    });

    // ── Resep ──────────────────────────────────
    Route::prefix('resep')->group(function () {
        Route::get('/',         [ResepController::class, 'index']);
        Route::post('/',        [ResepController::class, 'store']);
        Route::put('/{id}',     [ResepController::class, 'update']);
        Route::delete('/{id}',  [ResepController::class, 'destroy']);
    });

    // ── Chatbot AI ─────────────────────────────
    Route::prefix('chatbot')->group(function () {
        Route::post('/rekomendasi', [ChatbotController::class, 'rekomendasi']);
        Route::post('/update-ai',   [ChatbotController::class, 'updateModel']);
        Route::post('/evaluasi',    [ChatbotController::class, 'evaluasi']);
    });

    // ── Laporan Keuangan ────────────────────────
    Route::prefix('keuangan')->group(function () {
        // Ringkasan bulan: total, rata2, prediksi, komposisi
        Route::get('/ringkasan', [KeuanganController::class, 'ringkasan']);
        // Data grafik tren harian
        Route::get('/grafik',    [KeuanganController::class, 'grafik']);
        // List mutasi (pagination)
        Route::get('/mutasi',    [KeuanganController::class, 'mutasi']);
        // Detail 1 transaksi
        Route::get('/{id}',      [KeuanganController::class, 'detail']);
    });

    // ── Profil User ─────────────────────────────
    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'show']);
        Route::put('/', [ProfileController::class, 'update']);
    });
});