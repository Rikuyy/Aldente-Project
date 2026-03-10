<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Laravel') }}</title>

    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<body class="font-sans text-gray-900 antialiased">
    <div class="min-h-screen flex flex-col sm:justify-center items-center pt-6 sm:pt-0 bg-gray-50">
        
        <div>
            <a href="/" class="flex items-center gap-2 text-3xl font-extrabold text-[#E91E63] hover:opacity-80 transition" style="text-decoration: none;">
                <div class="bg-[#E91E63] text-white p-2 rounded-2xl w-12 h-12 flex items-center justify-center shadow-lg">
                    👨‍🍳
                </div>
                <span>CookMate</span>
            </a>
        </div>

        <div class="w-full sm:max-w-md mt-6 px-8 py-10 bg-white shadow-xl overflow-hidden sm:rounded-3xl border border-gray-100">
            {{ $slot }}
        </div>
        
    </div>
</body>

</html>