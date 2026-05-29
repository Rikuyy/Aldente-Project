<?php

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
        'Kategori',          // 'Beli', 'Masak', 'Topup', 'Penarikan', 'Lainnya'
        'Detail_Beli',
        'Total_Pengeluaran',
    ];

    protected $casts = [
        'Id_User' => 'string',
        'Id_JadwalMakan' => 'string',
        'Total_Pengeluaran' => 'double',
        'Detail_Beli' => 'array',
    ];

    public function jadwalMakan()
    {
        return $this->belongsTo(JadwalMakan::class, 'Id_JadwalMakan');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'Id_User');
    }
}