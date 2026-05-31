<x-app-layout>
    <x-slot name="header">
        User Management
    </x-slot>

    <div class="max-w-7xl mx-auto">
        <div class="flex flex-col md:flex-row items-start md:items-center justify-between mb-8 gap-4">
            <div>
                <h1 class="text-3xl font-extrabold tracking-tight text-white">
                    Manajemen <span class="text-[#FF723A]">User</span>
                </h1>
                <p class="text-neutral-400 mt-2 text-lg">Kelola data pengguna yang terdaftar di sistem database MongoDB.</p>
            </div>
        </div>

        @if (session('status'))
            <div class="mb-6 p-4 bg-green-500/10 border border-green-500/50 text-green-400 rounded-xl flex items-center">
                <i class="fas fa-check-circle mr-3"></i>
                {{ session('status') }}
            </div>
        @endif

        <div class="bg-neutral-900 rounded-[2rem] border border-neutral-800 shadow-2xl overflow-hidden">
            <div class="p-6 sm:p-8 border-b border-neutral-800/50 bg-neutral-800/20">
                <h2 class="text-xl font-bold text-white flex items-center">
                    <i class="fas fa-users text-[#FF723A] mr-3"></i> Daftar Pengguna Terdaftar
                </h2>
            </div>
            
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse whitespace-nowrap">
                    <thead>
                        <tr class="bg-neutral-800/50">
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700">Nama</th>
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700">Email</th>
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700">Tanggal Gabung</th>
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700 text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="text-neutral-400">
                        @forelse($users as $user)
                        <tr class="border-b border-neutral-800/50 hover:bg-neutral-800/30 transition-colors">
                            <!-- Menampilkan nama menggunakan kolom Username sesuai di Model -->
                            <td class="py-4 px-6 font-bold text-white">{{ $user->Username ?? '-' }}</td>
                            
                            <!-- Menampilkan Email secara penuh (tanpa sensor) -->
                            <td class="py-4 px-6">
                                <span class="bg-neutral-800 text-sm px-3 py-1 rounded-md border border-neutral-700 text-neutral-300">
                                    {{ $user->Email ?? '-' }}
                                </span>
                            </td>
                            
                            <td class="py-4 px-6 text-sm">
                                {{ $user->created_at ? $user->created_at->format('d M Y') : '-' }}
                            </td>
                            <td class="py-4 px-6 text-center">
                                <!-- Menggunakan Id_User untuk proses hapus (sesuai primaryKey di Model) -->
                                <form action="{{ route('users.destroy', $user->Id_User) }}" method="POST" onsubmit="return confirm('Hapus user ini secara permanen?')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="bg-red-500/10 hover:bg-red-500 text-red-500 hover:text-white px-4 py-2 rounded-xl border border-red-500/20 transition-all duration-200 text-sm font-bold">
                                        <i class="fas fa-trash-alt mr-1"></i> Hapus
                                    </button>
                                </form>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="4" class="py-16 px-4 text-center text-neutral-500">
                                <div class="w-16 h-16 bg-neutral-800 rounded-full flex items-center justify-center mx-auto mb-4">
                                    <i class="fas fa-user-slash text-2xl opacity-50"></i>
                                </div>
                                <p class="text-lg font-bold text-white mb-1">Tidak ada user ditemukan</p>
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</x-app-layout>