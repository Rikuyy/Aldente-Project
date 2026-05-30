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

    // 1. Beritahu Laravel kalau primary key kustom kita namanya Id_User
    protected $primaryKey = 'Id_User';

    // 2. WAJIB UNTUK MONGODB: Matikan auto-increment bawaan SQL agar mau menerima string ObjectId kustom
    public $incrementing = false;
    protected $keyType = 'string';

    // 3. Daftarkan semua field agar diizinkan masuk ke MongoDB (Termasuk Id_User dan Saldo_Budget!)
    protected $fillable = [
        'Id_User',         // <-- Wajib dimasukkan agar tidak diblokir Laravel
        'Username',
        'Email',
        'Password',
        'Kategori_Favorit',
        'Jumlah_Makan',
        'Budget_Bulanan',
        'Saldo_Budget',    // <-- Kolom baru kamu
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
        'Saldo_Budget' => 'float', 
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