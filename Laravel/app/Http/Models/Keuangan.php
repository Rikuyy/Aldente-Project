<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Keuangan extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'keuangan';
    
    // Primary key default MongoDB adalah '_id', tapi Anda juga punya 'Id_Keuangan'
    // Biarkan pakai '_id' agar tidak ribet
    protected $primaryKey = '_id';
    
    // Field yang boleh diisi (mass assignment)
    protected $fillable = [
        'Id_Keuangan',
        'Id_User',
        'Id_JadwalMakan',
        'Tanggal',
        'Waktu',
        'Jenis_Pengeluaran', // 'Beli' atau 'Masak'
        'Detail_Beli',      // array untuk 'Beli', null untuk 'Masak'
        'Total_Pengeluaran',
    ];

    // Casting tipe data
    protected $casts = [
        'Id_Keuangan' => 'integer',
        'Id_User' => 'integer',
        'Id_JadwalMakan' => 'integer',
        'Total_Pengeluaran' => 'double',
        'Detail_Beli' => 'array',
        'Tanggal' => 'string',
        'Waktu' => 'string',
    ];

    // Relasi ke JadwalMakan (jika ingin pakai Eloquent)
    public function jadwalMakan()
    {
        return $this->belongsTo(JadwalMakan::class, 'Id_JadwalMakan', 'Id_JadwalMakan');
    }
}