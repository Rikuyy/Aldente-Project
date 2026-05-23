<?php

namespace App\Models;

// Pastikan ini yang di-import!
use MongoDB\Laravel\Eloquent\Model as Eloquent;

class Resep extends Eloquent
{
    // Paksa pakai koneksi mongodb
    protected $connection = 'mongodb';
    
    // Paksa nama koleksinya 'resep' (tanpa s)
    protected $collection = 'resep';
    protected $primaryKey = '_id'; 

    protected $guarded = [];
    protected $fillable = [
        'Title Cleaned',
        'Ingredients Cleaned',
        'Steps',
        'Loves',
        'Category',
        'Total Ingredients',
        'Total Steps'
    ];
}