<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    'paths' => ['api/*', 'auth/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => ['*'], // Mengizinkan semua origin termasuk Flutter Web kamu

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'], // Mengizinkan semua header termasuk 'Authorization' dari JWT

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false, // Set false jika allowed_origins menggunakan '*' agar browser tidak error

];