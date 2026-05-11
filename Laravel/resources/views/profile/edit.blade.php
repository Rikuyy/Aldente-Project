<x-app-layout>
    <x-slot name="header">
        <h2 class="font-bold text-3xl text-white">
            {{ __('Profile Settings') }}
        </h2>
    </x-slot>

    <div class="max-w-7xl mx-auto py-10 sm:px-6 lg:px-8 space-y-8">
        
        <div class="bg-neutral-900 p-6 sm:p-8 rounded-[2.5rem] border border-neutral-800 shadow-2xl transition hover:border-[#FF723A]/30">
            <div class="max-w-xl">
                @include('profile.partials.update-profile-information-form')
            </div>
        </div>

        <div class="bg-neutral-900 p-6 sm:p-8 rounded-[2.5rem] border border-neutral-800 shadow-2xl transition hover:border-[#FF723A]/30">
            <div class="max-w-xl">
                @include('profile.partials.update-password-form')
            </div>
        </div>

    

        <div x-data="{ showLogoutModal: false }" class="bg-neutral-900 p-6 sm:p-8 rounded-[2.5rem] border border-neutral-800 border-l-4 border-l-blue-700 shadow-2xl transition hover:border-blue-800/50">
            <div class="max-w-xl">
                <section class="space-y-6">
                    <header>
                        <h2 class="text-lg font-bold text-white">
                            {{ __('Log Out') }}
                        </h2>
                        <p class="mt-1 text-sm text-neutral-400">
                            {{ __('Keluar dari sesi akun Admin saat ini. Pastikan semua pekerjaan Anda telah disimpan.') }}
                        </p>
                    </header>

                    <div>
                        <button @click="showLogoutModal = true" type="button" class="group flex items-center gap-3 bg-blue-900/20 hover:bg-blue-700 text-blue-400 hover:text-white border border-blue-800/50 font-bold py-3 px-8 rounded-2xl transition-all duration-300 shadow-lg shadow-blue-900/10">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5 transition-transform group-hover:-translate-x-1">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15M12 9l-3 3m0 0l3 3m-3-3h12.75" />
                            </svg>
                            {{ __('Log Out Now') }}
                        </button>
                    </div>

                    <div x-show="showLogoutModal" style="display: none;" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
                        <div x-show="showLogoutModal" x-transition:enter="ease-out duration-300" x-transition:enter-start="opacity-0" x-transition:enter-end="opacity-100" x-transition:leave="ease-in duration-200" x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0" class="fixed inset-0 bg-neutral-950/90 backdrop-blur-md transition-opacity" @click="showLogoutModal = false"></div>

                        <div class="flex min-h-screen items-center justify-center p-4 text-center">
                            <div x-show="showLogoutModal" x-transition:enter="ease-out duration-300" x-transition:enter-start="opacity-0 scale-95" x-transition:enter-end="opacity-100 scale-100" x-transition:leave="ease-in duration-200" x-transition:leave-start="opacity-100 scale-100" x-transition:leave-end="opacity-0 scale-95" class="relative transform overflow-hidden rounded-[2.5rem] bg-neutral-900 border border-neutral-800 text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-md p-8">
                                
                                <h2 class="text-2xl font-bold text-white text-center">
                                    Konfirmasi Keluar
                                </h2>

                                <p class="mt-3 text-center text-neutral-400">
                                    Apakah Anda yakin ingin mengakhiri sesi di dashboard <span class="text-blue-500 font-semibold">CookCash</span>?
                                </p>

                                <div class="mt-10 flex flex-col gap-3">
                                    <form method="POST" action="{{ route('logout') }}" class="w-full">
                                        @csrf
                                        <button type="submit" class="w-full bg-blue-700 hover:bg-blue-800 text-white font-bold py-4 rounded-2xl transition-all shadow-lg shadow-blue-700/20 flex justify-center items-center gap-2">
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15M12 9l-3 3m0 0l3 3m-3-3h12.75" />
                                            </svg>
                                            Ya, Keluar Sekarang
                                        </button>
                                    </form>
                                    <button type="button" @click="showLogoutModal = false" class="w-full bg-neutral-800 hover:bg-neutral-700 text-neutral-300 font-bold py-4 rounded-2xl transition-colors">
                                        Batal
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                </section>
            </div>
        </div>
    </div>
</x-app-layout>