<section>
    <header>
        <h2 class="text-lg font-bold text-white">
            {{ __('Update Password') }}
        </h2>

        <p class="mt-1 text-sm text-neutral-400">
            {{ __('Ensure your account is using a long, random password to stay secure.') }}
        </p>
    </header>

    <form method="post" action="{{ route('password.update') }}" class="mt-6 space-y-6">
        @csrf
        @method('put')

        <div>
            <x-input-label for="update_password_current_password" :value="__('Current Password')" class="text-neutral-300 font-semibold ml-1" />
            <x-text-input id="update_password_current_password" name="current_password" type="password" class="mt-1 block w-full px-5 py-3 bg-neutral-800 border border-neutral-700 text-white rounded-xl shadow-sm focus:border-[#FF723A] focus:ring-[#FF723A] transition-colors" autocomplete="current-password" />
            <x-input-error :messages="$errors->updatePassword->get('current_password')" class="mt-2 text-red-500" />
        </div>

        <div>
            <x-input-label for="update_password_password" :value="__('New Password')" class="text-neutral-300 font-semibold ml-1" />
            <x-text-input id="update_password_password" name="password" type="password" class="mt-1 block w-full px-5 py-3 bg-neutral-800 border border-neutral-700 text-white rounded-xl shadow-sm focus:border-[#FF723A] focus:ring-[#FF723A] transition-colors" autocomplete="new-password" />
            <x-input-error :messages="$errors->updatePassword->get('password')" class="mt-2 text-red-500" />
        </div>

        <div>
            <x-input-label for="update_password_password_confirmation" :value="__('Confirm Password')" class="text-neutral-300 font-semibold ml-1" />
            <x-text-input id="update_password_password_confirmation" name="password_confirmation" type="password" class="mt-1 block w-full px-5 py-3 bg-neutral-800 border border-neutral-700 text-white rounded-xl shadow-sm focus:border-[#FF723A] focus:ring-[#FF723A] transition-colors" autocomplete="new-password" />
            <x-input-error :messages="$errors->updatePassword->get('password_confirmation')" class="mt-2 text-red-500" />
        </div>

        <div class="flex items-center gap-4 ml-1">
            <button type="submit" class="bg-[#FF723A] hover:bg-[#ff8c5a] text-white font-bold py-2.5 px-6 rounded-xl transition-colors shadow-lg shadow-[#FF723A]/20">
                {{ __('Save') }}
            </button>

            @if (session('status') === 'password-updated')
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