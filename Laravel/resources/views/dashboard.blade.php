<x-app-layout>
    <div class="max-w-7xl mx-auto">
        <div class="flex flex-col md:flex-row items-start md:items-center justify-between mb-8 gap-4">
            <div>
                <h1 class="text-3xl font-bold text-white">Overview Admin</h1>
                <p class="text-gray-400 mt-1">Pantau perkembangan resep dan user anak kos kamu.</p>
            <!-- </div>
            <button class="bg-[#FF6B35] hover:bg-[#e85a20] text-white px-6 py-3 rounded-xl font-semibold shadow-lg shadow-[#FF6B35]/20 transition-all whitespace-nowrap">
                + Tambah Resep Baru
            </button>
        </div> -->

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            
            <div class="bg-[#1A1A1A] p-6 rounded-2xl border border-white/5">
                <p class="text-gray-400 text-sm mb-1">Total Resep Aktif</p>
                <h3 class="text-3xl font-bold text-white">1,248</h3>
                <span class="text-green-500 text-xs font-medium">+12 minggu ini</span>
            </div>
            
            <div class="bg-[#1A1A1A] p-6 rounded-2xl border border-white/5">
                <p class="text-gray-400 text-sm mb-1">User Terdaftar</p>
                <h3 class="text-3xl font-bold text-white">8,590</h3>
                <span class="text-orange-500 text-xs font-medium">Anak kos aktif</span>
            </div>
            
            <div class="bg-[#1A1A1A] p-6 rounded-2xl border border-white/5 border-l-4 border-l-[#FF6B35]">
                <p class="text-gray-400 text-sm mb-1">Menunggu Review</p>
                <h3 class="text-3xl font-bold text-white">14</h3>
                <span class="text-gray-500 text-xs font-medium italic text-orange-400">Butuh persetujuan admin</span>
            </div>
            
            <div class="bg-[#1A1A1A] p-6 rounded-2xl border border-white/5">
                <p class="text-gray-400 text-sm mb-1">Total Master Bahan</p>
                <h3 class="text-3xl font-bold text-white">128</h3>
                <span class="text-red-500 text-xs font-medium">5 Bahan Naik Harga</span>
            </div>

        </div>

        <div class="bg-[#1A1A1A] rounded-2xl border border-white/5 overflow-hidden">
            <div class="p-6 border-b border-white/5">
                <h2 class="text-xl font-bold text-white">Resep Terbaru Masuk</h2>
            </div>
            <div class="p-6 text-center text-gray-500"> 
                Belum ada data resep baru untuk ditampilkan.
            </div>
        </div>
    </div>
</x-app-layout>