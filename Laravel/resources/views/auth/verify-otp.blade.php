<x-guest-layout>
    <div class="mb-4 text-sm text-gray-600 dark:text-gray-400 text-center">
        {{ __('Silakan masukkan 6 digit kode OTP yang kami kirimkan ke email:') }} <br>
        <span class="font-bold text-indigo-600">{{ $email }}</span>
    </div>

    @if (session('status'))
        <div class="mb-4 font-medium text-sm text-green-600">
            {{ session('status') }}
        </div>
    @endif

    <form method="POST" action="{{ route('password.otp.verify') }}">
        @csrf

        <input type="hidden" name="email" value="{{ $email }}">

        <div class="mt-4">
            <x-input-label for="otp" :value="__('Kode OTP')" class="text-center mb-2" />
            
            <input id="otp" 
                   type="text" 
                   name="otp" 
                   maxlength="6"
                   required 
                   autofocus 
                   inputmode="numeric"
                   autocomplete="one-time-code"
                   placeholder="000000"
                   class="block mt-1 w-full border-gray-300 dark:border-gray-700 dark:bg-gray-900 dark:text-white focus:border-indigo-500 dark:focus:border-indigo-600 focus:ring-indigo-500 dark:focus:ring-indigo-600 rounded-md shadow-sm text-center text-4xl font-extrabold tracking-[0.5em] text-gray-900"
            >

            <x-input-error :messages="$errors->get('otp')" class="mt-2 text-center" />
        </div>

        <div class="flex flex-col items-center justify-center mt-6">
            <x-primary-button class="w-full justify-center py-3">
                {{ __('Verifikasi OTP Sekarang') }}
            </x-primary-button>

            <div class="mt-4">
                <a href="{{ route('password.request') }}" class="text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 underline">
                    {{ __('Ganti Email?') }}
                </a>
            </div>
        </div>
    </form>

    <div class="mt-6 text-center text-xs text-gray-500">
        {{ __('Kode ini akan kedaluwarsa dalam 5 menit.') }}
    </div>
</x-guest-layout>