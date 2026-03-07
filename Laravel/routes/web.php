<?php

use App\Http\Controllers\Auth\AuthController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| AUTH ROUTES (guest only)
|--------------------------------------------------------------------------
*/
Route::middleware('guest')->group(function () {

    // Login
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);

    // Register
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);

});

/*
|--------------------------------------------------------------------------
| PROTECTED ROUTES (auth only)
|--------------------------------------------------------------------------
*/
Route::middleware('auth')->group(function () {

    // Dashboard — ganti dengan controller kamu
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');

    // Logout
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

});

/*
|--------------------------------------------------------------------------
| ROOT REDIRECT
|--------------------------------------------------------------------------
*/
Route::get('/', function () {
    return redirect()->route('dashboard');
});
