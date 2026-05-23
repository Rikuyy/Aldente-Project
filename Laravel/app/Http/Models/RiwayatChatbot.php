<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class RiwayatChatbot extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'riwayat_chatbot';
    protected $primaryKey = 'Id_Riwayat';

    protected $fillable = [
        'Id_User', 
        'Role', 
        'Message'
    ];
}