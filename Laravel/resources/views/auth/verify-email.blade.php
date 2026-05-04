<x-guest-layout>
    <div class="text-center mb-10">
        <div class="h-20 w-20 bg-[#FF723A]/10 rounded-full flex items-center justify-center mx-auto mb-6">
            <i class="fas fa-envelope-open-text text-4xl text-[#FF723A]"></i>
        </div>
        <h1 class="text-3xl font-extrabold text-white tracking-tight">Verifikasi Email</h1>
        <p class="mt-4 text-neutral-400 leading-relaxed">
            Hampir selesai! Kami sudah mengirimkan link verifikasi ke email Anda. Silakan klik link tersebut untuk mengaktifkan akun.
        </p>
    </div>

    @if (session('status') == 'verification-link-sent')
        <div class="mb-6 p-4 bg-green-500/10 border border-green-500/50 text-green-400 text-sm rounded-2xl text-center font-bold animate-pulse">
            Link baru berhasil dikirim ke alamat email Anda.
        </div>
    @endif

    <div class="flex flex-col gap-4">
        <form method="POST" action="{{ route('verification.send') }}" x-data="{ loading: false }" @submit="loading = true">
            @csrf
            <button type="submit" :disabled="loading" class="w-full py-4 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-full font-bold transition-all shadow-lg shadow-[#FF723A]/20 flex justify-center items-center gap-2">
                <template x-if="loading">
                    <i class="fas fa-spinner animate-spin"></i>
                </template>
                <span x-text="loading ? 'Mengirim...' : 'Kirim Ulang Email Verifikasi'"></span>
            </button>
        </form>

        <form method="POST" action="{{ route('logout') }}" class="text-center">
            @csrf
            <button type="submit" class="text-sm font-bold text-neutral-500 hover:text-white transition uppercase tracking-widest">
                Log Out
            </button>
        </form>
    </div>
</x-guest-layout>