<x-guest-layout>
    <div class="text-center mb-10">
        <h1 class="text-3xl font-extrabold text-white tracking-tight">Register Account</h1>
        <p class="mt-3 text-lg text-neutral-400">Create an account to get started</p>
    </div>

    <form method="POST" action="{{ route('register') }}" class="space-y-6">
        @csrf

        <div class="space-y-2">
            <x-input-label for="name" :value="__('Name')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="name" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-neutral-600 focus:ring-0 placeholder-neutral-500 focus:placeholder-transparent transition-all duration-200" type="text" name="name" :value="old('name')" required autofocus autocomplete="name" placeholder="Enter your name" />
            </div>
            <x-input-error :messages="$errors->get('name')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="email" :value="__('Email')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="email" class="block w-full px-6 py-4 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-neutral-600 focus:ring-0 placeholder-neutral-500 focus:placeholder-transparent transition-all duration-200" type="email" name="email" :value="old('email')" required autocomplete="username" placeholder="Enter your email" />
            </div>
            <x-input-error :messages="$errors->get('email')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="password" :value="__('Password')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="password" class="block w-full px-6 py-4 pr-14 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-neutral-600 focus:ring-0 placeholder-neutral-500 focus:placeholder-transparent transition-all duration-200" type="password" name="password" required autocomplete="new-password" placeholder="Enter your password" />
                
                <button type="button" onclick="togglePassword('password', 'eye-icon-1', 'eye-slash-icon-1')" class="absolute right-6 top-1/2 -translate-y-1/2 text-neutral-500 hover:text-[#FF723A] focus:outline-none transition-colors">
                    <svg id="eye-icon-1" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                    <svg id="eye-slash-icon-1" class="w-6 h-6 hidden" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
                    </svg>
                </button>
            </div>
            <x-input-error :messages="$errors->get('password')" class="mt-2 ml-5" />
        </div>

        <div class="space-y-2">
            <x-input-label for="password_confirmation" :value="__('Confirm Password')" class="text-neutral-300 font-semibold ml-1" />
            <div class="relative">
                <input id="password_confirmation" class="block w-full px-6 py-4 pr-14 bg-neutral-800 border border-neutral-700 text-white rounded-full text-lg shadow-inner focus:border-neutral-600 focus:ring-0 placeholder-neutral-500 focus:placeholder-transparent transition-all duration-200" type="password" name="password_confirmation" required autocomplete="new-password" placeholder="Confirm your password" />
                
                <button type="button" onclick="togglePassword('password_confirmation', 'eye-icon-2', 'eye-slash-icon-2')" class="absolute right-6 top-1/2 -translate-y-1/2 text-neutral-500 hover:text-[#FF723A] focus:outline-none transition-colors">
                    <svg id="eye-icon-2" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                    <svg id="eye-slash-icon-2" class="w-6 h-6 hidden" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
                    </svg>
                </button>
            </div>
            <x-input-error :messages="$errors->get('password_confirmation')" class="mt-2 ml-5" />
        </div>

        <div class="mt-8">
            <button type="submit" class="w-full py-4 px-6 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-full text-lg font-bold tracking-wider transition-colors duration-200">
                REGISTER
            </button>
        </div>

        <div class="mt-6 text-center text-sm text-neutral-400">
            Sudah punya akun? 
            <a href="{{ route('login') }}" class="font-bold text-[#FF723A] hover:text-[#ff8c5a] hover:underline transition ease-in-out duration-150">
                Masuk di sini
            </a>
        </div>
        
    </form>
</x-guest-layout>

<script>
    function togglePassword(inputId, iconId, iconSlashId) {
        const passwordInput = document.getElementById(inputId);
        const eyeIcon = document.getElementById(iconId);
        const eyeSlashIcon = document.getElementById(iconSlashId);

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            eyeIcon.classList.add('hidden');
            eyeSlashIcon.classList.remove('hidden');
        } else {
            passwordInput.type = 'password';
            eyeIcon.classList.remove('hidden');
            eyeSlashIcon.classList.add('hidden');
        }
    }
</script>