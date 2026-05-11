<?php

return [

    'defaults' => [
        'guard' => 'web',
        'passwords' => 'admins', // <-- Ganti ke admins
    ],

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'admins', // <-- Ganti provider ke admins
        ],

        'api' => [
            'driver' => 'sanctum',
            'provider' => 'flutter_users',
        ],
    ],

    'providers' => [
        // Tambahkan provider admins yang mengarah ke model Admin
        'admins' => [
            'driver' => 'eloquent',
            'model' => App\Models\Admin::class, 
        ],

        'flutter_users' => [
            'driver' => 'eloquent',
            'model' => App\Models\User::class, 
        ],
    ],

    'passwords' => [
        'admins' => [ // <-- Ganti namanya jadi admins
            'provider' => 'admins',
            'table' => 'password_reset_tokens',
            'expire' => 5, 
            'throttle' => 60,
        ],
    ],

    'password_timeout' => 10800,

];