<x-app-layout>
    
    <x-slot name="header">
        Evaluasi Algoritma
    </x-slot>

    <div class="max-w-7xl mx-auto">
        
        <div class="mb-10 text-center">
            <h1 class="text-4xl font-extrabold tracking-tight text-white mb-3">
                <i class="fas fa-microchip text-[#FF723A] mr-2"></i> 
                Dashboard Evaluasi <span class="text-[#FF723A]">TF-IDF</span>
            </h1>
            <p class="text-lg text-neutral-400">Sistem Pencarian Resep Anak Kos - CookCash Project</p>
        </div>

        <div class="mb-10 text-center">
            <button id="btnJalankanUji" class="inline-flex items-center justify-center py-4 px-8 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-full text-lg font-bold tracking-wider transition-colors duration-200 shadow-lg shadow-[#FF723A]/20">
                <i class="fas fa-play-circle mr-3 text-xl"></i> Jalankan Uji Akurasi Data Test
            </button>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
            
            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 border-l-4 border-l-blue-500 shadow-xl relative overflow-hidden">
                <div class="absolute top-0 right-0 p-4 opacity-10">
                    <i class="fas fa-database text-6xl text-blue-500"></i>
                </div>
                <h6 class="text-neutral-400 font-semibold mb-2">Total Data Uji</h6>
                <div class="flex items-baseline gap-2">
                    <h3 class="text-4xl font-bold text-white" id="totalUji">0</h3>
                    <span class="text-neutral-500">Resep</span>
                </div>
            </div>

            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 border-l-4 border-l-green-500 shadow-xl relative overflow-hidden">
                <div class="absolute top-0 right-0 p-4 opacity-10">
                    <i class="fas fa-check-circle text-6xl text-green-500"></i>
                </div>
                <h6 class="text-neutral-400 font-semibold mb-2">Prediksi Benar</h6>
                <div class="flex items-baseline gap-2">
                    <h3 class="text-4xl font-bold text-green-400" id="totalBenar">0</h3>
                    <span class="text-neutral-500">Sesuai</span>
                </div>
            </div>

            <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 border-l-4 border-l-[#FF723A] shadow-xl relative overflow-hidden">
                <div class="absolute top-0 right-0 p-4 opacity-10">
                    <i class="fas fa-chart-line text-6xl text-[#FF723A]"></i>
                </div>
                <h6 class="text-neutral-400 font-semibold mb-2">Akurasi Sistem</h6>
                <div class="flex items-baseline gap-2">
                    <h3 class="text-4xl font-bold text-[#FF723A]" id="akurasiSistem">0%</h3>
                </div>
            </div>

        </div>

        <div class="bg-neutral-900 p-6 sm:p-8 rounded-[2rem] border border-neutral-800 shadow-2xl">
            <h2 class="text-2xl font-bold mb-6 flex items-center text-white">
                <i class="fas fa-list text-[#FF723A] mr-3"></i> Detail Hasil Pengujian
            </h2>
            
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse whitespace-nowrap">
                    <thead>
                        <tr class="bg-neutral-800/50">
                            <th class="py-4 px-4 text-neutral-300 font-semibold border-b border-neutral-700 rounded-tl-xl">#</th>
                            <th class="py-4 px-4 text-neutral-300 font-semibold border-b border-neutral-700">Input Query (Soal)</th>
                            <th class="py-4 px-4 text-neutral-300 font-semibold border-b border-neutral-700">Kategori Target</th>
                            <th class="py-4 px-4 text-neutral-300 font-semibold border-b border-neutral-700">Rekomendasi AI</th>
                            <th class="py-4 px-4 text-neutral-300 font-semibold border-b border-neutral-700">Kategori Prediksi</th>
                            <th class="py-4 px-4 text-neutral-300 font-semibold border-b border-neutral-700">Skor Kemiripan</th>
                            <th class="py-4 px-4 text-neutral-300 font-semibold border-b border-neutral-700 rounded-tr-xl">Status</th>
                        </tr>
                    </thead>
                    <tbody class="text-neutral-400" id="tableBody">
                        <tr class="border-b border-neutral-800/50">
                            <td colspan="7" class="py-12 px-4 text-center text-neutral-500">
                                <i class="fas fa-inbox text-4xl mb-4 opacity-50 block"></i>
                                Belum ada data pengujian.<br>
                                Klik tombol <b class="text-neutral-400">Jalankan Uji Akurasi Data Test</b> di atas untuk memulai.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</x-app-layout>