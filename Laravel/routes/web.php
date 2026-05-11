<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/login');

// Semua route yang butuh login masukkan ke dalam group ini
Route::middleware(['auth', 'verified'])->group(function () {
    
    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    // Manajemen Resep
    Route::get('/resep', function () {
        return view('resep');
    })->name('resep.index');

    // Manajemen Bahan
    Route::get('/bahan', function () {
        return view('bahan');
    })->name('bahan.index');

    // Manajemen User (User Flutter)
    Route::get('/manajemen-user', [UserController::class, 'index'])->name('users.index');
    Route::delete('/manajemen-user/{id}', [UserController::class, 'destroy'])->name('users.destroy');

    // Evaluasi Algoritma / Testing
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

    // Profile
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';