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
                <input id="name" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 transition-all" type="text" name="name" :value="old('name')" required autofocus />
            </div>
            <x-input-error :messages="$errors->get('name')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="email" :value="__('Email Address')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="email" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 transition-all" type="email" name="email" :value="old('email')" required />
            </div>
            <x-input-error :messages="$errors->get('email')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="password" :value="__('Password')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="password" :type="showPw ? 'text' : 'password'" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 transition-all" name="password" required autocomplete="new-password" />
                <button type="button" @click="showPw = !showPw" class="absolute right-6 top-1/2 -translate-y-1/2 text-neutral-500">
                    <i class="fas" :class="showPw ? 'fa-eye-slash' : 'fa-eye'"></i>
                </button>
            </div>
            <x-input-error :messages="$errors->get('password')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="password_confirmation" :value="__('Konfirmasi Password')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="password_confirmation" :type="showPw ? 'text' : 'password'" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 transition-all" name="password_confirmation" required />
            </div>
        </div>

        <div class="mt-8">
            <button type="submit" :disabled="loading" 
                    class="w-full py-4 px-6 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-full text-lg font-bold tracking-wider transition-all uppercase flex justify-center items-center gap-3">
                <template x-if="loading">
                    <i class="fas fa-spinner animate-spin"></i>
                </template>
                <span x-text="loading ? 'Processing...' : 'SELESAIKAN SETUP'"></span>
            </button>
        </div>

        <div class="mt-6 text-center text-sm text-neutral-500 italic">
            *Halaman ini hanya muncul untuk konfigurasi sistem pertama kali.
        </div>
    </form>
</x-guest-layout>