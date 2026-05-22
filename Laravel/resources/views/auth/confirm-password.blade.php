<x-guest-layout>
    <div class="text-center mb-10">
        <h1 class="text-3xl font-extrabold text-white tracking-tight">Area Keamanan</h1>
        <p class="mt-3 text-neutral-400">
            Demi keamanan, silakan konfirmasi password Anda sebelum melanjutkan ke halaman ini.
        </p>
    </div>

    <form method="POST" action="{{ route('password.confirm') }}" class="space-y-6" x-data="{ loading: false }" @submit="loading = true">
        @csrf

        <div class="space-y-2">
            <x-input-label for="password" :value="__('Password')" class="text-neutral-300 font-semibold ml-1" />
            <input id="password" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg focus:border-[#FF723A] focus:ring-0 placeholder-neutral-600 transition-all" 
                   type="password" name="password" required autocomplete="current-password" placeholder="••••••••" />
            <x-input-error :messages="$errors->get('password')" class="mt-2 ml-5" />
        </div>

        <button type="submit" :disabled="loading" class="w-full py-4 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-full text-lg font-bold transition-all flex justify-center items-center gap-3 shadow-lg">
            <template x-if="loading">
                <i class="fas fa-spinner animate-spin"></i>
            </template>
            <span x-text="loading ? 'MEMVERIFIKASI...' : 'KONFIRMASI PASSWORD'"></span>
        </button>
    </form>
</x-guest-layout>