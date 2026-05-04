<?php

namespace App\Models;

<<<<<<< HEAD
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
=======
// Pastikan kamu sudah menginstall library mongodb/laravel-mongodb
use MongoDB\Laravel\Auth\User as Authenticatable;
>>>>>>> 6e0998e2e85b3d5cd7cc289d45055d4409ca031d
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

<<<<<<< HEAD
    protected $fillable = ['username', 'name', 'email', 'password'];
    protected $hidden = ['password', 'remember_token'];
    protected $casts = ['email_verified_at' => 'datetime', 'password' => 'hashed'];

    public function budgets() { return $this->hasMany(Budget::class); }
    public function expenses() { return $this->hasMany(Expense::class); }
    public function inventories() { return $this->hasMany(Inventory::class); }
=======
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
>>>>>>> 6e0998e2e85b3d5cd7cc289d45055d4409ca031d
}