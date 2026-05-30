<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model as Eloquent;

class Resep extends Eloquent
{
    protected $connection = 'mongodb';
    
    // INI KUNCI UTAMANYA: Mencegah Laravel nambahin huruf 's'
    protected $table = 'resep'; 
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