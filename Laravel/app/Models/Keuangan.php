<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Keuangan extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'keuangan';
    protected $table = 'keuangan';
    //protected $primaryKey = 'Id_Keuangan';

    protected $fillable = [
        'Id_User', 
        'Id_JadwalMakan', 
        'Tanggal', 
        'Waktu', 
        'Jenis_Pengeluaran', 
        'Detail_Beli', // Pastikan ini masuk fillable
        'Total Pengeluaran'
    ];

    // WAJIB TAMBAHKAN INI UNTUK ARRAY MONGODB
    protected $casts = [
        'Detail_Beli' => 'array', 
    ];
}