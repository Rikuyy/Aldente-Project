<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Stock extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'ingredient_name',
        'ingredient_category',
        'quantity',
        'unit',
        'input_date',
        'expiry_date'
    ];
}
