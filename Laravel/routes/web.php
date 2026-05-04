<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\DashboardController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;

Route::redirect('/', '/login');

// =========================================================
// ZONA AMAN (Web Admin)
// =========================================================
Route::middleware(['auth', 'verified'])->group(function () {
    
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    Route::get('/resep', function () {
        return view('resep');
    })->name('resep.index');

    Route::get('/bahan', function () {
        return view('bahan');
    })->name('bahan.index');

    // Route Testing dipindah ke sini (Hanya Admin yang bisa akses)
    Route::get('/testing', function () {
        $routes = collect(\Route::getRoutes())->filter(function($route) {
            return str_contains($route->uri, 'api/') && !str_contains($route->uri, 'sanctum');
        })->map(function($route) {
            return [
                'method' => $route->methods[0],
                'uri' => '/' . ltrim($route->uri, '/')
            ];
        })->values();

        return view('testing', compact('routes'));
    })->name('testing');

    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

Route::middleware('auth')->group(function () {
    // Route untuk halaman user
Route::get('/manajemen-user', [UserController::class, 'index'])->name('users.index');
    Route::delete('/manajemen-user/{user}', [UserController::class, 'destroy'])->name('users.destroy');
});

require __DIR__.'/auth.php';