<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\InventoryController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

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
});