<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'CookCase') }}</title>

    <link rel="icon" type="image/svg+xml" href="{{ asset('logo.svg') }}">

    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600,700,800&display=swap" rel="stylesheet" />

    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<body class="font-sans antialiased text-white bg-neutral-900 overflow-hidden">

    <div x-data="{ sidebarOpen: true }" class="flex h-screen w-full relative">

        <aside class="flex flex-col bg-neutral-950 border-r border-neutral-800 transition-all duration-300 ease-in-out shrink-0 z-20"
               :class="sidebarOpen ? 'w-72' : 'w-20'">

            <div class="h-24 flex items-center border-b border-neutral-800/50 transition-all duration-300"
                 :class="sidebarOpen ? 'px-4 justify-start' : 'px-0 justify-center'">
                
                <div class="bg-neutral-900 text-[#FF723A] border border-neutral-800 rounded-xl flex items-center justify-center shadow-sm shrink-0 w-12 h-12 transition-all duration-300">
                    <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z"></path>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.879 16.121A3 3 0 1012.015 11L11 14H9c0 .768.293 1.536.879 2.121z"></path>
                    </svg>
                </div>
                
                <span x-show="sidebarOpen" class="text-2xl font-bold tracking-wide ml-3">
                    Cook<span class="text-[#FF723A]">Case</span>
                </span>
            </div>

            <nav class="flex-1 mt-6 space-y-2 overflow-y-auto overflow-x-hidden flex flex-col transition-all duration-300"
                 :class="sidebarOpen ? 'px-4' : 'px-0 items-center'">
                
                <a href="{{ route('dashboard') }}" 
                   class="flex items-center rounded-xl transition-all duration-200 bg-[#FF723A]/10 text-[#FF723A] border border-[#FF723A]/20 hover:bg-[#FF723A]/20"
                   :class="sidebarOpen ? 'w-full px-4 py-3 justify-start' : 'w-12 h-12 justify-center'">
                    
                    <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path>
                    </svg>
                    
                    <span x-show="sidebarOpen" class="ml-3 font-bold whitespace-nowrap">Dashboard</span>
                </a>

                <a href="{{ route('resep.index') }}" 
                   class="flex items-center rounded-xl transition-all duration-200 text-neutral-400 border border-transparent hover:text-white hover:bg-neutral-800"
                   :class="sidebarOpen ? 'w-full px-4 py-3 justify-start' : 'w-12 h-12 justify-center'">
                    
                    <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>
                    </svg>

                    <span x-show="sidebarOpen" class="ml-3 font-medium whitespace-nowrap">Manajemen Resep</span>
                </a>

                <a href="{{ route('bahan.index') }}" 
                   class="flex items-center rounded-xl transition-all duration-200 {{ request()->routeIs('bahan.*') ? 'bg-[#FF723A]/10 text-[#FF723A] border border-[#FF723A]/20 font-bold' : 'text-neutral-400 border border-transparent hover:text-white hover:bg-neutral-800 font-medium' }}"
                   :class="sidebarOpen ? 'w-full px-4 py-3 justify-start' : 'w-12 h-12 justify-center'">
                    
                    <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"></path>
                    </svg>

                    <span x-show="sidebarOpen" class="ml-3 whitespace-nowrap">Harga Bahan</span>
                </a>
            </nav>

            <div class="mt-auto mb-6 flex flex-col transition-all duration-300"
                 :class="sidebarOpen ? 'px-4' : 'px-0 items-center'">
                <form method="POST" action="{{ route('logout') }}" :class="sidebarOpen ? 'w-full' : 'w-12'">
                    @csrf
                    <button type="submit" 
                            class="flex items-center rounded-xl transition-all duration-200 bg-neutral-800 hover:bg-neutral-700 border border-neutral-700 text-neutral-300 hover:text-white"
                            :class="sidebarOpen ? 'w-full px-4 py-3 justify-start' : 'w-12 h-12 justify-center'">
                        
                        <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                        </svg>
                        
                        <span x-show="sidebarOpen" class="ml-3 text-sm font-bold whitespace-nowrap">Log Out</span>
                    </button>
                </form>
            </div>
            
        </aside>

        <div class="flex-1 flex flex-col min-w-0 overflow-hidden">

            @if (isset($header))
            <header class="pt-8 px-10 pb-4 flex justify-between items-center bg-neutral-900 border-b border-neutral-800/50">
                <div class="flex items-center gap-5">
                    
                    <button @click="sidebarOpen = !sidebarOpen" class="p-2.5 bg-neutral-800 text-neutral-400 rounded-xl shadow-sm border border-neutral-700 hover:text-white hover:bg-[#FF723A] hover:border-[#FF723A] transition-all focus:outline-none shrink-0">
                        <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h7"></path>
                        </svg>
                    </button>

                    <div class="text-2xl font-bold text-white truncate">
                        {{ $header }}
                    </div>
                </div>

                <a href="{{ route('profile.edit') }}" class="flex items-center gap-4 hover:bg-neutral-800 p-2 rounded-2xl transition-colors border border-transparent hover:border-neutral-700 shrink-0">
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