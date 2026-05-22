<section>
    <header>
        <h2 class="text-lg font-bold text-white tracking-tight">
            {{ __('Profile Information') }}
        </h2>

        <p class="mt-1 text-sm text-neutral-400">
            {{ __("Update your account's profile information and email address.") }}
        </p>
    </header>

    <form id="send-verification" method="post" action="{{ route('verification.send') }}">
        @csrf
    </form>

    <form method="post" action="{{ route('profile.update') }}" class="mt-8 space-y-6">
        @csrf
        @method('patch')

        <div>
            <x-input-label for="name" :value="__('Name')" class="text-neutral-300 font-semibold ml-1" />
            <input id="name" name="name" type="text" class="mt-1 block w-full px-5 py-3 bg-neutral-800 border border-neutral-700 text-white rounded-xl shadow-sm focus:border-[#FF723A] focus:ring-[#FF723A] transition-colors" :value="old('name', $user->name)" required autofocus autocomplete="name" />
            <x-input-error class="mt-2 ml-1 text-red-500" :messages="$errors->get('name')" />
        </div>

        <div>
            <x-input-label for="email" :value="__('Email')" class="text-neutral-300 font-semibold ml-1" />
            <input 
                id="email" 
                name="email" 
                type="email" 
                class="mt-1 block w-full px-5 py-3 bg-neutral-900/50 border border-neutral-800 text-neutral-500 rounded-xl shadow-sm cursor-not-allowed focus:outline-none" 
                value="{{ $user->email }}" 
                readonly 
            />
            <p class="mt-2 ml-1 text-[10px] text-neutral-500 italic">
                * Email tidak dapat diubah.
            </p>
            
            @if ($user instanceof \Illuminate\Contracts\Auth\MustVerifyEmail && ! $user->hasVerifiedEmail())
                <div>
                    <p class="text-sm mt-2 text-neutral-400">
                        {{ __('Your email address is unverified.') }}

                        <button form="send-verification" class="underline text-sm text-neutral-500 hover:text-white rounded-md focus:outline-none transition-colors">
                            {{ __('Click here to re-send the verification email.') }}
                        </button>
                    </p>

                    @if (session('status') === 'verification-link-sent')
                        <p class="mt-2 font-medium text-sm text-green-400">
                            {{ __('A new verification link has been sent to your email address.') }}
                        </p>
                    @endif
                </div>
            @endif
        </div>

        <div class="flex items-center gap-4 ml-1">
            <button type="submit" class="bg-[#FF723A] hover:bg-[#ff8c5a] text-white font-bold py-2.5 px-6 rounded-xl transition-colors shadow-lg shadow-[#FF723A]/20">
                {{ __('Save') }}
            </button>

            @if (session('status') === 'profile-updated')
                <p
                    x-data="{ show: true }"
                    x-show="show"
                    x-transition
                    x-init="setTimeout(() => show = false, 2000)"
                    class="text-sm text-neutral-400 font-medium"
                >{{ __('Saved.') }}</p>
            @endif
        </div>
    </form>
</section>