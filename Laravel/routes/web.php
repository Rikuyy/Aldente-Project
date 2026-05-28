<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ResepController;
use App\Http\Controllers\ChatbotController;
use Illuminate\Support\Facades\Route;

// 1. Arahkan halaman utama ke login
Route::redirect('/', '/login');

// 2. Semua route yang butuh login (Sesi/Web)
Route::middleware(['auth', 'verified'])->group(function () {
    
    // Dashboard Utama
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    // Halaman Utama Manajemen Resep
    Route::get('/resep', function () { return view('resep'); })->name('resep.index');

    // Routing Endpoint API Berbasis JSON untuk Data Resep (Web-based)
    Route::get('/api/resep', [ResepController::class, 'index']);
    Route::post('/api/resep', [ResepController::class, 'store']);
    Route::put('/api/resep/{id}', [ResepController::class, 'update']);
    Route::delete('/api/resep/{id}', [ResepController::class, 'destroy']);

    // --- ROUTE EVALUASI UNTUK TESTING (WEB) ---
    // Menggunakan prefix /api agar konsisten dengan panggilan dari frontend
    Route::post('/api/chatbot/evaluasi', [ChatbotController::class, 'evaluasi']);

    // Manajemen Bahan
    Route::get('/bahan', function () { return view('bahan'); })->name('bahan.index');

    // Manajemen User
    Route::get('/manajemen-user', [UserController::class, 'index'])->name('users.index');
    Route::delete('/manajemen-user/{id}', [UserController::class, 'destroy'])->name('users.destroy');

    // Halaman Uji Algoritma (Testing)
    Route::get('/testing', function () {
        $routes = collect(Route::getRoutes())->filter(function($route) {
            return str_contains($route->uri, 'api/') && !str_contains($route->uri, 'sanctum');
        })->map(function($route) {
            return [
                'method' => $route->methods[0],
                'uri' => '/' . ltrim($route->uri, '/')
            ];
        })->values();

        return view('testing', compact('routes'));
    })->name('testing');

    // Profile Manajemen Akun Admin
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';