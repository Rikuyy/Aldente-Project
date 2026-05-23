<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class JadwalMakan extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'jadwal_makan';
    protected $primaryKey = 'Id_JadwalMakan';

    protected $fillable = [
        'Id_User', 
        'Id_Resep', 
        'Tanggal', 
        'Sesi Makan'
    ];
}