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

        <div class="hidden lg:flex lg:w-1/2 bg-neutral-900 p-12 flex-col justify-center relative overflow-hidden {{ request()->routeIs('register') ? 'border-l' : 'border-r' }} border-neutral-800 animate-fade">

            <div class="absolute top-0 left-0 w-full h-full opacity-20 bg-[radial-gradient(ellipse_at_top_left,_var(--tw-gradient-stops))] from-[#FF723A] via-neutral-900 to-neutral-900"></div>

            <div class="relative z-10 max-w-lg mx-auto">
                <h1 class="text-6xl font-extrabold tracking-tight text-white mb-6">
                    Cook<span class="text-[#FF723A]">Cash</span>
                </h1>

                <h2 class="text-3xl font-bold text-neutral-200 mb-6">
                    Kelola Keuangan Bisnis Kulinermu dengan Mudah.
                </h2>

                <p class="text-lg text-neutral-400 leading-relaxed mb-10">
                    Fokus ciptakan rasa terbaik di dapurmu, biarkan CookCash yang mengurus catatan keuangannya. Platform terbaik untuk memantau pemasukan, pengeluaran, dan profit harianmu.
                </p>

                <ul class="space-y-4 text-neutral-300">
                    <li class="flex items-center">
                        <div class="flex-shrink-0 w-8 h-8 rounded-full bg-[#FF723A]/20 flex items-center justify-center mr-4">
                            <svg class="w-5 h-5 text-[#FF723A]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                        </div>
                        Pencatatan transaksi real-time
                    </li>
                    <li class="flex items-center">
                        <div class="flex-shrink-0 w-8 h-8 rounded-full bg-[#FF723A]/20 flex items-center justify-center mr-4">
                            <svg class="w-5 h-5 text-[#FF723A]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                        </div>
                        Laporan keuangan otomatis
                    </li>
                    <li class="flex items-center">
                        <div class="flex-shrink-0 w-8 h-8 rounded-full bg-[#FF723A]/20 flex items-center justify-center mr-4">
                            <svg class="w-5 h-5 text-[#FF723A]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                        </div>
                        Aman, cepat, dan responsif
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