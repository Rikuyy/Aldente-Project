<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\StockController;
use App\Http\Controllers\DashboardController;
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

// PROTECTED ROUTES (Wajib Login)
Route::middleware('auth:api')->group(function () {

    Route::prefix('dashboard')->group(function () {
        Route::get('/summary', [DashboardController::class, 'summary']);
        Route::get('/laporan', [DashboardController::class, 'laporan']);
    });

    Route::prefix('inventory')->group(function () {
        Route::get('/',               [StockController::class, 'index']);
        Route::get('/search',         [StockController::class, 'search']);
        Route::post('/',              [StockController::class, 'store']);
        Route::put('/{id}',           [StockController::class, 'update']);
        Route::delete('/{id}',        [StockController::class, 'deleteStock']);
        Route::post('/masak-selesai', [StockController::class, 'masakSelesai']);
    });

    Route::prefix('resep')->group(function () {
        Route::get('/',         [ResepController::class, 'index']);
        Route::post('/',        [ResepController::class, 'store']);
        Route::put('/{id}',     [ResepController::class, 'update']);
        Route::delete('/{id}',  [ResepController::class, 'destroy']);
    });

    Route::prefix('chatbot')->group(function () {
        Route::post('/rekomendasi', [ChatbotController::class, 'rekomendasi']);
        Route::post('/update-ai',   [ChatbotController::class, 'updateModel']);
        Route::post('/evaluasi',    [ChatbotController::class, 'evaluasi']);
    });
});