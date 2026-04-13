<section>
    <header>
        <h2 class="text-2xl font-bold text-neutral-950 tracking-tight">
            {{ __('Profile Information') }}
        </h2>

        <p class="mt-2 text-sm text-neutral-600">
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
            <x-input-label for="name" :value="__('Name')" class="text-neutral-800 font-semibold ml-1" />
            <input id="name" name="name" type="text" class="mt-1 block w-full px-5 py-3 border border-neutral-300 text-neutral-950 rounded-xl shadow-sm focus:border-neutral-400 focus:ring-0" :value="old('name', $user->name)" required autofocus autocomplete="name" />
            <x-input-error class="mt-2 ml-1" :messages="$errors->get('name')" />
        </div>

        <div>
            <x-input-label for="email" :value="__('Email')" class="text-neutral-800 font-semibold ml-1" />
            <input id="email" name="email" type="email" class="mt-1 block w-full px-5 py-3 border border-neutral-300 text-neutral-950 rounded-xl shadow-sm focus:border-neutral-400 focus:ring-0" :value="old('email', $user->email)" required autocomplete="username" />
            <x-input-error class="mt-2 ml-1" :messages="$errors->get('email')" />

            @if ($user instanceof \Illuminate\Contracts\Auth\MustVerifyEmail && ! $user->hasVerifiedEmail())
                <div>
                    <p class="text-sm mt-2 text-neutral-800">
                        {{ __('Your email address is unverified.') }}

                        <button form="send-verification" class="underline text-sm text-neutral-600 hover:text-neutral-900 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[#FF723A]">
                            {{ __('Click here to re-send the verification email.') }}
                        </button>
                    </p>

                    @if (session('status') === 'verification-link-sent')
                        <p class="mt-2 font-medium text-sm text-green-600">
                            {{ __('A new verification link has been sent to your email address.') }}
                        </p>
                    @endif
                </div>
            @endif
        </div>

        <div class="flex items-center gap-4 ml-1">
            <button type="submit" class="bg-[#FF723A] hover:bg-[#ff8c5a] text-white font-bold py-2.5 px-6 rounded-xl transition shadow-md">
                {{ __('Save') }}
            </button>

            @if (session('status') === 'profile-updated')
                <p
                    x-data="{ show: true }"
                    x-show="show"
                    x-transition
                    x-init="setTimeout(() => show = false, 2000)"
                    class="text-sm text-neutral-600 font-medium"
                >{{ __('Saved.') }}</p>
            @endif
        </div>
    </form>
</section>