<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'CookMate') }}</title>

        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,500,600,700,800&display=swap" rel="stylesheet" />

        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
    <body class="font-sans antialiased bg-neutral-950 text-white">
        <div class="min-h-screen flex flex-col items-center justify-center p-6">
            
            <div class="mb-10 text-center">
                <h1 class="text-4xl font-extrabold tracking-tight text-white">
                    Cook<span class="text-[#FF723A]">Case</span>
                </h1>
            </div>

            <div class="w-full sm:max-w-xl p-12 bg-neutral-900 border border-neutral-800 shadow-2xl overflow-hidden rounded-[2.5rem]">
                {{ $slot }}
            </div>
        </div>
    </body>
</html>