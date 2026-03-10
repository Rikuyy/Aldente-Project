<x-guest-layout>
    <div class="mb-6 text-sm text-gray-600 leading-relaxed">
        Lupa password Anda? Tidak masalah. Cukup beritahu kami alamat email Anda dan kami akan mengirimkan tautan reset password agar Anda dapat membuat password baru.
    </div>

    <x-auth-session-status class="mb-6" :status="session('status')" />

    <form method="POST" action="{{ route('password.email') }}">
        @csrf

        <div>
            <x-input-label for="email" :value="__('Email')" />
            <x-text-input id="email" class="block mt-1 w-full" type="email" name="email" :value="old('email')" required autofocus />
            <x-input-error :messages="$errors->get('email')" class="mt-2" />
        </div>

        <div class="mt-6">
            <x-primary-button class="w-full">
                {{ __('EMAIL PASSWORD RESET LINK') }}
            </x-primary-button>
        </div>

        <div class="mt-6 text-center text-sm text-gray-700">
            Tiba-tiba ingat passwordnya? 
            <a href="{{ route('login') }}" class="font-bold text-[#E91E63] hover:text-[#c2185b] hover:underline transition ease-in-out duration-150">
                Masuk di sini
            </a>
        </div>
    </form>
</x-guest-layout>