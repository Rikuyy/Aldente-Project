<?php

namespace App\Models;

use MongoDB\Laravel\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $connection = 'mongodb';
    protected $collection = 'users';

    protected $fillable = [
        'Username', 
        'Email', 
        'Password', 
        'Kategori_Favorit', 
        'Jumlah_Makan', 
        'Budget_Bulanan', 
        'Alergi'
    ];

    protected $hidden = [
        'Password',
        'remember_token',
    ];

    /**
     * Casting data supaya pas dikirim ke Flutter tipe datanya bener.
     */
    protected $casts = [
        'Email_verified_at' => 'datetime',
        'Password' => 'hashed', // Biar otomatis aman
        'Jumlah_Makan' => 'integer',
        'Budget_Bulanan' => 'float', // Pakai float/double buat uang
    ];

    /**
     * Laravel mencari field 'password' (lowercase) secara default.
     * Fungsi ini mengarahkan Laravel ke kolom 'Password' (Capital) kamu.
     */
    public function getAuthPassword()
    {
        return $this->Password;
    }

    /**
     * (Opsional) Jika Flutter butuh field email dengan nama 'email' (kecil), 
     * tapi di DB kamu 'Email' (besar).
     */
}