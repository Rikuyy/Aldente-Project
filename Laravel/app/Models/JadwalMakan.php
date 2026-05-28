<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class JadwalMakan extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'jadwal_makan';
    protected $table = 'jadwal_makan';
    //protected $primaryKey = 'Id_JadwalMakan'; pakai id bawaan MongoDB

    protected $fillable = [
        'Id_User', 
        'Id_Resep', 
        'Tanggal', 
        'Sesi Makan'
    ];
    public function resep()
    {
        return $this->belongsTo(Resep::class, 'Id_Resep', 'id');
    }
}