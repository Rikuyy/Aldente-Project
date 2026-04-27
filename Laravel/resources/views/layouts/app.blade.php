<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'CookCash') }}</title>

    <link rel="icon" type="image/svg+xml" href="{{ asset('logo.svg') }}">

    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600,700,800&display=swap" rel="stylesheet" />

    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<body class="font-sans antialiased text-white bg-neutral-900 overflow-hidden">

    <div class="flex h-screen w-full relative">

        <aside class="flex flex-col bg-neutral-950 border-r border-neutral-800 shrink-0 z-20 w-72">

            <div class="h-24 flex items-center border-b border-neutral-800/50 px-4 justify-start">
                <div class="bg-neutral-900 text-[#FF723A] border border-neutral-800 rounded-xl flex items-center justify-center shadow-sm shrink-0 w-12 h-12">
                    <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z"></path>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.879 16.121A3 3 0 1012.015 11L11 14H9c0 .768.293 1.536.879 2.121z"></path>
                    </svg>
                </div>
                <span class="text-2xl font-bold tracking-wide ml-3">
                    Cook<span class="text-[#FF723A]">Cash</span>
                </span>
            </div>

            <nav class="flex-1 mt-6 space-y-2 overflow-y-auto overflow-x-hidden flex flex-col px-4">
                
                <a href="{{ route('dashboard') }}" wire:navigate
                   class="flex items-center rounded-xl transition-colors duration-200 {{ request()->routeIs('dashboard') ? 'bg-[#FF723A]/10 text-[#FF723A] border border-[#FF723A]/20 font-bold' : 'text-neutral-400 border border-transparent hover:text-white hover:bg-neutral-800 font-medium' }} w-full px-4 py-3 justify-start">
                    <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path>
                    </svg>
                    <span class="ml-3 whitespace-nowrap">Dashboard</span>
                </a>

                <a href="{{ route('resep.index') }}" wire:navigate
                   class="flex items-center rounded-xl transition-colors duration-200 {{ request()->routeIs('resep.*') ? 'bg-[#FF723A]/10 text-[#FF723A] border border-[#FF723A]/20 font-bold' : 'text-neutral-400 border border-transparent hover:text-white hover:bg-neutral-800 font-medium' }} w-full px-4 py-3 justify-start">
                    <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>
                    </svg>
                    <span class="ml-3 whitespace-nowrap">Manajemen Resep</span>
                </a>

                <a href="{{ url('/testing') }}" wire:navigate
                   class="flex items-center rounded-xl transition-colors duration-200 {{ request()->is('testing') ? 'bg-[#FF723A]/10 text-[#FF723A] border border-[#FF723A]/20 font-bold' : 'text-neutral-400 border border-transparent hover:text-white hover:bg-neutral-800 font-medium' }} w-full px-4 py-3 justify-start">
                    <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z"></path>
                    </svg>
                    <span class="ml-3 whitespace-nowrap">Evaluasi Algoritma</span>
                </a>

            </nav>

            <div class="mt-auto mb-6 flex flex-col px-4">
                <form method="POST" action="{{ route('logout') }}" class="w-full">
                    @csrf
                    <button type="submit" 
                            class="flex items-center rounded-xl transition-colors duration-200 bg-neutral-800 hover:bg-neutral-700 border border-neutral-700 text-neutral-300 hover:text-white w-full px-4 py-3 justify-start">
                        <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                        </svg>
                        <span class="ml-3 text-sm font-bold whitespace-nowrap">Log Out</span>
                    </button>
                </form>
            </div>
            
        </aside>

        <div class="flex-1 flex flex-col min-w-0 overflow-hidden">

            @if (isset($header))
            <header class="pt-8 px-10 pb-4 flex justify-between items-center bg-neutral-900 border-b border-neutral-800/50">
                <div class="flex items-center gap-5">
                    <div class="text-2xl font-bold text-white truncate">
                        {{ $header }}
                    </div>
                </div>

                <a href="{{ route('profile.edit') }}" wire:navigate class="flex items-center gap-4 hover:bg-neutral-800 p-2 rounded-2xl transition-colors border border-transparent hover:border-neutral-700 shrink-0">
                    <div class="text-right hidden md:block">
                        <p class="text-sm font-bold text-white">{{ Auth::user()->name }}</p>
                        <p class="text-xs text-neutral-400 font-medium">{{ Auth::user()->email }}</p>
                    </div>
                    <div class="w-10 h-10 rounded-full bg-[#FF723A] flex items-center justify-center text-white font-bold shrink-0">
                        {{ substr(Auth::user()->name, 0, 2) }}
                    </div>
                </a>
            </header>
            @endif

            <main class="flex-1 overflow-x-hidden overflow-y-auto p-10 pt-6 bg-neutral-900">
                {{ $slot }}
            </main>

        </div>

    </div>
</body>

</html>