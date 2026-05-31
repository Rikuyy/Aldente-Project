<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class UserResep extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'user_resep';
    protected $table = 'user_resep';

    protected $fillable = [
        'Id_User',
        'resep_queue',
        'queue_index',
        'queue_built_at',
    ];

    protected $casts = [
        'resep_queue' => 'array',
        'queue_index' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'Id_User', 'Id_User');
    }
}