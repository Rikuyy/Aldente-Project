<x-guest-layout>
    <div class="text-center mb-10">
        <div class="mb-4 inline-flex items-center gap-2 bg-[#FF723A]/10 border border-[#FF723A]/30 px-3 py-1 rounded-full text-[#FF723A] text-xs font-bold uppercase tracking-widest">
            <span class="relative flex h-2 w-2">
                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#FF723A] opacity-75"></span>
                <span class="relative inline-flex rounded-full h-2 w-2 bg-[#FF723A]"></span>
            </span>
            First-Time Setup
        </div>
        
        <h1 class="text-3xl font-extrabold text-white tracking-tight">Buat Akun Admin</h1>
        <p class="mt-3 text-lg text-neutral-400">Silakan buat akun super admin utama Anda</p>
    </div>

    <form method="POST" action="{{ route('register') }}" class="space-y-6" x-data="{ loading: false, showPw: false }" @submit="loading = true">
        @csrf

        <div class="space-y-2">
            <x-input-label for="name" :value="__('Nama Lengkap Admin')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="name" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 transition-all" type="text" name="name" value="{{ old('name') }}" required autofocus />
            </div>
            <x-input-error :messages="$errors->get('name')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="email" :value="__('Email Address')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="email" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 transition-all" type="email" name="email" value="{{ old('email') }}" required />
            </div>
            <x-input-error :messages="$errors->get('email')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="password" :value="__('Password')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="password" :type="showPw ? 'text' : 'password'" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 transition-all pr-16" name="password" required autocomplete="new-password" />
                
                <button type="button" @click="showPw = !showPw" class="absolute right-6 top-1/2 -translate-y-1/2 text-neutral-400 hover:text-white focus:outline-none">
                    <svg x-show="!showPw" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                    </svg>
                    <svg x-show="showPw" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6" x-cloak>
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                    </svg>
                </button>
            </div>
            <x-input-error :messages="$errors->get('password')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="password_confirmation" :value="__('Konfirmasi Password')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="password_confirmation" :type="showPw ? 'text' : 'password'" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 transition-all pr-16" name="password_confirmation" required />
                
                <button type="button" @click="showPw = !showPw" class="absolute right-6 top-1/2 -translate-y-1/2 text-neutral-400 hover:text-white focus:outline-none">
                    <svg x-show="!showPw" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                    </svg>
                    <svg x-show="showPw" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6" x-cloak>
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                    </svg>
                </button>
            </div>
        </div>

        <div class="mt-8">
            <button type="submit" :disabled="loading" 
                    class="w-full py-4 px-6 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-full text-lg font-bold tracking-wider transition-all uppercase flex justify-center items-center gap-3">
                <template x-if="loading">
                    <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                </template>
                <span x-text="loading ? 'Processing...' : 'SELESAIKAN SETUP'"></span>
            </button>
        </div>

        <div class="mt-6 text-center text-sm text-neutral-500 italic">
            *Halaman ini hanya muncul untuk konfigurasi sistem pertama kali.
        </div>
    </form>
</x-guest-layout>