<head>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<x-app-layout>
    <x-slot name="header">
        Manajemen Resep Makanan
    </x-slot>

    <div x-data="{ 
            /* --- MODAL STATE --- */
            isModalTambahOpen: false, 
            isModalEditOpen: false,
            isModalHapusOpen: false,
            isModalDetailOpen: false,
            
            /* --- NOTIFICATION STATE --- */
            notif: { show: false, message: '', type: 'success' },
            
            /* --- FORM FILTER STATE --- */
            filterKategori: 'semua',
            filterKategoriCustom: '',
            searchJudul: '',
            
            /* --- FORM INPUT/EDIT STATE --- */
            formResep: {
                id: null,
                judul: '',
                kategoriSelect: 'Sayuran',
                kategoriCustom: '',
                bahan: '',
                steps: '',
                url: ''
            },

            detailResep: {},
            itemToDelete: null,
            
            /* --- DATA DUMMY --- */
            currentPage: 1,
            itemsPerPage: 5,
            
            reseps: [
                { id: 1, judul: 'Gurame Saus Padang', kategori: 'SEAFOOD', labelClass: 'bg-blue-500/10 text-blue-500 border-blue-500/20', bahan: '1 ekor gurame\n4 siung bawang putih (cincang halus)\n3 siung bawang merah (cincang halus)\n15 bh cabai merah (giling)\nSaus tiram, Saus tomat, Garam, Gula, Lada\nTepung maizena & 250 ml air', steps: '1. Cuci bersih ikan gurame lalu lumuri perasan jeruk nipis.\n2. Campur tepung terigu, tepung beras dan garam, lumuri ikan lalu goreng hingga matang.\n3. Tumis bawang merah bawang putih hingga harum, masukan cabai.\n4. Tambahkan saus tiram, tomat, dan air, aduk hingga mengental.\n5. Siram saus ke atas ikan.', url: '/id/resep/gurame-saus-padang' },
                { id: 2, judul: 'Gulai Sayur Labu Siam & Sarden', kategori: 'SAYURAN', labelClass: 'bg-green-500/10 text-green-500 border-green-500/20', bahan: '1 buah labu siam (potong memanjang)\n1 ikat kacang panjang\n1 kaleng sarden kecil\n1 bungkus bumbu gulai instan\n65 ml santan kental\n400 ml air', steps: '1. Panaskan sedikit minyak, tumis bumbu gulai instan.\n2. Tuang air dan biarkan mendidih.\n3. Masukkan sarden kaleng perlahan agar tidak hancur.\n4. Masukkan sayuran, masak hingga empuk.\n5. Tuang santan sambil terus diaduk. Koreksi rasa.', url: '/id/resep/gulai-sayur-labu-siam' },
                { id: 3, judul: 'Gulai Sayur Tauge Ekstra Pedas', kategori: 'SAYURAN', labelClass: 'bg-green-500/10 text-green-500 border-green-500/20', bahan: '1 porsi tauge (cuci, potong)\n1 bungkus bumbu gulai instan\n65 ml santan\n3 lembar daun jeruk\n5 buah cabai rawit merah', steps: '1. Tumis bumbu gulai instan bersama daun jeruk hingga wangi.\n2. Tuang air dan biarkan mendidih.\n3. Masukkan irisan cabai rawit.\n4. Masukkan tauge dan santan.\n5. Aduk hingga matang.', url: '/id/resep/gulai-sayur-tauge-ekstra-pedas-999' },
                { id: 4, judul: 'Es Krim Coklat Lembut', kategori: 'DESSERT', labelClass: 'bg-pink-500/10 text-pink-500 border-pink-500/20', bahan: 'Susu cair\nCoklat bubuk\nGula', steps: '1. Campur semua\n2. Masukkan freezer.', url: '' }
            ],
            
            /* --- HELPER FUNCTIONS --- */
            showNotification(message, type = 'success') {
                this.notif.message = message;
                this.notif.type = type;
                this.notif.show = true;
                setTimeout(() => {
                    this.notif.show = false;
                }, 3000);
            },
            
            /* --- LOGIKA PENCARIAN & FILTER --- */
            get filteredReseps() {
                let result = this.reseps;
                if (this.searchJudul.trim() !== '') {
                    result = result.filter(r => r.judul.toLowerCase().includes(this.searchJudul.toLowerCase()));
                }
                if (this.filterKategori === 'semua') {
                    return result;
                } else if (this.filterKategori === 'lainnya') {
                    if (this.filterKategoriCustom.trim() === '') return result;
                    let search = this.filterKategoriCustom.toUpperCase();
                    return result.filter(r => r.kategori.toUpperCase().includes(search));
                } else {
                    return result.filter(r => r.kategori.toUpperCase() === this.filterKategori.toUpperCase());
                }
            },

            get totalPages() {
                return Math.ceil(this.filteredReseps.length / this.itemsPerPage) || 1;
            },
            get paginatedResep() {
                let start = (this.currentPage - 1) * this.itemsPerPage;
                let end = start + this.itemsPerPage;
                return this.filteredReseps.slice(start, end);
            },
            nextPage() {
                if (this.currentPage < this.totalPages) this.currentPage++;
            },
            prevPage() {
                if (this.currentPage > 1) this.currentPage--;
            },

            /* --- FUNGSI MODAL --- */
            resetForm() {
                this.formResep = { id: null, judul: '', kategoriSelect: 'Sayuran', kategoriCustom: '', bahan: '', steps: '', url: '' };
            },
            openTambah() {
                this.resetForm();
                this.isModalTambahOpen = true;
            },
            openDetail(item) {
                this.detailResep = item;
                this.isModalDetailOpen = true;
            },
            openEdit(item) {
                this.formResep.id = item.id;
                this.formResep.judul = item.judul;
                
                let cat = item.kategori.toLowerCase();
                let defaultOptions = ['sayuran', 'seafood', 'protein', 'unggas', 'bumbu saus'];
                
                if (defaultOptions.includes(cat)) {
                    let formattedCat = cat.split(' ').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
                    this.formResep.kategoriSelect = formattedCat;
                    this.formResep.kategoriCustom = '';
                } else {
                    this.formResep.kategoriSelect = 'Lainnya';
                    this.formResep.kategoriCustom = item.kategori;
                }

                this.formResep.bahan = item.bahan;
                this.formResep.steps = item.steps;
                this.formResep.url = item.url;
                this.isModalEditOpen = true;
            },

            /* --- FUNGSI SAVE DENGAN VALIDASI & NOTIFIKASI --- */
            saveData() {
                // Validasi judul tidak boleh kosong
                if (!this.formResep.judul.trim()) {
                    this.showNotification('Judul resep harus diisi!', 'error');
                    return;
                }
                
                let finalKategori = this.formResep.kategoriSelect === 'Lainnya' 
                    ? this.formResep.kategoriCustom 
                    : this.formResep.kategoriSelect;

                if(finalKategori.trim() === '') finalKategori = 'Lainnya';

                if (this.formResep.id) {
                    // EDIT RESEP
                    let index = this.reseps.findIndex(r => r.id === this.formResep.id);
                    if (index !== -1) {
                        this.reseps[index].judul = this.formResep.judul;
                        this.reseps[index].kategori = finalKategori.toUpperCase();
                        this.reseps[index].bahan = this.formResep.bahan;
                        this.reseps[index].steps = this.formResep.steps;
                        this.reseps[index].url = this.formResep.url;
                        this.showNotification('Resep berhasil diperbarui!', 'success');
                    } else {
                        this.showNotification('Gagal memperbarui resep!', 'error');
                    }
                    this.isModalEditOpen = false;
                } else {
                    // TAMBAH RESEP BARU
                    let newId = this.reseps.length > 0 ? Math.max(...this.reseps.map(r => r.id)) + 1 : 1;
                    
                    this.reseps.unshift({
                        id: newId,
                        judul: this.formResep.judul || 'Tanpa Judul',
                        kategori: finalKategori.toUpperCase(),
                        labelClass: 'bg-neutral-500/10 text-neutral-400 border-neutral-500/20',
                        bahan: this.formResep.bahan,
                        steps: this.formResep.steps,
                        url: this.formResep.url
                    });
                    this.showNotification('Resep baru berhasil ditambahkan!', 'success');
                    this.isModalTambahOpen = false;
                }
            },

            /* --- FUNGSI HAPUS DENGAN NOTIFIKASI --- */
            confirmDelete(id) {
                this.itemToDelete = id;
                this.isModalHapusOpen = true;
            },
            executeDelete() {
                if (this.itemToDelete !== null) {
                    this.reseps = this.reseps.filter(r => r.id !== this.itemToDelete);
                    if (this.currentPage > this.totalPages) {
                        this.currentPage = this.totalPages;
                    }
                    this.showNotification('Resep berhasil dihapus!', 'success');
                } else {
                    this.showNotification('Gagal menghapus resep!', 'error');
                }
                this.isModalHapusOpen = false;
                this.itemToDelete = null;
            }
        }" class="space-y-6 relative">

        <!-- TOAST NOTIFICATION -->
        <div x-show="notif.show" 
             x-transition:enter="transition ease-out duration-300 transform"
             x-transition:enter-start="translate-x-full opacity-0"
             x-transition:enter-end="translate-x-0 opacity-100"
             x-transition:leave="transition ease-in duration-200 transform"
             x-transition:leave-start="translate-x-0 opacity-100"
             x-transition:leave-end="translate-x-full opacity-0"
             class="fixed bottom-6 right-6 z-50 w-80 md:w-96"
             style="display: none;">
            <div :class="{
                    'bg-emerald-500/10 border-emerald-500/50 text-emerald-400': notif.type === 'success',
                    'bg-red-500/10 border-red-500/50 text-red-400': notif.type === 'error',
                    'bg-blue-500/10 border-blue-500/50 text-blue-400': notif.type === 'info'
                }"
                class="backdrop-blur-md border rounded-xl shadow-2xl p-4 flex items-start gap-3">
                <div class="shrink-0">
                    <template x-if="notif.type === 'success'">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </template>
                    <template x-if="notif.type === 'error'">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </template>
                    <template x-if="notif.type === 'info'">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </template>
                </div>
                <div class="flex-1 text-sm font-medium" x-text="notif.message"></div>
                <button @click="notif.show = false" class="shrink-0 opacity-70 hover:opacity-100 transition">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </button>
            </div>
        </div>

        <!-- Header & Tabel (konten sama seperti sebelumnya, tidak diubah) -->
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
                <h1 class="text-2xl font-bold text-white">Manajemen Database Resep</h1>
                <p class="text-neutral-400 text-sm mt-1">Kelola daftar resep lengkap dengan bahan, instruksi masak, dan tautan referensi.</p>
            </div>

            <div class="flex items-center gap-3 w-full sm:w-auto">
                <div class="relative w-full sm:w-64">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg class="w-5 h-5 text-neutral-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                    </div>
                    <input type="text" x-model="searchJudul" @input="currentPage = 1" class="w-full bg-neutral-900 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block pl-10 p-2.5 placeholder-neutral-500 transition-colors" placeholder="Cari judul resep...">
                </div>

                <button @click="openTambah()" class="shrink-0 bg-[#FF723A] hover:bg-[#E55A20] text-white px-4 py-2.5 rounded-xl text-sm font-bold transition-all shadow-lg shadow-[#FF723A]/20 flex items-center gap-2">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                    Tambah Resep
                </button>
            </div>
        </div>

        <div class="flex flex-col sm:flex-row items-start sm:items-center gap-3 pb-2">
            <div class="relative w-full sm:w-56 shrink-0">
                <select x-model="filterKategori" @change="currentPage = 1; filterKategoriCustom = ''" class="w-full bg-neutral-900 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-2.5 appearance-none bg-none cursor-pointer shadow-sm transition-colors">
                    <option value="semua">Semua Kategori</option>
                    <option value="sayuran">Sayuran</option>
                    <option value="seafood">Seafood</option>
                    <option value="protein">Protein</option>
                    <option value="unggas">Unggas</option>
                    <option value="bumbu saus">Bumbu Saus</option>
                    <option value="lainnya" class="font-bold text-[#FF723A]">Kategori Lainnya...</option>
                </select>
                <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none text-neutral-400">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                </div>
            </div>

            <div x-show="filterKategori === 'lainnya'" x-transition:enter="transition ease-out duration-200" x-transition:enter-start="opacity-0 -translate-x-2" x-transition:enter-end="opacity-100 translate-x-0" class="w-full sm:w-64 relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <svg class="w-4 h-4 text-[#FF723A]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path></svg>
                </div>
                <input type="text" x-model="filterKategoriCustom" @input="currentPage = 1" class="w-full bg-neutral-900 border border-[#FF723A]/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block pl-9 p-2.5 placeholder-neutral-500 shadow-[0_0_10px_rgba(255,114,58,0.1)] transition-all" placeholder="Ketik kategori untuk disortir...">
            </div>
        </div>

        <div class="bg-neutral-800 border border-neutral-700/50 rounded-2xl overflow-hidden shadow-sm">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-neutral-400">
                    <thead class="bg-neutral-900/50 text-neutral-300 border-b border-neutral-700/50">
                        <tr>
                            <th class="px-6 py-4 font-bold">Judul Resep</th>
                            <th class="px-6 py-4 font-bold">Kategori</th>
                            <th class="px-6 py-4 font-bold">Kompleksitas</th>
                            <th class="px-6 py-4 font-bold text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-neutral-700/50">
                        <template x-show="filteredReseps.length > 0" x-for="resep in paginatedResep" :key="resep.id">
                            <tr class="hover:bg-neutral-700/20 transition-colors group">
                                <td class="px-6 py-4">
                                    <span class="text-white font-bold block" x-text="resep.judul"></span>
                                </td>
                                <td class="px-6 py-4">
                                    <span :class="resep.labelClass || 'bg-neutral-500/10 text-neutral-400 border-neutral-500/20'" class="border px-2.5 py-1 rounded-md text-xs font-bold uppercase" x-text="resep.kategori"></span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex flex-col gap-0.5 text-xs text-neutral-400">
                                        <span x-text="(resep.bahan ? resep.bahan.split('\n').filter(i=>i.trim()!=='').length : 0) + ' Macam Bahan'"></span>
                                        <span x-text="(resep.steps ? resep.steps.split('\n').filter(i=>i.trim()!=='').length : 0) + ' Langkah Masak'"></span>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <div class="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <button @click="openDetail(resep)" class="p-2 bg-neutral-700 hover:bg-blue-500 text-white rounded-lg transition-colors" title="Lihat Detail Resep">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                                        </button>
                                        <button @click="openEdit(resep)" class="p-2 bg-neutral-700 hover:bg-[#FF723A] text-white rounded-lg transition-colors" title="Edit Resep">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path></svg>
                                        </button>
                                        <button @click="confirmDelete(resep.id)" class="p-2 bg-neutral-700 hover:bg-red-500 text-white rounded-lg transition-colors" title="Hapus">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </template>
                        
                        <tr x-show="filteredReseps.length === 0">
                            <td colspan="4" class="px-6 py-8 text-center text-neutral-500">
                                Tidak ada data resep yang ditemukan.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div x-show="filteredReseps.length > 0" class="p-4 border-t border-neutral-700/50 flex flex-col sm:flex-row items-center justify-between text-sm text-neutral-400 gap-3">
                <span>
                    Menampilkan <span x-text="filteredReseps.length > 0 ? (currentPage - 1) * itemsPerPage + 1 : 0" class="font-bold text-white"></span> 
                    hingga <span x-text="Math.min(currentPage * itemsPerPage, filteredReseps.length)" class="font-bold text-white"></span> 
                    dari <span x-text="filteredReseps.length" class="font-bold text-white"></span> resep
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

        <!-- MODAL TAMBAH/EDIT (konten sama, tidak diubah) -->
        <div x-show="isModalTambahOpen || isModalEditOpen" style="display: none;" class="fixed inset-0 z-50 flex items-center justify-center px-4 py-8">
            <div x-show="isModalTambahOpen || isModalEditOpen" x-transition.opacity.duration.300ms @click="isModalTambahOpen = false; isModalEditOpen = false;" class="absolute inset-0 bg-black/60 backdrop-blur-sm"></div>
            
            <div x-show="isModalTambahOpen || isModalEditOpen" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-8 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" class="relative bg-neutral-900 border border-neutral-700/50 rounded-2xl shadow-2xl w-full max-w-2xl max-h-full overflow-hidden flex flex-col">
                
                <div class="flex items-center justify-between p-6 border-b border-neutral-800 shrink-0">
                    <h3 class="text-xl font-bold text-white" x-text="isModalEditOpen ? 'Update Resep' : 'Tambah Resep Baru'"></h3>
                    <button @click="isModalTambahOpen = false; isModalEditOpen = false;" class="text-neutral-500 hover:text-white transition-colors">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                    </button>
                </div>

                <form class="p-6 space-y-5 overflow-y-auto flex-1">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-neutral-300 mb-1.5">Judul Resep</label>
                            <input type="text" x-model="formResep.judul" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3" placeholder="Contoh: Gurame Saus Padang">
                        </div>
                        
                        <div>
                            <label class="block text-sm font-medium text-neutral-300 mb-1.5">Kategori Olahan</label>
                            <div class="relative mb-2">
                                <select x-model="formResep.kategoriSelect" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3 appearance-none cursor-pointer">
                                    <option value="Sayuran">Sayuran</option>
                                    <option value="Seafood">Seafood</option>
                                    <option value="Protein">Protein</option>
                                    <option value="Unggas">Unggas</option>
                                    <option value="Bumbu Saus">Bumbu Saus</option>
                                    <option value="Lainnya">Lainnya (Isi Sendiri)</option>
                                </select>
                                <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none text-neutral-400">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                                </div>
                            </div>
                            
                            <div x-show="formResep.kategoriSelect === 'Lainnya'" x-transition>
                                <input type="text" x-model="formResep.kategoriCustom" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3 placeholder-neutral-500" placeholder="Ketik kategori baru disini...">
                            </div>
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-neutral-300 mb-1.5">Bahan-Bahan</label>
                        <p class="text-xs text-neutral-500 mb-2">Pisahkan bahan dengan baris baru (Enter).</p>
                        <textarea x-model="formResep.bahan" rows="4" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3" placeholder="Contoh:&#10;1 Ekor Gurame&#10;2 Siung Bawang Putih"></textarea>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-neutral-300 mb-1.5">Langkah / Steps</label>
                        <p class="text-xs text-neutral-500 mb-2">Pisahkan tiap langkah dengan baris baru (Enter).</p>
                        <textarea x-model="formResep.steps" rows="4" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3" placeholder="Contoh:&#10;1. Cuci ikan hingga bersih&#10;2. Goreng dengan minyak panas"></textarea>
                    </div>
                </form>

                <div class="flex items-center justify-end gap-3 p-6 border-t border-neutral-800 shrink-0">
                    <button type="button" @click="isModalTambahOpen = false; isModalEditOpen = false;" class="px-5 py-3 text-sm font-medium text-neutral-300 hover:text-white bg-neutral-800 hover:bg-neutral-700 rounded-xl transition-colors">Batal</button>
                    <button type="button" @click="saveData()" class="px-5 py-3 text-sm font-bold text-white bg-[#FF723A] hover:bg-[#E55A20] rounded-xl shadow-lg transition-all" x-text="isModalEditOpen ? 'Simpan Perubahan' : 'Simpan Resep'"></button>
                </div>
            </div>
        </div>

        <!-- MODAL DETAIL (konten sama) -->
        <div x-show="isModalDetailOpen" style="display: none;" class="fixed inset-0 z-50 flex items-center justify-center px-4 py-8">
            <div x-show="isModalDetailOpen" x-transition.opacity.duration.300ms @click="isModalDetailOpen = false" class="absolute inset-0 bg-black/60 backdrop-blur-sm"></div>
            
            <div x-show="isModalDetailOpen" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-8 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" class="relative bg-neutral-900 border border-neutral-700/50 rounded-2xl shadow-2xl w-full max-w-2xl max-h-full overflow-hidden flex flex-col">
                
                <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between p-6 border-b border-neutral-800 shrink-0 gap-4">
                    <div>
                        <h3 class="text-xl font-bold text-white mb-1" x-text="detailResep.judul"></h3>
                        <span :class="detailResep.labelClass || 'bg-neutral-500/10 text-neutral-400 border-neutral-500/20'" class="border px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider" x-text="detailResep.kategori"></span>
                    </div>
                    <button @click="isModalDetailOpen = false" class="text-neutral-500 hover:text-white transition-colors bg-neutral-800 p-2 rounded-full absolute right-6 top-6 sm:static">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                    </button>
                </div>

                <div class="p-6 space-y-6 overflow-y-auto flex-1 text-sm text-neutral-300">
                    <div>
                        <h4 class="font-bold text-[#FF723A] uppercase tracking-wide mb-3 flex items-center gap-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                            Bahan-Bahan
                        </h4>
                        <ul class="list-disc pl-5 space-y-2 marker:text-neutral-600">
                            <template x-for="item in (detailResep.bahan ? detailResep.bahan.split('\n') : [])" :key="item">
                                <li x-text="item" x-show="item.trim() !== ''"></li>
                            </template>
                        </ul>
                    </div>

                    <div class="h-px w-full bg-neutral-800"></div>

                    <div>
                        <h4 class="font-bold text-[#FF723A] uppercase tracking-wide mb-3 flex items-center gap-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path></svg>
                            Langkah Memasak
                        </h4>
                        <div class="space-y-3">
                            <template x-for="step in (detailResep.steps ? detailResep.steps.split('\n') : [])" :key="step">
                                <p class="leading-relaxed bg-neutral-800/50 p-3 rounded-xl border border-neutral-700/50" x-text="step" x-show="step.trim() !== ''"></p>
                            </template>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- MODAL HAPUS (konten sama) -->
        <div x-show="isModalHapusOpen" style="display: none;" class="fixed inset-0 z-50 flex items-center justify-center px-4">
            <div x-show="isModalHapusOpen" x-transition.opacity.duration.300ms @click="isModalHapusOpen = false" class="absolute inset-0 bg-black/60 backdrop-blur-sm"></div>
            
            <div x-show="isModalHapusOpen" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-8 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" class="relative bg-neutral-900 border border-neutral-700/50 rounded-2xl shadow-2xl w-full max-w-sm overflow-hidden text-center p-6">
                <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-500/10 mb-4">
                    <svg class="h-6 w-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
                </div>
                <h3 class="text-lg font-bold text-white mb-2">Hapus Resep Ini?</h3>
                <p class="text-sm text-neutral-400 mb-6">Resep yang dihapus tidak bisa dikembalikan.</p>
                <div class="flex items-center justify-center gap-3">
                    <button type="button" @click="isModalHapusOpen = false" class="flex-1 px-4 py-2.5 text-sm font-medium text-neutral-300 hover:text-white bg-neutral-800 hover:bg-neutral-700 rounded-xl transition-colors">Batal</button>
                    <button type="button" @click="executeDelete()" class="flex-1 px-4 py-2.5 text-sm font-bold text-white bg-red-500 hover:bg-red-600 rounded-xl shadow-lg shadow-red-500/20 transition-all">Ya, Hapus</button>
                </div>
            </div>
        </div>

    </div>
</x-app-layout>