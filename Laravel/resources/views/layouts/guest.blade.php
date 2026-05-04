<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'CookCash') }}</title>

    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600,700,800&display=swap" rel="stylesheet" />

    @vite(['resources/css/app.css', 'resources/js/app.js'])

    <style>
        input[type="password"]::-ms-reveal,
        input[type="password"]::-ms-clear {
            display: none;
        }

        @keyframes slideInRight {
            0% {
                opacity: 0;
                transform: translateX(50px);
            }

            100% {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes slideInLeft {
            0% {
                opacity: 0;
                transform: translateX(-50px);
            }

            100% {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes fadeIn {
            0% {
                opacity: 0;
            }

            100% {
                opacity: 1;
            }
        }

        .animate-login {
            animation: slideInRight 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        .animate-register {
            animation: slideInLeft 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        .animate-fade {
            animation: fadeIn 0.8s ease-out forwards;
        }
    </style>
</head>

<body class="font-sans antialiased bg-neutral-950 text-white overflow-hidden">

    <div class="min-h-screen flex flex-col lg:flex-row {{ request()->routeIs('register') ? 'lg:flex-row-reverse' : '' }}">

        <div class="relative hidden lg:flex flex-col justify-center items-center w-full lg:w-1/2 bg-neutral-950 overflow-hidden p-8 lg:p-12 {{ request()->routeIs('register') ? 'border-l' : 'border-r' }} border-neutral-800 animate-fade">
            
            <div class="absolute inset-0 overflow-hidden pointer-events-none">
                <div class="absolute -top-20 -left-20 w-96 h-96 bg-[#FF723A] rounded-full mix-blend-screen filter blur-[120px] opacity-20 animate-pulse"></div>
                <div class="absolute -bottom-32 -right-20 w-[30rem] h-[30rem] bg-orange-700 rounded-full mix-blend-screen filter blur-[150px] opacity-20"></div>
            </div>

            <div class="relative z-10 w-full max-w-lg bg-neutral-800/30 border border-neutral-700/50 backdrop-blur-xl rounded-[2rem] p-10 shadow-2xl shadow-black/50">
                
                <div class="text-5xl font-extrabold mb-6 tracking-tight drop-shadow-md">
                    <span class="text-white">Cook</span><span class="text-[#FF723A]">Cash</span>
                </div>

                <h2 class="text-3xl font-bold mb-5 text-transparent bg-clip-text bg-gradient-to-br from-white to-neutral-400 leading-tight">
                    Masak Hemat, Perut Kenyang, Kantong Tenang.
                </h2>

                <p class="text-neutral-400 text-lg mb-8 leading-relaxed">
                    Platform andalan anak kos! Temukan ratusan resep gampang, murah, dan anti-gagal yang pas banget sama sisa uang jajanmu akhir bulan.
                </p>

                <ul class="space-y-5">
                    <li class="flex items-center space-x-4 text-neutral-300 transform transition duration-300 hover:translate-x-2">
                        <div class="flex-shrink-0 w-8 h-8 rounded-full bg-[#FF723A]/10 flex items-center justify-center border border-[#FF723A]/30 shadow-[0_0_10px_rgba(255,114,58,0.2)]">
                            <svg class="w-5 h-5 text-[#FF723A]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"></path>
                            </svg>
                        </div>
                        <span class="font-medium text-base">Rekomendasi resep sesuai budget</span>
                    </li>
                    
                    <li class="flex items-center space-x-4 text-neutral-300 transform transition duration-300 hover:translate-x-2">
                        <div class="flex-shrink-0 w-8 h-8 rounded-full bg-[#FF723A]/10 flex items-center justify-center border border-[#FF723A]/30 shadow-[0_0_10px_rgba(255,114,58,0.2)]">
                            <svg class="w-5 h-5 text-[#FF723A]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"></path>
                            </svg>
                        </div>
                        <span class="font-medium text-base">Langkah masak praktis anti-ribet</span>
                    </li>

                    <li class="flex items-center space-x-4 text-neutral-300 transform transition duration-300 hover:translate-x-2">
                        <div class="flex-shrink-0 w-8 h-8 rounded-full bg-[#FF723A]/10 flex items-center justify-center border border-[#FF723A]/30 shadow-[0_0_10px_rgba(255,114,58,0.2)]">
                            <svg class="w-5 h-5 text-[#FF723A]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"></path>
                            </svg>
                        </div>
                        <span class="font-medium text-base">Simpan & share resep favorit kosan</span>
                    </li>
                </ul>
            </div>
        </div>

        <div class="w-full lg:w-1/2 flex flex-col items-center justify-center p-6 sm:p-12 relative {{ request()->routeIs('register') ? 'animate-register' : 'animate-login' }}">

            <div class="mb-8 text-center lg:hidden animate-fade">
                <h1 class="text-4xl font-extrabold tracking-tight text-white">
                    Cook<span class="text-[#FF723A]">Cash</span>
                </h1>
            </div>

            <div class="w-full sm:max-w-xl p-8 sm:p-12 bg-neutral-900 border border-neutral-800 shadow-2xl overflow-hidden rounded-[2.5rem]">
                {{ $slot }}
            </div>
        </div>

    </div>
</body>

</html>