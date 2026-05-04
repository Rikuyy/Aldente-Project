<?php

namespace App\Models;

// Pastikan kamu sudah menginstall library mongodb/laravel-mongodb
use MongoDB\Laravel\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable; // 1. Harus di-import di sini

class User extends Authenticatable
{
    use HasApiTokens, Notifiable; // 2. WAJIB DITULIS DI SINI JUGA!
    protected $connection = 'mongodb';
    protected $collection = 'admin'; 

    // Tambahkan ini untuk memaksa Laravel tahu nama koleksinya
    public function getTable()
    {
        return 'admin';
    }
    
    // ... isi lainnya

    /**
     * Field yang boleh diisi secara massal
     */
    protected $fillable = [
        'name', 
        'email', 
        'password', 
        'username', 
        'role', 
        'is_setup_done'
    ];

    /**
     * Field yang disembunyikan saat data diubah jadi JSON
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Casting data agar formatnya sesuai
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];
}