<x-guest-layout>
    <div class="text-center mb-8">
        <p class="text-sm text-neutral-400 leading-relaxed px-4">
            {{ __('Lupa password Anda? Tidak masalah. Cukup beritahu kami alamat email Anda dan kami akan mengirimkan tautan reset password agar Anda dapat membuat password baru.') }}
        </p>
    </div>

    <x-auth-session-status class="mb-6" :status="session('status')" />

    <form method="POST" action="{{ route('password.email') }}" class="space-y-6">
        @csrf

        <div class="space-y-2">
            <x-input-label for="email" :value="__('Email')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="email" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-neutral-600 focus:ring-0 placeholder-neutral-500 focus:placeholder-transparent transition-all duration-200" type="email" name="email" :value="old('email')" required autofocus placeholder="Enter your email" />
                
                <div class="absolute right-6 top-1/2 -translate-y-1/2 text-neutral-500 pointer-events-none">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg>
                </div>
            </div>
            <x-input-error :messages="$errors->get('email')" class="mt-2 ml-5" />
        </div>

        <div>
            <button type="submit" class="w-full flex justify-center py-4 px-4 border border-transparent rounded-full shadow-sm text-base font-bold text-white bg-[#FF723A] hover:bg-[#ff8c5a] focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-neutral-900 focus:ring-[#FF723A] transition ease-in-out duration-150 uppercase tracking-wide">
                {{ __('Email Password Reset Link') }}
            </button>
        </div>

        <div class="mt-8 text-center text-sm text-neutral-400">
            Tiba-tiba ingat passwordnya? 
            <a href="{{ route('login') }}" class="font-bold text-[#FF723A] hover:text-[#ff8c5a] hover:underline transition ease-in-out duration-150">
                Masuk di sini
            </a>
        </div>
    </form>
</x-guest-layout>