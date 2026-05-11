<x-guest-layout>
    <div class="text-center mb-10">
        <h1 class="text-3xl font-extrabold text-white tracking-tight">Welcome Back</h1>
        <p class="mt-3 text-lg text-neutral-400">Sign in with your email and password to continue</p>
    </div>

    <x-auth-session-status class="mb-6" :status="session('status')" />

    <form method="POST" action="{{ route('login') }}" class="space-y-6" x-data="{ loading: false, showPassword: false }" @submit="loading = true">
        @csrf

        <div class="space-y-2">
            <x-input-label for="email" :value="__('Email Address')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="email" 
                    class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 placeholder-neutral-500 transition-all duration-200" 
                    type="email" 
                    name="email" 
                    :value="old('email')" 
                    required 
                    autofocus 
                    placeholder="name@example.com" />
            </div>
            <x-input-error :messages="$errors->get('email')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <div class="flex justify-between items-center ml-1">
                <x-input-label for="password" :value="__('Password')" class="text-neutral-300 font-semibold" />
                @if (Route::has('password.request'))
                    <a class="text-sm font-bold text-[#FF723A] hover:text-[#ff8c5a] transition ease-in-out duration-150" href="{{ route('password.request') }}">
                        Forgot Password?
                    </a>
                @endif
            </div>
            <div class="relative">
                <input id="password" 
                    :type="showPassword ? 'text' : 'password'" 
                    class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 placeholder-neutral-500 transition-all duration-200" 
                    name="password" 
                    required 
                    autocomplete="current-password" 
                    placeholder="••••••••" />
                
                <button type="button" @click="showPassword = !showPassword" class="absolute right-6 top-1/2 -translate-y-1/2 text-neutral-500 hover:text-white transition-colors">
                    <svg x-show="!showPassword" xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                    <svg x-show="showPassword" xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" style="display: none;">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.542-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18" />
                    </svg>
                </button>
            </div>
            <x-input-error :messages="$errors->get('password')" class="mt-2 ml-5" />
        </div>

        <div class="block ml-1">
            <label for="remember_me" class="inline-flex items-center">
                <input id="remember_me" type="checkbox" class="rounded border-neutral-700 bg-neutral-800 text-[#FF723A] shadow-sm focus:ring-[#FF723A] focus:ring-offset-neutral-900" name="remember">
                <span class="ml-2 text-sm text-neutral-400">{{ __('Remember this device') }}</span>
            </label>
        </div>

        <div>
            <button type="submit" :disabled="loading" 
                    class="w-full bg-[#FF723A] hover:bg-[#ff8c5a] text-white font-bold py-4 rounded-full text-lg transition-all flex justify-center items-center gap-3 shadow-lg shadow-[#FF723A]/20 disabled:opacity-50 disabled:cursor-not-allowed">
                <template x-if="loading">
                    <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                </template>
                <span x-text="loading ? 'AUTHENTICATING...' : 'CONTINUE'"></span>
            </button>
        </div>

        {{-- Menggunakan Admin::count() karena kita menggunakan model Admin --}}
        @if(\App\Models\Admin::count() == 0)
            <div class="mt-12 text-center text-sm text-neutral-400">
                Don't have an account? 
                <a href="{{ route('register') }}" class="font-bold text-[#FF723A] hover:text-[#ff8c5a] hover:underline transition">
                    Sign Up
                </a>
            </div>
        @else
            <div class="mt-12 text-center text-xs text-neutral-500 italic">
                Sistem dikunci khusus untuk Admin terdaftar.
            </div>
        @endif
    </form>
</x-guest-layout>