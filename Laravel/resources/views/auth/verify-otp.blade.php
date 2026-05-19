<x-guest-layout>
    <div class="mb-6 text-sm text-neutral-400 text-center">
        {{ __('Silakan masukkan 6 digit kode OTP yang kami kirimkan ke email:') }} <br>
        <span class="font-bold text-[#FF723A] text-base">{{ $email }}</span>
    </div>

    @if (session('status'))
        <div class="mb-4 font-medium text-sm text-emerald-500 text-center bg-emerald-500/10 py-2 rounded-lg border border-emerald-500/20">
            {{ session('status') }}
        </div>
    @endif

    <form method="POST" action="{{ route('password.otp.verify') }}">
        @csrf

        <input type="hidden" name="email" value="{{ $email }}">

        <div class="mt-4">
            <x-input-label for="otp" :value="__('Kode OTP')" class="text-center mb-3 text-neutral-300" />
            
            <input id="otp" 
                   type="text" 
                   name="otp" 
                   maxlength="6"
                   required 
                   autofocus 
                   inputmode="numeric"
                   autocomplete="one-time-code"
                   placeholder="000000"
                   class="block mt-1 w-full bg-neutral-950 border-neutral-800 text-white focus:border-[#FF723A] focus:ring-[#FF723A] rounded-xl shadow-sm text-center text-4xl font-extrabold tracking-[0.4em] placeholder:text-neutral-800 h-20 transition-all duration-200"
            >

            <x-input-error :messages="$errors->get('otp')" class="mt-3 text-center" />
        </div>

        <div class="flex flex-col items-center justify-center mt-8 space-y-4">
            <button type="submit" class="w-full inline-flex justify-center items-center px-4 py-3 bg-[#FF723A] hover:bg-[#ff8554] text-white font-bold text-sm uppercase tracking-widest rounded-xl transition-all duration-200 active:scale-95 shadow-lg shadow-[#FF723A]/20">
                {{ __('Verifikasi OTP Sekarang') }}
            </button>

            <div>
                <a href="{{ route('password.request') }}" class="text-sm text-neutral-500 hover:text-[#FF723A] transition-colors duration-200 underline decoration-neutral-700 underline-offset-4">
                    {{ __('Ganti Email?') }}
                </a>
            </div>
        </div>
    </form>

    <div class="mt-8 text-center text-xs text-neutral-600">
        {{ __('Kode ini akan kedaluwarsa dalam 5 menit.') }}
    </div>
</x-guest-layout>