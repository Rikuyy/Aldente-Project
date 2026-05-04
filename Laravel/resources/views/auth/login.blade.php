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
                <input id="email" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 placeholder-neutral-500 transition-all duration-200" type="email" name="email" :value="old('email')" required autofocus placeholder="name@example.com" />
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
                <input id="password" :type="showPassword ? 'text' : 'password'" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-[#FF723A] focus:ring-0 placeholder-neutral-500 transition-all duration-200" name="password" required autocomplete="current-password" placeholder="••••••••" />
                <button type="button" @click="showPassword = !showPassword" class="absolute right-6 top-1/2 -translate-y-1/2 text-neutral-500 hover:text-white transition-colors">
                    <i class="fas" :class="showPassword ? 'fa-eye-slash' : 'fa-eye'"></i>
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
                    class="w-full bg-[#FF723A] hover:bg-[#ff8c5a] text-white font-bold py-4 rounded-full text-lg transition-all flex justify-center items-center gap-3 shadow-lg shadow-[#FF723A]/20">
                <template x-if="loading">
                    <i class="fas fa-spinner animate-spin"></i>
                </template>
                <span x-text="loading ? 'AUTHENTICATING...' : 'CONTINUE'"></span>
            </button>
        </div>

        @if(\App\Models\User::count() == 0)
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