<x-guest-layout>
    <div class="text-center mb-8">
        <h1 class="text-3xl font-extrabold text-white tracking-tight">Lupa Password?</h1>
        <p class="mt-3 text-sm text-neutral-400 leading-relaxed px-4">
            Masukkan email Anda, kami akan kirimkan link untuk buat password baru.
        </p>
    </div>

    <x-auth-session-status class="mb-6 text-green-400 font-bold bg-green-900/20 p-4 rounded-xl border border-green-800" :status="session('status')" />

    <form method="POST" action="{{ route('password.email') }}" class="space-y-6" x-data="{ loading: false }" @submit="loading = true">
        @csrf

        <div class="space-y-2">
            <x-input-label for="email" :value="__('Email')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="email" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 placeholder-neutral-500 transition-all duration-200" type="email" name="email" :value="old('email')" required autofocus placeholder="Masukkan email terdaftar" />
            </div>
            <x-input-error :messages="$errors->get('email')" class="mt-2 ml-5" />
        </div>

        <div>
            <button type="submit" :disabled="loading" class="w-full py-4 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-full text-lg font-bold transition-all flex justify-center items-center gap-3 shadow-lg shadow-[#FF723A]/20">
                <template x-if="loading">
                    <i class="fas fa-spinner animate-spin"></i>
                </template>
                <span x-text="loading ? 'MENGIRIM...' : 'KIRIM LINK RESET'"></span>
            </button>
        </div>

        <div class="text-center">
            <a href="{{ route('login') }}" class="text-sm text-neutral-500 hover:text-white transition">Kembali ke Login</a>
        </div>
    </form>
</x-guest-layout>