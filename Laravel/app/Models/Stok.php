<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Stok extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'stok';
    protected $primaryKey = 'Id_Stok';

    protected $fillable = [
        'Id_User', 
        'Nama_Bahan', 
        'Kategori_Bahan', 
        'Jumlah_Bahan', 
        'Satuan_Bahan', 
        'Tanggal_Beli', 
        'Tanggal Kadaluarsa'
    ];
}