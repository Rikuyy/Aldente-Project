<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController; 
use App\Http\Controllers\API\SetupController;
use App\Http\Controllers\ResepController;
use App\Http\Controllers\ChatbotController;

/*
|--------------------------------------------------------------------------
| API Routes (Untuk Flutter)
|--------------------------------------------------------------------------
*/

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
});