<?php

namespace App\Models;

use MongoDB\Laravel\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;

class Admin extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $connection = 'mongodb';
    protected $collection = 'admins'; // Udah dibalikin jadi 'admin' tanpa 's' ya!

    // $primaryKey DIHAPUS agar Laravel Auth membaca _id bawaan MongoDB

    protected $fillable = [
        'Username', 
        'Password', 
        'Email',
        'is_setup_done'
    ];

    protected $hidden = [
        'Password',
        'remember_token',
    ];

    protected $casts = [
        'Password' => 'hashed',
    ];

    public function getAuthPassword()
    {
        return $this->Password;
    }
}