<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Inventory extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'nama_bahan', 'kategori', 'jumlah', 'satuan', 'harga_satuan', 'status', 'tanggal_beli', 'tanggal_kadaluarsa'];
    protected $casts = ['tanggal_beli' => 'date', 'tanggal_kadaluarsa' => 'date', 'jumlah' => 'decimal:2', 'harga_satuan' => 'decimal:2'];

    public function user() { return $this->belongsTo(User::class); }
}