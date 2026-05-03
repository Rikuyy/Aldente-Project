<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Expense extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'budget_id', 'nama_pengeluaran', 'jumlah', 'kategori', 'tanggal', 'catatan'];
    protected $casts = ['tanggal' => 'date', 'jumlah' => 'decimal:2'];

    public function user() { return $this->belongsTo(User::class); }
    public function budget() { return $this->belongsTo(Budget::class); }
}