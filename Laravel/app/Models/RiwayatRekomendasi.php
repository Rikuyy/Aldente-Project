<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model; // WAJIB PAKE INI UNTUK MONGODB

class RiwayatRekomendasi extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'riwayat_rekomendasi';

    protected $fillable = [
        'user_id',
        'resep_id',
    ];

    // Laravel otomatis akan mengurus 'created_at' dan 'updated_at' 
    // menjadi format BSON Date agar TTL 7 Harimu berfungsi!
}