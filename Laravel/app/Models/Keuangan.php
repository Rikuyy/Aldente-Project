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
        'Kategori', 
        'Keterangan',
        'Detail',
        'Total_Nominal'
    ];
 
    protected $casts = [
        'Detail' => 'array',
        'Total_Nominal' => 'float',
    ];
    protected $appends = ['is_debit'];

    public function getIsDebitAttribute(): bool
    {
        return $this->Kategori === 'Pengeluaran';
    }
}