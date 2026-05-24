<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $connection = 'mongodb';
    protected $collection = 'users';

    protected $fillable = [
        'Username',
        'Email',
        'Password',
        'Kategori_Favorit',
        'Jumlah_Makan',
        'Budget_Bulanan',
        'Alergi',
    ];

    protected $hidden = [
        'Password',
        'remember_token',
    ];

    protected $casts = [
        'Email_verified_at' => 'datetime',
        'Jumlah_Makan' => 'integer',
        'Budget_Bulanan' => 'float',
    ];

    // Wajib untuk JWT
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [];
    }

    // Custom password field
    public function getAuthPassword()
    {
        return $this->Password;
    }
}