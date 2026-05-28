<?php
// app/Models/Keuangan.php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Keuangan extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'keuangan';
    
    protected $primaryKey = '_id';
    
    protected $fillable = [
        'Id_User',
        'Id_JadwalMakan',
        'Tanggal',
        'Waktu',
        'Jenis_Pengeluaran', // 'Beli', 'Masak', 'Topup'
        'Detail_Beli',
        'Total_Pengeluaran', // nominal positif
        'is_debit',          // true = pengeluaran, false = pemasukan
    ];

    protected $casts = [
        'Id_User' => 'string',
        'Id_JadwalMakan' => 'string',
        'Total_Pengeluaran' => 'double',
        'Detail_Beli' => 'array',
        'is_debit' => 'boolean',
    ];

    // Relasi ke JadwalMakan
    public function jadwalMakan()
    {
        return $this->belongsTo(JadwalMakan::class, 'Id_JadwalMakan');
    }

    // Relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class, 'Id_User');
    }
}