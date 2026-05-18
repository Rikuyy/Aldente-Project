<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Stok extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'stok';
    protected $table = 'stok'; // ← tambah ini
    
    protected $fillable = [
        'Id_User', 'Nama_Bahan', 'Kategori_Bahan', 'Jumlah_Bahan', 
        'Satuan_Bahan', 'Tanggal_Beli', 'Tanggal_Kadaluarsa'
    ];

    protected $casts = [
        'Jumlah_Bahan'       => 'float', 
        'Tanggal_Beli'       => 'date',
        'Tanggal_Kadaluarsa' => 'date',
    ];
}