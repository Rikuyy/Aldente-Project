<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Budget extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'total_budget_harian', 'sisa_budget', 'terpakai', 'tanggal', 'status'];
    protected $casts = ['tanggal' => 'date', 'total_budget_harian' => 'decimal:2', 'sisa_budget' => 'decimal:2', 'terpakai' => 'decimal:2'];

    public function user() { return $this->belongsTo(User::class); }
    public function expenses() { return $this->hasMany(Expense::class); }
}