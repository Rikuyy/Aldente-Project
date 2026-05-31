<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class JadwalHarian extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'jadwal_harian';
    protected $table = 'jadwal_harian';
    protected $fillable = [
        'Id_User',
        'Tanggal',
        'sesi_ke',
        'Sesi Makan',
        'Id_Resep',
    ];

    public function resep()
    {
        return $this->belongsTo(Resep::class, 'Id_Resep', 'id');
    }
}