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
                <p class="text-neutral-400 mt-2 text-lg">Pantau perkembangan resep dan performa sistem rekomendasi TF-IDF.</p>
            </div>
            <a href="{{ route('resep.index') }}" wire:navigate class="inline-flex items-center justify-center py-3 px-6 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-xl font-bold tracking-wider transition-all duration-200 shadow-lg shadow-[#FF723A]/20 whitespace-nowrap group">
                <i class="fas fa-plus mr-2 group-hover:rotate-90 transition-transform duration-300"></i> Tambah Resep Baru
            </a>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
            
            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 hover:border-[#FF723A]/50 transition-colors duration-300 group shadow-lg">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-neutral-400 text-sm font-semibold mb-1">Total Resep</p>
                        <h3 class="text-4xl font-bold text-white group-hover:text-[#FF723A] transition-colors">0</h3>
                    </div>
                    <div class="w-12 h-12 rounded-xl bg-neutral-800 flex items-center justify-center text-white group-hover:bg-[#FF723A] transition-colors">
                        <i class="fas fa-book-open text-xl"></i>
                    </div>
                </div>
                <div class="flex items-center text-sm">
                    <span class="text-neutral-500 font-medium bg-neutral-800 px-2 py-1 rounded-md">0</span>
                    <span class="text-neutral-500 ml-2">Resep bulan ini</span>
                </div>
            </div>
            
            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 hover:border-blue-500/50 transition-colors duration-300 group shadow-lg">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-neutral-400 text-sm font-semibold mb-1">Kategori Tersedia</p>
                        <h3 class="text-4xl font-bold text-white group-hover:text-blue-400 transition-colors">0</h3>
                    </div>
                    <div class="w-12 h-12 rounded-xl bg-neutral-800 flex items-center justify-center text-white group-hover:bg-blue-500 transition-colors">
                        <i class="fas fa-tags text-xl"></i>
                    </div>
                </div>
                <div class="flex items-center text-sm">
                    <span class="text-neutral-500">Tersebar di seluruh resep</span>
                </div>
            </div>
            
            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 hover:border-purple-500/50 transition-colors duration-300 group shadow-lg">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-neutral-400 text-sm font-semibold mb-1">Total Pengujian</p>
                        <h3 class="text-4xl font-bold text-white group-hover:text-purple-400 transition-colors">0</h3>
                    </div>
                    <div class="w-12 h-12 rounded-xl bg-neutral-800 flex items-center justify-center text-white group-hover:bg-purple-500 transition-colors">
                        <i class="fas fa-microchip text-xl"></i>
                    </div>
                </div>
                <div class="flex items-center text-sm">
                    <span class="text-purple-400 font-medium">Algoritma TF-IDF</span>
                </div>
            </div>
            
            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 hover:border-green-500/50 transition-colors duration-300 group shadow-lg border-l-4 border-l-green-500">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-neutral-400 text-sm font-semibold mb-1">Rata-rata Akurasi</p>
                        <h3 class="text-4xl font-bold text-white">0<span class="text-2xl text-green-500">%</span></h3>
                    </div>
                    <div class="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center text-green-500">
                        <i class="fas fa-bullseye text-xl"></i>
                    </div>
                </div>
                <div class="flex items-center text-sm">
                    <span class="text-neutral-500">Berdasarkan data uji terakhir</span>
                </div>
            </div>

        </div>

        <div class="bg-neutral-900 rounded-[2rem] border border-neutral-800 shadow-2xl overflow-hidden">
            <div class="p-6 sm:p-8 border-b border-neutral-800/50 flex justify-between items-center bg-neutral-800/20">
                <h2 class="text-xl font-bold text-white flex items-center">
                    <i class="fas fa-clock text-[#FF723A] mr-3"></i> Resep Terbaru Masuk
                </h2>
                <a href="{{ route('resep.index') }}" wire:navigate class="text-sm font-semibold text-[#FF723A] hover:text-white transition-colors">
                    Lihat Semua <i class="fas fa-arrow-right ml-1"></i>
                </a>
            </div>
            
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse whitespace-nowrap">
                    <thead>
                        <tr class="bg-neutral-800/50">
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700">Nama Resep</th>
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700">Kategori</th>
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700">Estimasi Harga</th>
                            <th class="py-4 px-6 text-neutral-300 font-semibold border-b border-neutral-700">Tanggal Ditambahkan</th>
                        </tr>
                    </thead>
                    <tbody class="text-neutral-400">
                        <tr class="border-b border-neutral-800/50">
                            <td colspan="4" class="py-16 px-4 text-center text-neutral-500">
                                <div class="w-16 h-16 bg-neutral-800 rounded-full flex items-center justify-center mx-auto mb-4">
                                    <i class="fas fa-folder-open text-2xl opacity-50"></i>
                                </div>
                                <p class="text-lg">Belum ada data resep baru.</p>
                                <p class="text-sm mt-1">Silakan tambah resep melalui tombol di atas.</p>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</x-app-layout>