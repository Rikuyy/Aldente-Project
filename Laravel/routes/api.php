<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// API Test Resep (Database Kosong)
Route::get('/resep', function () {
    return response()->json([
        'status' => 'success',
        'message' => 'Data resep dari MongoDB belum tersedia.',
        'data' => [] // Dikosongkan sesuai permintaanmu
    ]);
});