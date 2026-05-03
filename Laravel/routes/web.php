<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::redirect('/', '/login');

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::get('/bahan', function () {
    return view('bahan'); // Memanggil file resources/views/bahan.blade.php
})->middleware(['auth', 'verified'])->name('bahan.index');

Route::get('/resep', function () {
    return view('resep'); // Panggil fail resep.blade.php secara terus
})->name('resep.index');

Route::get('/testing', function () {
    return view('testing');
});

Route::get('/api-tester', function () {
    return view('api-tester');
});

// Grup rute untuk SEMUA user yang sudah login (Admin & Anak Kos)
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

// Grup rute KHUSUS ADMIN (Harus login DAN role-nya Admin)
Route::middleware(['auth', \App\Http\Middleware\IsAdmin::class])->group(function () {
    Route::resource('users', UserController::class);
    
    // Nanti kalau ada halaman khusus admin lainnya (misal kelola resep/bahan),
    // kamu bisa taruh rutenya di dalam grup ini juga ya!
});

require __DIR__.'/auth.php';