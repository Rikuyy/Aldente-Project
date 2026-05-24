<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\DashboardController as ApiDashboardController;
use App\Http\Controllers\API\StockController;
use App\Http\Controllers\API\ConsultationController;
use App\Http\Controllers\API\KeuanganController;
use App\Http\Controllers\API\UserProfileController;
use App\Http\Controllers\ResepController;
use App\Http\Controllers\ChatbotController;

/*
|--------------------------------------------------------------------------
| API Routes (Untuk Flutter - Menggunakan JWT)
|--------------------------------------------------------------------------
*/

// ── AUTH PUBLIC (Tidak Perlu Login) ─────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);

    Route::middleware('auth:api')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

<<<<<<< HEAD
// Consultation tanpa auth (jika diperlukan)
Route::post('/consultation', [ConsultationController::class, 'send']);
=======
Route::post('/consultation', [ConsultationController::class, 'send']); // guest dan konsultasi belum login tetap bisa akses (menggunakan JWT opsional, untuk dapat konteks lebih kaya jika login)
>>>>>>> 3dce3ded2007c2340c53492b0ffca3ec2144b212

// ── PROTECTED ROUTES (Wajib Login & Menggunakan JWT) ─────────────
Route::middleware('auth:api')->group(function () {

    // Dashboard
    Route::prefix('dashboard')->group(function () {
        Route::get('/summary', [ApiDashboardController::class, 'summary']);
        Route::get('/laporan', [ApiDashboardController::class, 'laporan']);
        Route::get('/', [ApiDashboardController::class, 'index']);
        Route::post('/budget', [ApiDashboardController::class, 'setBudget']);
    });

<<<<<<< HEAD
    // Inventory
    Route::prefix('inventory')->group(function () {
        Route::get('/', [StockController::class, 'index']);
        Route::get('/cari', [StockController::class, 'cari']);
        Route::post('/', [StockController::class, 'simpan']);
        Route::put('/{id}', [StockController::class, 'perbarui']);
        Route::delete('/{id}', [StockController::class, 'hapus']);
=======
    Route::prefix('stok')->group(function () { 
        Route::get('/',               [StockController::class, 'index']);
        Route::get('/cari',           [StockController::class, 'cari']);
        Route::post('/',              [StockController::class, 'simpan']);
        Route::put('/{id}',           [StockController::class, 'perbarui']);
        Route::delete('/{id}',        [StockController::class, 'hapus']);
>>>>>>> 3dce3ded2007c2340c53492b0ffca3ec2144b212
        Route::post('/masak-selesai', [StockController::class, 'masakSelesai']);
    });

    // Resep (termasuk categories)
    Route::prefix('resep')->group(function () {
        Route::get('/', [ResepController::class, 'index']);
        Route::get('/categories', [ResepController::class, 'getCategories']);
        Route::post('/', [ResepController::class, 'store']);
        Route::put('/{id}', [ResepController::class, 'update']);
        Route::delete('/{id}', [ResepController::class, 'destroy']);
    });

    // Chatbot
    Route::prefix('chatbot')->group(function () {
        Route::post('/rekomendasi', [ChatbotController::class, 'rekomendasi']);
        Route::post('/update-ai', [ChatbotController::class, 'updateModel']);
        Route::post('/evaluasi', [ChatbotController::class, 'evaluasi']);
    });

<<<<<<< HEAD
    // Profil User (termasuk verifikasi password)
    Route::prefix('profile')->group(function () {
        Route::get('/', [UserProfileController::class, 'index']);
        Route::put('/', [UserProfileController::class, 'updateProfile']);
    });
    // Endpoint terpisah untuk verifikasi password (di luar prefix profile)
    Route::post('/verify-password', [UserProfileController::class, 'verifyPassword']);

    // Endpoint onboarding (PUT /profile sudah dipakai untuk update, maka onboarding menggunakan route berbeda jika diperlukan)
    // Namun jika ingin tetap menggunakan /profile untuk onboarding, bisa arahkan ke saveOnboarding, tapi lebih baik pisah:
    Route::post('/onboarding', [UserProfileController::class, 'saveOnboarding']);

    // Keuangan
=======
    Route::put('/profile',          [UserProfileController::class, 'saveOnboarding']); // Simpan data onboarding user (kategori favorit, alergi, dll)
}); 
 
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
>>>>>>> 3dce3ded2007c2340c53492b0ffca3ec2144b212
    Route::prefix('keuangan')->group(function () {
        Route::get('/ringkasan', [KeuanganController::class, 'ringkasan']);
        Route::get('/grafik', [KeuanganController::class, 'grafik']);
        Route::get('/mutasi', [KeuanganController::class, 'mutasi']);
        Route::get('/{id}', [KeuanganController::class, 'detail']);
    });
<<<<<<< HEAD
});
=======

    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'show']);
        Route::put('/', [ProfileController::class, 'update']); 
    });
});
// Konsultasi, gunakan salah satu dari dua route berikut://
//Route::middleware('auth:sanctum')->group(function () {
    //Route::post('/consultation/send', [ConsultationController::class, 'send'])
        //->name('consultation.send');
//});
Route::post('/consultation/send', [ConsultationController::class, 'send'])
    ->name('consultation.send');
//============//
>>>>>>> 3dce3ded2007c2340c53492b0ffca3ec2144b212
