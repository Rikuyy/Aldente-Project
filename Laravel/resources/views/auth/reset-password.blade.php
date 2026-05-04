<x-guest-layout>
    <div class="text-center mb-10">
        <h1 class="text-3xl font-extrabold text-white tracking-tight">Buat Password Baru</h1>
        <p class="mt-3 text-sm text-neutral-400">Silakan masukkan password baru untuk akun Anda.</p>
    </div>

    <form method="POST" action="{{ route('password.store') }}" class="space-y-6" x-data="{ loading: false, showPw: false }" @submit="loading = true">
        @csrf

        <input type="hidden" name="token" value="{{ $request->route('token') }}">

        <div class="space-y-2">
            <x-input-label for="email" :value="__('Email')" class="text-neutral-300 font-semibold ml-1" />
            <input id="email" class="block w-full px-6 py-4 bg-neutral-900 border border-neutral-800 text-neutral-500 rounded-full text-lg cursor-not-allowed" type="email" name="email" value="{{ old('email', $request->email) }}" required readonly />
            <x-input-error :messages="$errors->get('email')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="password" :value="__('Password Baru')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="password" :type="showPw ? 'text' : 'password'" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg focus:border-[#FF723A] focus:ring-0 transition-all" name="password" required autocomplete="new-password" placeholder="••••••••" />
                <button type="button" @click="showPw = !showPw" class="absolute right-6 top-1/2 -translate-y-1/2 text-neutral-500">
                    <i class="fas" :class="showPw ? 'fa-eye-slash' : 'fa-eye'"></i>
                </button>
            </div>
            <x-input-error :messages="$errors->get('password')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="password_confirmation" :value="__('Ulangi Password Baru')" class="text-neutral-300 font-semibold ml-1" />
            <input id="password_confirmation" :type="showPw ? 'text' : 'password'" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg focus:border-[#FF723A] focus:ring-0 transition-all" name="password_confirmation" required placeholder="••••••••" />
        </div>

        <div class="pt-4">
            <button type="submit" :disabled="loading" 
                    class="w-full py-4 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-full text-lg font-bold transition-all flex justify-center items-center gap-3 shadow-lg">
                <template x-if="loading">
                    <i class="fas fa-spinner animate-spin"></i>
                </template>
                <span x-text="loading ? 'MENYIMPAN...' : 'RESET PASSWORD SEKARANG'"></span>
            </button>
        </div>
    </form>
</x-guest-layout>