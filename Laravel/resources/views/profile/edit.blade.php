<x-app-layout>
    <x-slot name="header">
        <span class="font-extrabold text-3xl text-gray-900">
            {{ __('Profile') }}
        </span>
    </x-slot>

    <div class="space-y-8">
        
        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-100 transition hover:shadow-md">
            <div class="max-w-xl">
                @include('profile.partials.update-profile-information-form')
            </div>
        </div>

        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-100 transition hover:shadow-md">
            <div class="max-w-xl">
                @include('profile.partials.update-password-form')
            </div>
        </div>

        <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-100 transition hover:shadow-md">
            <div class="max-w-xl">
                @include('profile.partials.delete-user-form')
            </div>
        </div>

    </div>
</x-app-layout>