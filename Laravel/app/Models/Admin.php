<?php

namespace App\Models;

use MongoDB\Laravel\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;

class Admin extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $connection = 'mongodb';
    protected $collection = 'admins'; 

    protected $fillable = [
        'Username', 
        'Password', 
        'Email',
    ];

    protected $hidden = [
        'Password',
        'remember_token',
    ];

    protected $casts = [
        'Password' => 'hashed',
    ];

    /**
     * PENTING: Memberitahu Laravel ke mana email harus dikirim.
     * Karena field di MongoDB kamu 'Email' (kapital), Laravel butuh ini.
     */
    public function routeNotificationForMail($notification)
    {
        return $this->Email;
    }

    /**
     * Beritahu Laravel bahwa kolom password di DB namanya 'Password'
     */
    public function getAuthPassword()
    {
        return $this->Password;
    }
}