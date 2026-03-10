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
    <body class="font-sans antialiased text-gray-900 bg-[#f8f9fa] overflow-hidden">
        
        <div x-data="{ sidebarOpen: true }" class="flex h-screen w-full">

            <aside :class="sidebarOpen ? 'w-72' : 'w-24'" class="bg-[#E91E63] text-white flex flex-col transition-all duration-300 rounded-tr-3xl rounded-br-3xl shadow-xl z-20 overflow-hidden">
                
                <div class="p-6 flex items-center gap-3" :class="sidebarOpen ? 'justify-start' : 'justify-center px-0'">
                    <div class="bg-white text-[#E91E63] p-2 rounded-xl w-10 h-10 flex items-center justify-center text-xl shadow-md shrink-0">
                        👨‍🍳
                    </div>
                    <span x-show="sidebarOpen" x-transition.opacity class="text-2xl font-extrabold tracking-wide whitespace-nowrap">CookMate</span>
                </div>

                <nav class="flex-1 px-4 mt-6 space-y-2 overflow-y-auto">
                    <a href="{{ route('dashboard') }}" class="flex items-center gap-4 py-3 bg-[#f8f9fa] text-[#E91E63] rounded-2xl font-bold shadow-sm transition-all" :class="sidebarOpen ? 'px-4 justify-start' : 'px-0 justify-center'">
                        <svg class="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path></svg>
                        <span x-show="sidebarOpen" class="whitespace-nowrap">Dashboard</span>
                    </a>
                </nav>

                <div class="p-6" :class="sidebarOpen ? '' : 'px-4'">
                    <form method="POST" action="{{ route('logout') }}">
                        @csrf
                        <button type="submit" class="w-full py-3 bg-pink-700 hover:bg-pink-800 rounded-xl text-sm font-bold transition flex items-center justify-center gap-2" :class="sidebarOpen ? 'px-4' : 'px-0'">
                            <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
                            <span x-show="sidebarOpen" class="whitespace-nowrap">Log Out</span>
                        </button>
                    </form>
                </div>
            </aside>


            <div class="flex-1 flex flex-col overflow-hidden">
                
                @if (isset($header))
                    <header class="bg-transparent pt-8 px-10 pb-4 flex justify-between items-center">
                        <div class="flex items-center gap-4">
                            <button @click="sidebarOpen = !sidebarOpen" class="p-2 bg-white text-gray-600 rounded-xl shadow-sm border border-gray-100 hover:text-[#E91E63] hover:bg-pink-50 transition focus:outline-none">
                                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h7"></path></svg>
                            </button>
                            
                            <div class="text-2xl font-bold text-gray-800">
                                {{ $header }}
                            </div>
                        </div>
                        
                        <a href="{{ route('profile.edit') }}" class="flex items-center gap-4 hover:bg-white hover:shadow-sm p-2 rounded-2xl transition cursor-pointer">
                            <div class="text-right hidden md:block">
                                <p class="text-xs text-gray-500 font-semibold">Good Morning</p>
                                <p class="text-sm font-bold text-gray-800">{{ Auth::user()->name }}</p>
                            </div>
                            <div class="w-10 h-10 rounded-full bg-gray-300 border-2 border-white shadow-sm overflow-hidden shrink-0">
                                <img src="https://ui-avatars.com/api/?name={{ urlencode(Auth::user()->name) }}&background=E91E63&color=fff" alt="Avatar">
                            </div>
                        </a>
                    </header>
                @endif

                <main class="flex-1 overflow-x-hidden overflow-y-auto p-10 pt-4">
                    {{ $slot }}
                </main>

            </div>

        </div>
    </body>
</html>