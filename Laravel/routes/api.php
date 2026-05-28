<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\DashboardController as ApiDashboardController;
use App\Http\Controllers\API\StockController;
use App\Http\Controllers\API\ConsultationController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\API\KeuanganController;
use App\Http\Controllers\API\UserProfileController;
use App\Http\Controllers\ResepController;
use App\Http\Controllers\ChatbotController; 
use App\Http\Controllers\API\TodoCookController;
use Illuminate\Support\Facades\Password;
 
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
 
Route::post('/consultation', [ConsultationController::class, 'send']);  // guest dan konsultasi belum login tetap bisa akses (menggunakan JWT opsional, untuk dapat konteks lebih kaya jika login)
// Konsultasi, gunakan salah satu dari dua route berikut://
//Route::middleware('auth:sanctum')->group(function () {
    //Route::post('/consultation/send', [ConsultationController::class, 'send'])
        //->name('consultation.send');

//});
Route::post('/consultation/send', [ConsultationController::class, 'send'])
    ->name('consultation.send'); 

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
 
    Route::prefix('inventory')->group(function () { 
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
        Route::post('/evaluasi', [ChatbotController::class, 'evaluasi']); 
    });

    Route::put('/profile/onboarding', [UserProfileController::class, 'saveOnboarding']);  
 
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
    }); 
}); 

Route::middleware('auth:api')->group(function () {
    Route::get('/jadwal/generate', [TodoCookController::class, 'generate']);
    Route::post('/jadwal-makan', [TodoCookController::class, 'store']);
    Route::post('/jadwal/rebuild-queue', [TodoCookController::class, 'rebuildQueue']);
});

// ========== TAMBAHAN ROUTE DARI KODE KEDUA (YANG BELUM ADA) ==========
Route::middleware('auth:api')->group(function () {
    // Profile routes (GET dan PUT untuk profil biasa)
    Route::prefix('profile')->group(function () {
        Route::get('/', [UserProfileController::class, 'index']);
        Route::put('/', [UserProfileController::class, 'updateProfile']);
    });
    // Verifikasi password
    Route::post('/verify-password', [UserProfileController::class, 'verifyPassword']);
    // Endpoint onboarding dengan method POST (selain PUT /profile/onboarding yang sudah ada)
    Route::post('/onboarding', [UserProfileController::class, 'saveOnboarding']);
});