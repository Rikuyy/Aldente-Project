<?php

return [

    'defaults' => [
        'guard' => 'web',
        'passwords' => 'users',
    ],

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],

        'api' => [
            'driver' => 'sanctum',
            'provider' => 'flutter_users', // Flutter pakai provider khusus
        ],
    ],

    'providers' => [
        'users' => [
            'driver' => 'eloquent',
            'model' => App\Models\User::class, // Admin (Koleksi: admin)
        ],

        'flutter_users' => [
            'driver' => 'eloquent',
            'model' => App\Models\UserFlutter::class, // User (Koleksi: users)
        ],
    ],

'passwords' => [
    'users' => [
        'provider' => 'users',
        'table' => 'password_reset_tokens',
        'expire' => 5, // <--- Token cuma berlaku 5 menit!
        'throttle' => 60,
    ],
],

    'password_timeout' => 10800,

];