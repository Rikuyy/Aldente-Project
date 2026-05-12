<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Import semua controller yang dibutuhkan 
use App\Http\Controllers\API\Auth\AuthController;
use App\Http\Controllers\API\SetupController;
use App\Http\Controllers\API\ConsultationController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\InventoryController;
use App\Http\Controllers\ResepController;
use App\Http\Controllers\ChatbotController;


/*
|--------------------------------------------------------------------------
| API Routes (Untuk Flutter)
|--------------------------------------------------------------------------
*/

// Auth routes (tidak perlu login)
Route::prefix('auth')->group(function () {
    Route::post('/register',         [AuthController::class, 'register']);
    Route::post('/login',            [AuthController::class, 'login']);
    Route::post('/forgot-password',  [AuthController::class, 'forgotPassword']);
    Route::post('/verify-otp',       [AuthController::class, 'verifyOtp']);
    Route::post('/reset-password',   [AuthController::class, 'resetPassword']);

    // Butuh login untuk logout & profil
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout',       [AuthController::class, 'logout']);
        Route::get('/me',            [AuthController::class, 'me']);
    });
});

// Routes yang butuh login (Sanctum)
Route::middleware('auth:sanctum')->group(function () {
    // User data
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Dashboard
    Route::get('/dashboard/summary', [DashboardController::class, 'summary']);
    Route::get('/dashboard/laporan', [DashboardController::class, 'laporan']);

    // Inventory
    Route::prefix('inventory')->group(function () {
        Route::get('/',                 [InventoryController::class, 'index']);
        Route::post('/',                [InventoryController::class, 'store']);
        Route::put('/{id}',             [InventoryController::class, 'update']);
        Route::delete('/{id}',          [InventoryController::class, 'destroy']);
        Route::post('/masak-selesai',   [InventoryController::class, 'masakSelesai']);
    });

    // Resep
    Route::prefix('resep')->group(function () {
        Route::get('/',         [ResepController::class, 'index']);
        Route::post('/',        [ResepController::class, 'store']);
        Route::put('/{id}',     [ResepController::class, 'update']);
        Route::delete('/{id}',  [ResepController::class, 'destroy']);
    });

    // Chatbot
    Route::prefix('chatbot')->group(function () {
        Route::post('/rekomendasi', [ChatbotController::class, 'rekomendasi']);
        Route::post('/update-ai',    [ChatbotController::class, 'updateModel']);
        Route::post('/evaluasi',     [ChatbotController::class, 'evaluasi']);
    });

    
});

Route::post('/consultation', [ConsultationController::class, 'send']);
