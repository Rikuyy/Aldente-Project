<head>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<x-app-layout>
    <x-slot name="header">
        Manajemen Harga Bahan
    </x-slot>

    <div x-data="{ 
            /* --- MODAL STATE --- */
            isModalTambahOpen: false, 
            isModalEditOpen: false,
            isModalHapusOpen: false,
            
            /* --- FORM TAMBAH STATE --- */
            filterKategori: 'semua',
            kategoriForm: 'Sayuran',
            hargaInput: '',
            beratInput: '',
            satuanForm: 'gram',
            
            /* --- FORM EDIT STATE --- */
            editForm: {
                id: null,
                nama: '',
                harga: '',
                kategori: '',
                ukuran: ''
            },

            /* --- DELETE STATE --- */
            itemToDelete: null,

            formatRupiah(val) {
                let angka = val.replace(/[^0-9]/g, '');
                if (angka === '') return '';
                return 'Rp ' + new Intl.NumberFormat('id-ID').format(angka);
            },
            
            /* --- DATA & PAGINATION --- */
            currentPage: 1,
            itemsPerPage: 5,
            bahans: [
                { id: 1, nama: 'Cabai Rawit Merah', kategori: 'SAYURAN', labelClass: 'bg-green-500/10 text-green-500 border-green-500/20', ukuran: '150 - 160 gram / pack', harga: 'Rp19.100', tgl: '12 Jan 2024', status: '2 hari yang lalu', is_lama: false },
                { id: 2, nama: 'Telur Ayam Negeri', kategori: 'PROTEIN', labelClass: 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20', ukuran: '10 pcs / pack', harga: 'Rp23.900', tgl: '01 Des 2023', status: '1 bulan yang lalu', is_lama: true },
                { id: 3, nama: 'Bawang Merah', kategori: 'SAYURAN', labelClass: 'bg-green-500/10 text-green-500 border-green-500/20', ukuran: '500 gram', harga: 'Rp25.000', tgl: '14 Jan 2024', status: 'Baru saja', is_lama: false },
                { id: 4, nama: 'Bawang Putih', kategori: 'SAYURAN', labelClass: 'bg-green-500/10 text-green-500 border-green-500/20', ukuran: '500 gram', harga: 'Rp20.000', tgl: '14 Jan 2024', status: 'Baru saja', is_lama: false },
                { id: 5, nama: 'Daging Sapi Giling', kategori: 'PROTEIN', labelClass: 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20', ukuran: '500 gram', harga: 'Rp65.000', tgl: '10 Nov 2023', status: '2 bulan yang lalu', is_lama: true },
                { id: 6, nama: 'Dada Ayam Fillet', kategori: 'UNGGAS', labelClass: 'bg-orange-500/10 text-orange-500 border-orange-500/20', ukuran: '1 kg', harga: 'Rp55.000', tgl: '10 Jan 2024', status: '4 hari yang lalu', is_lama: false },
                { id: 7, nama: 'Garam Halus', kategori: 'BUMBU SAUS', labelClass: 'bg-blue-500/10 text-blue-500 border-blue-500/20', ukuran: '250 gram', harga: 'Rp3.500', tgl: '05 Jan 2024', status: '9 hari yang lalu', is_lama: false },
                { id: 8, nama: 'Kecap Manis', kategori: 'BUMBU SAUS', labelClass: 'bg-blue-500/10 text-blue-500 border-blue-500/20', ukuran: '520 ml', harga: 'Rp24.500', tgl: '05 Jan 2024', status: '9 hari yang lalu', is_lama: false },
                { id: 9, nama: 'Gula Pasir', kategori: 'LAINNYA', labelClass: 'bg-neutral-500/10 text-neutral-400 border-neutral-500/20', ukuran: '1 kg', harga: 'Rp16.000', tgl: '20 Okt 2023', status: '3 bulan yang lalu', is_lama: true },
                { id: 10, nama: 'Minyak Goreng', kategori: 'LAINNYA', labelClass: 'bg-neutral-500/10 text-neutral-400 border-neutral-500/20', ukuran: '2 Liter', harga: 'Rp34.000', tgl: '12 Jan 2024', status: '2 hari yang lalu', is_lama: false },
            ],
            
            get totalPages() {
                return Math.ceil(this.bahans.length / this.itemsPerPage) || 1;
            },
            get paginatedBahan() {
                let start = (this.currentPage - 1) * this.itemsPerPage;
                let end = start + this.itemsPerPage;
                return this.bahans.slice(start, end);
            },
            nextPage() {
                if (this.currentPage < this.totalPages) this.currentPage++;
            },
            prevPage() {
                if (this.currentPage > 1) this.currentPage--;
            },

            /* --- FUNGSI EDIT LOGIC --- */
            openEdit(item) {
                this.editForm.id = item.id;
                this.editForm.nama = item.nama;
                this.editForm.harga = item.harga;
                this.editForm.kategori = item.kategori;
                this.editForm.ukuran = item.ukuran;
                this.isModalEditOpen = true;
            },
            saveEdit() {
                let index = this.bahans.findIndex(b => b.id === this.editForm.id);
                if (index !== -1) {
                    this.bahans[index].nama = this.editForm.nama;
                    this.bahans[index].harga = this.editForm.harga;
                    let today = new Date().toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' });
                    this.bahans[index].tgl = today;
                    this.bahans[index].status = 'Baru saja diupdate';
                    this.bahans[index].is_lama = false;
                }
                this.isModalEditOpen = false;
            },

            /* --- FUNGSI HAPUS LOGIC --- */
            confirmDelete(id) {
                this.itemToDelete = id;
                this.isModalHapusOpen = true;
            },
            executeDelete() {
                if (this.itemToDelete !== null) {
                    // Filter out (hapus) data yang ID-nya cocok
                    this.bahans = this.bahans.filter(b => b.id !== this.itemToDelete);
                    
                    // Kalau halaman saat ini jadi kosong karena hapus data terakhir di halaman itu, mundur 1 halaman
                    if (this.currentPage > this.totalPages) {
                        this.currentPage = this.totalPages;
                    }
                }
                this.isModalHapusOpen = false;
                this.itemToDelete = null;
            }
        }" class="space-y-6 relative">

        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
                <h1 class="text-2xl font-bold text-white">Daftar Harga Bahan</h1>
                <p class="text-neutral-400 text-sm mt-1">Update harga bahan pokok agar estimasi resep anak kos tetap akurat.</p>
            </div>

            <div class="flex items-center gap-3 w-full sm:w-auto">
                <div class="relative w-full sm:w-64">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg class="w-5 h-5 text-neutral-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                    </div>
                    <input type="text" class="w-full bg-neutral-900 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block pl-10 p-2.5 placeholder-neutral-500 transition-colors" placeholder="Cari nama bahan...">
                </div>

                <button @click="isModalTambahOpen = true" class="shrink-0 bg-[#FF723A] hover:bg-[#E55A20] text-white px-4 py-2.5 rounded-xl text-sm font-bold transition-all shadow-lg shadow-[#FF723A]/20 flex items-center gap-2">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                    Tambah Bahan
                </button>
            </div>
        </div>

        <div class="flex flex-col sm:flex-row items-start sm:items-center gap-3 pb-2">
            <div class="relative w-full sm:w-56 shrink-0">
                <select x-model="filterKategori" class="w-full bg-neutral-900 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-2.5 appearance-none bg-none cursor-pointer shadow-sm transition-colors">
                    <option value="semua">Semua Kategori</option>
                    <option value="sayuran">Sayuran</option>
                    <option value="buah">Buah</option>
                    <option value="protein">Protein</option>
                    <option value="unggas">Unggas</option>
                    <option value="bumbu_saus">Bumbu Saus</option>
                    <option value="lainnya" class="font-bold text-[#FF723A]">Kategori Lainnya...</option>
                </select>
                <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none text-neutral-400">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                </div>
            </div>
        </div>

        <div class="bg-neutral-800 border border-neutral-700/50 rounded-2xl overflow-hidden shadow-sm">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-neutral-400">
                    <thead class="bg-neutral-900/50 text-neutral-300 border-b border-neutral-700/50">
                        <tr>
                            <th class="px-6 py-4 font-bold">Nama Barang</th>
                            <th class="px-6 py-4 font-bold">Kategori</th>
                            <th class="px-6 py-4 font-bold">Ukuran / Berat</th>
                            <th class="px-6 py-4 font-bold">Harga</th>
                            <th class="px-6 py-4 font-bold">Terakhir Update</th>
                            <th class="px-6 py-4 font-bold text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-neutral-700/50">
                        <template x-show="bahans.length > 0" x-for="bahan in paginatedBahan" :key="bahan.id">
                            <tr class="hover:bg-neutral-700/20 transition-colors group">
                                <td class="px-6 py-4">
                                    <span class="text-white font-bold block" x-text="bahan.nama"></span>
                                </td>
                                <td class="px-6 py-4">
                                    <span :class="bahan.labelClass" class="border px-2.5 py-1 rounded-md text-xs font-bold" x-text="bahan.kategori"></span>
                                </td>
                                <td class="px-6 py-4 font-medium text-neutral-300" x-text="bahan.ukuran"></td>
                                <td class="px-6 py-4">
                                    <span class="text-white font-bold" x-text="bahan.harga"></span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex flex-col">
                                        <span class="text-sm text-neutral-200" x-text="bahan.tgl"></span>
                                        <span class="text-xs" :class="bahan.is_lama ? 'text-red-400' : 'text-green-400'" x-text="bahan.status"></span>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <div class="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <button @click="openEdit(bahan)" class="p-2 bg-neutral-700 hover:bg-[#FF723A] text-white rounded-lg transition-colors" title="Update Harga">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path></svg>
                                        </button>
                                        <button @click="confirmDelete(bahan.id)" class="p-2 bg-neutral-700 hover:bg-red-500 text-white rounded-lg transition-colors" title="Hapus">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </template>
                        
                        <tr x-show="bahans.length === 0">
                            <td colspan="6" class="px-6 py-8 text-center text-neutral-500">
                                Tidak ada data bahan yang ditemukan.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div x-show="bahans.length > 0" class="p-4 border-t border-neutral-700/50 flex flex-col sm:flex-row items-center justify-between text-sm text-neutral-400 gap-3">
                <span>
                    Menampilkan <span x-text="(currentPage - 1) * itemsPerPage + 1" class="font-bold text-white"></span> 
                    hingga <span x-text="Math.min(currentPage * itemsPerPage, bahans.length)" class="font-bold text-white"></span> 
                    dari <span x-text="bahans.length" class="font-bold text-white"></span> bahan
                </span>
                
                <div class="flex gap-2">
                    <button @click="prevPage()" :disabled="currentPage === 1" class="px-3 py-1 rounded-md bg-neutral-900 border border-neutral-700 hover:text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed">Prev</button>
                    <template x-for="page in totalPages" :key="page">
                        <button @click="currentPage = page" :class="currentPage === page ? 'bg-[#FF723A] text-white border-[#FF723A]' : 'bg-neutral-900 text-neutral-400 border-neutral-700 hover:text-white'" class="px-3 py-1 rounded-md font-bold border transition-colors" x-text="page"></button>
                    </template>
                    <button @click="nextPage()" :disabled="currentPage === totalPages" class="px-3 py-1 rounded-md bg-neutral-900 border border-neutral-700 hover:text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed">Next</button>
                </div>
            </div>
        </div>

        <div x-show="isModalTambahOpen" style="display: none;" class="fixed inset-0 z-50 flex items-center justify-center px-4">
            <div x-show="isModalTambahOpen" x-transition.opacity.duration.300ms @click="isModalTambahOpen = false" class="absolute inset-0 bg-black/60 backdrop-blur-sm"></div>
            <div x-show="isModalTambahOpen" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-8 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" x-transition:leave="transition ease-in duration-200" x-transition:leave-start="opacity-100 translate-y-0 scale-100" x-transition:leave-end="opacity-0 translate-y-8 scale-95" class="relative bg-neutral-900 border border-neutral-700/50 rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden">
                <div class="flex items-center justify-between p-6 border-b border-neutral-800">
                    <h3 class="text-xl font-bold text-white">Tambah Bahan Baru</h3>
                    <button @click="isModalTambahOpen = false" class="text-neutral-500 hover:text-white transition-colors">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                    </button>
                </div>
                <form class="p-6 space-y-5">
                    <div>
                        <label class="block text-sm font-medium text-neutral-300 mb-1.5">Nama Barang</label>
                        <input type="text" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3" placeholder="Contoh: Bawang Putih">
                    </div>
                    <div class="grid grid-cols-2 gap-4 items-start">
                        <div>
                            <label class="block text-sm font-medium text-neutral-300 mb-1.5">Kategori</label>
                            <div class="relative">
                                <select x-model="kategoriForm" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3 appearance-none bg-none cursor-pointer">
                                    <option value="Sayuran">Sayuran</option>
                                    <option value="Buah">Buah</option>
                                    <option value="Protein">Protein</option>
                                    <option value="Unggas">Unggas</option>
                                    <option value="Seafood">Seafood</option>
                                    <option value="Bumbu Saus">Bumbu Saus</option>
                                </select>
                            </div>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-neutral-300 mb-1.5">Harga (Rp)</label>
                            <input type="text" x-model="hargaInput" @input="hargaInput = formatRupiah($event.target.value)" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3" placeholder="Rp 0">
                        </div>
                    </div>
                    <div class="flex items-center justify-end gap-3 pt-8 mt-6 border-t border-neutral-800">
                        <button type="button" @click="isModalTambahOpen = false" class="px-5 py-3 text-sm font-medium text-neutral-300 hover:text-white bg-neutral-800 hover:bg-neutral-700 rounded-xl transition-colors">Batal</button>
                        <button type="button" @click="isModalTambahOpen = false" class="px-5 py-3 text-sm font-bold text-white bg-[#FF723A] hover:bg-[#E55A20] rounded-xl shadow-lg transition-all">Simpan</button>
                    </div>
                </form>
            </div>
        </div>

        <div x-show="isModalEditOpen" style="display: none;" class="fixed inset-0 z-50 flex items-center justify-center px-4">
            <div x-show="isModalEditOpen" x-transition.opacity.duration.300ms @click="isModalEditOpen = false" class="absolute inset-0 bg-black/60 backdrop-blur-sm"></div>
            <div x-show="isModalEditOpen" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-8 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" x-transition:leave="transition ease-in duration-200" x-transition:leave-start="opacity-100 translate-y-0 scale-100" x-transition:leave-end="opacity-0 translate-y-8 scale-95" class="relative bg-neutral-900 border border-neutral-700/50 rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden">
                <div class="flex items-center justify-between p-6 border-b border-neutral-800">
                    <h3 class="text-xl font-bold text-white">Update Harga Bahan</h3>
                    <button @click="isModalEditOpen = false" class="text-neutral-500 hover:text-white transition-colors">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                    </button>
                </div>
                <div class="p-6 space-y-5">
                    <div class="bg-neutral-800/50 p-4 rounded-xl border border-neutral-700/30 mb-2">
                        <p class="text-xs text-neutral-400 mb-1">Bahan yang diupdate:</p>
                        <p class="text-lg font-bold text-white" x-text="editForm.nama"></p>
                        <p class="text-sm text-[#FF723A] mt-1" x-text="editForm.ukuran"></p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-neutral-300 mb-1.5">Harga Baru (Rp)</label>
                        <input type="text" x-model="editForm.harga" @input="editForm.harga = formatRupiah($event.target.value)" class="w-full bg-neutral-800 border border-[#FF723A]/50 text-white text-lg font-bold rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-4 shadow-[0_0_15px_rgba(255,114,58,0.1)] transition-all" placeholder="Rp 0">
                    </div>
                    <div class="flex items-center justify-end gap-3 pt-8 mt-6 border-t border-neutral-800">
                        <button type="button" @click="isModalEditOpen = false" class="px-5 py-3 text-sm font-medium text-neutral-300 hover:text-white bg-neutral-800 hover:bg-neutral-700 rounded-xl transition-colors">Batal</button>
                        <button type="button" @click="saveEdit()" class="px-5 py-3 text-sm font-bold text-white bg-[#FF723A] hover:bg-[#E55A20] rounded-xl shadow-lg shadow-[#FF723A]/20 transition-all flex items-center gap-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                            Simpan Perubahan
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div x-show="isModalHapusOpen" style="display: none;" class="fixed inset-0 z-50 flex items-center justify-center px-4">
            <div x-show="isModalHapusOpen" x-transition.opacity.duration.300ms @click="isModalHapusOpen = false" class="absolute inset-0 bg-black/60 backdrop-blur-sm"></div>
            
            <div x-show="isModalHapusOpen" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-8 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" x-transition:leave="transition ease-in duration-200" x-transition:leave-start="opacity-100 translate-y-0 scale-100" x-transition:leave-end="opacity-0 translate-y-8 scale-95" class="relative bg-neutral-900 border border-neutral-700/50 rounded-2xl shadow-2xl w-full max-w-sm overflow-hidden text-center p-6">
                
                <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-500/10 mb-4">
                    <svg class="h-6 w-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                    </svg>
                </div>
                
                <h3 class="text-lg font-bold text-white mb-2">Hapus Bahan Ini?</h3>
                <p class="text-sm text-neutral-400 mb-6">Data yang dihapus tidak bisa dikembalikan. Pastikan Anda tidak salah pilih.</p>
                
                <div class="flex items-center justify-center gap-3">
                    <button type="button" @click="isModalHapusOpen = false" class="flex-1 px-4 py-2.5 text-sm font-medium text-neutral-300 hover:text-white bg-neutral-800 hover:bg-neutral-700 rounded-xl transition-colors">
                        Batal
                    </button>
                    <button type="button" @click="executeDelete()" class="flex-1 px-4 py-2.5 text-sm font-bold text-white bg-red-500 hover:bg-red-600 rounded-xl shadow-lg shadow-red-500/20 transition-all">
                        Ya, Hapus
                    </button>
                </div>
            </div>
        </div>

    </div>
</x-app-layout>