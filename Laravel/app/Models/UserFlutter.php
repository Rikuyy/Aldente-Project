<?php

namespace App\Models;

use MongoDB\Laravel\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens; // WAJIB ADA
use Illuminate\Notifications\Notifiable;

class UserFlutter extends Authenticatable
{
    use HasApiTokens, Notifiable; // Pasang di sini

    protected $connection = 'mongodb';
    protected $collection = 'users'; // Sesuai permintaanmu

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];
}