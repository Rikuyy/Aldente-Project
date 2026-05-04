<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
<<<<<<< HEAD
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\InventoryController;
=======
use App\Http\Controllers\API\AuthController; 
use App\Http\Controllers\API\SetupController;
use App\Http\Controllers\ResepController;
use App\Http\Controllers\ChatbotController;
>>>>>>> 6e0998e2e85b3d5cd7cc289d45055d4409ca031d

/*
|--------------------------------------------------------------------------
| API Routes (Untuk Flutter)
|--------------------------------------------------------------------------
*/

<<<<<<< HEAD
// Auth routes (tidak perlu login)
Route::prefix('auth')->group(function () {
    Route::post('/register',        [AuthController::class, 'register']);
    Route::post('/login',           [AuthController::class, 'login']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/verify-otp',      [AuthController::class, 'verifyOtp']);
    Route::post('/reset-password',  [AuthController::class, 'resetPassword']);

    // Butuh login
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout',      [AuthController::class, 'logout']);
        Route::get('/me',           [AuthController::class, 'me']);
    });
});

// Routes yang butuh login
Route::middleware('auth:sanctum')->group(function () {
    // Dashboard
    Route::get('/dashboard/summary', [DashboardController::class, 'summary']);
    Route::get('/dashboard/laporan', [DashboardController::class, 'laporan']);

    // Inventory
    Route::get('/inventory',                    [InventoryController::class, 'index']);
    Route::post('/inventory',                   [InventoryController::class, 'store']);
    Route::put('/inventory/{id}',               [InventoryController::class, 'update']);
    Route::delete('/inventory/{id}',            [InventoryController::class, 'destroy']);
    Route::post('/inventory/masak-selesai',     [InventoryController::class, 'masakSelesai']);
=======
// Setup & Login (Public)


// Grouping biar rapi
Route::prefix('resep')->group(function () {
    Route::get('/', [ResepController::class, 'index']);
    Route::post('/', [ResepController::class, 'store']);
    Route::put('/{id}', [ResepController::class, 'update']);
    Route::delete('/{id}', [ResepController::class, 'destroy']);
});

Route::prefix('chatbot')->group(function () {
    Route::post('/rekomendasi', [ChatbotController::class, 'rekomendasi']);
    Route::post('/update-ai', [ChatbotController::class, 'updateModel']);
    Route::post('/evaluasi', [ChatbotController::class, 'evaluasi']);
});

// Ambil data user yang sedang login (Flutter)
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
>>>>>>> 6e0998e2e85b3d5cd7cc289d45055d4409ca031d
});