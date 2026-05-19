<x-app-layout>
    <x-slot name="header">
        Overview Dashboard
    </x-slot>

    <div class="max-w-7xl mx-auto">
        
        <div class="flex flex-col md:flex-row items-start md:items-center justify-between mb-8 gap-4">
            <div>
                <h1 class="text-3xl font-extrabold tracking-tight text-white">
                    Overview <span class="text-[#FF723A]">Admin</span>
                </h1>
                <p class="text-neutral-400 mt-2 text-lg">Pantau perkembangan database resep dan status sinkronisasi AI.</p>
            </div>
            <a href="{{ url('/resep') }}" class="inline-flex items-center justify-center py-3 px-6 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-xl font-bold tracking-wider transition-all duration-200 shadow-lg shadow-[#FF723A]/20 whitespace-nowrap group">
                <i class="fas fa-plus mr-2 group-hover:rotate-90 transition-transform duration-300"></i> Kelola Resep
            </a>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
            
            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 hover:border-[#FF723A]/50 transition-colors duration-300 group shadow-lg">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-neutral-400 text-sm font-semibold mb-1">Total Resep</p>
                        <h3 class="text-4xl font-bold text-white group-hover:text-[#FF723A] transition-colors">{{ $totalResep }}</h3>
                    </div>
                    <div class="w-12 h-12 rounded-xl bg-neutral-800 flex items-center justify-center text-white group-hover:bg-[#FF723A] transition-colors">
                        <i class="fas fa-book-open text-xl"></i>
                    </div>
                </div>
                <div class="text-sm text-neutral-500 font-medium">Resep aktif di database</div>
            </div>
            
            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 hover:border-pink-500/50 transition-colors duration-300 group shadow-lg">
                <div class="flex justify-between items-start mb-4">
                    <div class="overflow-hidden pr-2">
                        <p class="text-neutral-400 text-sm font-semibold mb-1">Paling Disukai</p>
                        <h3 class="text-lg font-bold text-white truncate group-hover:text-pink-400 transition-colors">{{ $namaResepPopuler }}</h3>
                    </div>
                    <div class="w-12 h-12 rounded-xl bg-neutral-800 flex items-center justify-center text-white group-hover:bg-pink-500 transition-colors shrink-0">
                        <i class="fas fa-heart text-xl"></i>
                    </div>
                </div>
                <div class="text-sm text-neutral-500">Resep dengan Loves tertinggi</div>
            </div>
            
            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 hover:border-blue-500/50 transition-colors duration-300 group shadow-lg">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-neutral-400 text-sm font-semibold mb-1">Rata-rata Komposisi</p>
                        <h3 class="text-4xl font-bold text-white group-hover:text-blue-400 transition-colors">{{ $rataBahan }}</h3>
                    </div>
                    <div class="w-12 h-12 rounded-xl bg-neutral-800 flex items-center justify-center text-white group-hover:bg-blue-500 transition-colors shrink-0">
                        <i class="fas fa-list-ol text-xl"></i>
                    </div>
                </div>
                <div class="text-sm text-neutral-500">Rata-rata bahan per resep</div>
            </div>
            
            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 hover:border-green-500/50 transition-colors duration-300 group shadow-lg border-l-4 border-l-green-500">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-neutral-400 text-sm font-semibold mb-1">Terakhir Update AI</p>
                        <h3 class="text-md font-bold text-white mt-2">{{ $waktuUpdate }}</h3>
                    </div>
                    <div class="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center text-green-500 shrink-0">
                        <i class="fas fa-robot text-xl"></i>
                    </div>
                </div>
                <div class="text-sm text-neutral-500 mt-2">Sinkronisasi Chatbot ML</div>
            </div>

        </div>

        <div class="bg-neutral-900 rounded-[2rem] border border-neutral-800 shadow-2xl overflow-hidden">
            <div class="p-6 sm:p-8 border-b border-neutral-800/50 flex justify-between items-center bg-neutral-800/20">
                <h2 class="text-xl font-bold text-white flex items-center">
                    <i class="fas fa-clock text-[#FF723A] mr-3"></i> Aktivitas Terbaru (Resep Masuk)
                </h2>
                <a href="{{ url('/resep') }}" class="text-sm font-semibold text-[#FF723A] hover:text-white transition-colors">
                    Lihat Semua <i class="fas fa-arrow-right ml-1"></i>
                </a>
            </div>
            
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse whitespace-nowrap">
                    <thead>
                        <tr class="bg-neutral-800/50">
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700">Nama Resep</th>
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700">Kategori</th>
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700 text-center">Komposisi</th>
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700 text-center">Favorit</th>
                        </tr>
                    </thead>
                    <tbody class="text-neutral-400">
                        @forelse($resepTerbaru as $resep)
                        <tr class="border-b border-neutral-800/50 hover:bg-neutral-800/30 transition-colors">
                            <td class="py-4 px-6 font-bold text-white">{{ $resep['Title Cleaned'] ?? 'Tanpa Judul' }}</td>
                            <td class="py-4 px-6">
                                <span class="bg-neutral-800 text-xs px-2 py-1 rounded-md uppercase border border-neutral-700 text-neutral-300">
                                    {{ $resep['Category'] ?? 'Lainnya' }}
                                </span>
                            </td>
                            <td class="py-4 px-6 text-sm text-center">
                                {{ $resep['Total Ingredients'] ?? 0 }} Bahan
                            </td>
                            <td class="py-4 px-6 text-center">
                                <div class="text-pink-500 font-bold flex items-center justify-center gap-1 bg-pink-500/10 px-2 py-1 rounded-lg inline-flex">
                                    <i class="fas fa-heart text-xs"></i> {{ $resep['Loves'] ?? 0 }}
                                </div>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="4" class="py-16 px-4 text-center text-neutral-500">
                                <div class="w-16 h-16 bg-neutral-800 rounded-full flex items-center justify-center mx-auto mb-4">
                                    <i class="fas fa-folder-open text-2xl opacity-50"></i>
                                </div>
                                <p class="text-lg font-bold text-white mb-1">Belum ada data resep</p>
                                <p class="text-sm">Data resep terbaru akan muncul di sini.</p>
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</x-app-layout>