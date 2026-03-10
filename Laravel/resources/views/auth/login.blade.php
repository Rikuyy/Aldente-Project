<x-guest-layout>
    <!-- Session Status -->
    <x-auth-session-status class="mb-4" :status="session('status')" />

    <form method="POST" action="{{ route('login') }}">
        @csrf

        <!-- Email Address -->
        <div>
            <x-input-label for="email" :value="__('Email')" />
            <x-text-input id="email" class="block mt-1 w-full" type="email" name="email" :value="old('email')" required autofocus autocomplete="username" />
            <x-input-error :messages="$errors->get('email')" class="mt-2" />
        </div>

        <!-- Password -->
        <div class="mt-4">
            <x-input-label for="password" :value="__('Password')" />

            <x-text-input id="password" class="block mt-1 w-full" type="password" name="password" required autocomplete="current-password" />

            <x-input-error :messages="$errors->get('password')" class="mt-2" />
        </div>

        <!-- Remember Me -->
        <div class="flex items-center justify-between mt-4">
            <label for="remember_me" class="inline-flex items-center cursor-pointer">
                <input id="remember_me" type="checkbox" class="rounded border-gray-300 text-[#E91E63] shadow-sm focus:ring-[#E91E63] focus:ring-offset-0 transition duration-150 ease-in-out cursor-pointer" name="remember">
                <span class="ms-2 text-sm text-gray-700">{{ __('Remember me') }}</span>
            </label>

            @if (Route::has('password.request'))
            <a class="text-sm text-gray-600 hover:text-[#E91E63] hover:underline transition ease-in-out duration-150" href="{{ route('password.request') }}">
                {{ __('Forgot your password?') }}
            </a>
            @endif
        </div>

        <div class="mt-6">
            <x-primary-button class="w-full">
                {{ __('LOG IN') }}
            </x-primary-button>
        </div>

        <div class="mt-6 text-center text-sm text-gray-700">
            Belum punya akun?
            <a href="{{ route('register') }}" class="font-bold text-[#E91E63] hover:text-[#c2185b] hover:underline transition ease-in-out duration-150">
                Daftar di sini
            </a>
        </div>
    </form>
</x-guest-layout>