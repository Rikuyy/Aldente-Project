<head>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>

<x-app-layout>
    <x-slot name="header">
        Manajemen Resep Makanan 
    </x-slot>

    <div x-data="{ 
            isModalTambahOpen: false, 
            isModalEditOpen: false,
            isModalHapusOpen: false,
            isModalDetailOpen: false,
            
            notif: { show: false, message: '', type: 'success' },
            
            filterKategori: 'semua',
            filterKategoriCustom: '',
            searchJudul: '',
            
            formResep: {
                id: null,
                judul: '',
                kategoriSelect: '',
                kategoriCustom: '',
                bahan: '',
                steps: '',
                loves: 0
            },

            detailResep: {},
            itemToDelete: null,
            
            currentPage: 1,
            itemsPerPage: 5,
            reseps: [],
            uniqueCategories: [],
            
            init() {
                this.fetchResep();
            },

            getCategoryColor(cat) {
                const category = cat.toLowerCase();
                if (category.includes('sapi')) return 'bg-red-500/10 text-red-500 border-red-500/20';
                if (category.includes('ayam')) return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20';
                if (category.includes('udang') || category.includes('seafood')) return 'bg-orange-500/10 text-orange-500 border-orange-500/20';
                if (category.includes('sayur')) return 'bg-green-500/10 text-green-500 border-green-500/20';
                if (category.includes('ikan')) return 'bg-cyan-500/10 text-cyan-500 border-cyan-500/20';
                return 'bg-purple-500/10 text-purple-400 border-purple-500/20';
            },

            fetchResep() {
                fetch('/api/resep')
                    .then(res => res.json())
                    .then(data => {
                        this.reseps = data.map(item => {
                            let bahanClean = item['Ingredients Cleaned'] 
                                ? item['Ingredients Cleaned'].split(',').map(s => s.trim()).join('\n') 
                                : '';
                            let langkahClean = item['Steps'] || '';

                            return {
                                id: item.id || item._id,
                                judul: item['Title Cleaned'] || 'Tanpa Judul',
                                kategori: item.Category ? item.Category.toUpperCase() : 'LAINNYA',
                                bahan: bahanClean,
                                steps: langkahClean,
                                totalBahan: item['Total Ingredients'] || bahanClean.split('\n').filter(b=>b.trim()).length,
                                totalLangkah: item['Total Steps'] || langkahClean.split('\n').filter(s=>s.trim()).length,
                                loves: item.Loves || 0
                            };
                        });

                        let cats = this.reseps.map(r => r.kategori);
                        this.uniqueCategories = [...new Set(cats)].filter(c => c !== 'LAINNYA');
                        
                        if(this.uniqueCategories.length > 0 && !this.formResep.kategoriSelect) {
                            this.formResep.kategoriSelect = this.uniqueCategories[0];
                        }
                    })
                    .catch(err => {
                        console.error('Error Fetching Data:', err);
                        this.showNotification('Gagal mengambil data dari server', 'error');
                    });
            },

            showNotification(message, type = 'success') {
                this.notif.message = message;
                this.notif.type = type;
                this.notif.show = true;
                setTimeout(() => { this.notif.show = false; }, 3000);
            },
            
            get filteredReseps() {
                let result = this.reseps;
                if (this.searchJudul.trim() !== '') {
                    result = result.filter(r => r.judul.toLowerCase().includes(this.searchJudul.toLowerCase()));
                }
                if (this.filterKategori === 'semua') {
                    return result;
                } else if (this.filterKategori === 'lainnya') {
                    if (this.filterKategoriCustom.trim() === '') return result;
                    return result.filter(r => r.kategori.toUpperCase().includes(this.filterKategoriCustom.toUpperCase()));
                } else {
                    return result.filter(r => r.kategori === this.filterKategori);
                }
            },

            get totalPages() { return Math.ceil(this.filteredReseps.length / this.itemsPerPage) || 1; },
            get paginatedResep() {
                let start = (this.currentPage - 1) * this.itemsPerPage;
                return this.filteredReseps.slice(start, start + this.itemsPerPage);
            },
            nextPage() { if (this.currentPage < this.totalPages) this.currentPage++; },
            prevPage() { if (this.currentPage > 1) this.currentPage--; },

            resetForm() {
                this.formResep = { id: null, judul: '', kategoriSelect: this.uniqueCategories[0] || '', kategoriCustom: '', bahan: '', steps: '', loves: 0 };
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
                this.formResep.bahan = item.bahan;
                this.formResep.steps = item.steps;
                this.formResep.loves = item.loves;
                
                if (this.uniqueCategories.includes(item.kategori)) {
                    this.formResep.kategoriSelect = item.kategori;
                    this.formResep.kategoriCustom = '';
                } else {
                    this.formResep.kategoriSelect = 'Lainnya';
                    this.formResep.kategoriCustom = item.kategori;
                }
                this.isModalEditOpen = true;
            },

            triggerModelUpdate() {
                fetch('/api/chatbot/update-ai', {
                    method: 'POST',
                    headers: { 'Accept': 'application/json' }
                })
                .then(res => res.json())
                .then(data => {
                    console.log('AI Model Updated:', data);
                    this.showNotification('Model AI berhasil di-retrain!', 'success');
                })
                .catch(err => console.error('Gagal update model:', err));
            },

            saveData() {
                if (!this.formResep.judul.trim()) {
                    this.showNotification('Judul resep harus diisi!', 'error'); return;
                }
                
                let finalKategori = this.formResep.kategoriSelect === 'Lainnya' ? this.formResep.kategoriCustom : this.formResep.kategoriSelect;
                if(finalKategori.trim() === '') finalKategori = 'Lainnya';

                let bahanArray = this.formResep.bahan.split('\n').filter(b => b.trim() !== '');
                let langkahArray = this.formResep.steps.split('\n').filter(s => s.trim() !== '');
                let bahanApi = bahanArray.join(' , ');

                let payload = {
                    'Title Cleaned': this.formResep.judul,
                    'Category': finalKategori.toLowerCase(),
                    'Ingredients Cleaned': bahanApi,
                    'Steps': this.formResep.steps,
                    'Total Ingredients': bahanArray.length,
                    'Total Steps': langkahArray.length,
                    'Loves': this.formResep.loves
                };

                let url = this.formResep.id ? `/api/resep/${this.formResep.id}` : '/api/resep';
                let method = this.formResep.id ? 'PUT' : 'POST';

                fetch(url, {
                    method: method,
                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                    body: JSON.stringify(payload)
                })
                .then(res => res.json())
                .then(data => {
                    if(data.status === 'success') {
                        this.showNotification(data.message, 'success');
                        this.fetchResep(); 
                        this.triggerModelUpdate(); // OTOMATIS JALAN SAAT TAMBAH ATAU EDIT
                        this.isModalEditOpen = false;
                        this.isModalTambahOpen = false;
                    }
                });
            },

            confirmDelete(id) {
                this.itemToDelete = id;
                this.isModalHapusOpen = true;
            },
            executeDelete() {
                if (this.itemToDelete !== null) {
                    fetch(`/api/resep/${this.itemToDelete}`, {
                        method: 'DELETE',
                        headers: { 'Accept': 'application/json' }
                    })
                    .then(res => res.json())
                    .then(data => {
                        if(data.status === 'success') {
                            this.showNotification(data.message, 'success');
                            this.fetchResep(); 
                            this.triggerModelUpdate(); // OTOMATIS JALAN SAAT HAPUS
                            if (this.paginatedResep.length === 1 && this.currentPage > 1) this.currentPage--;
                        }
                    });
                }
                this.isModalHapusOpen = false;
                this.itemToDelete = null;
            }
        }" class="space-y-6 relative" x-cloak>

        <div x-show="notif.show" x-transition class="fixed bottom-6 right-6 z-50 w-80 md:w-96" style="display: none;">
            <div :class="notif.type === 'success' ? 'bg-emerald-500/10 border-emerald-500/50 text-emerald-400' : 'bg-red-500/10 border-red-500/50 text-red-400'"
                class="backdrop-blur-md border rounded-xl shadow-2xl p-4 flex items-start gap-3">
                <div class="flex-1 text-sm font-medium" x-text="notif.message"></div>
            </div>
        </div>

        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
                <h1 class="text-2xl font-bold text-white">Rincian Resep</h1>
                <p class="text-neutral-400 text-sm mt-1">Sistem Otomatis: Sinkronasi Database dan Retrain Model ML CookCash.</p>
            </div>

            <div class="flex items-center gap-3 w-full sm:w-auto">
                <div class="relative w-full sm:w-64">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-neutral-500">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                    </div>
                    <input type="text" x-model="searchJudul" class="w-full bg-neutral-900 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block pl-10 p-2.5 transition-colors" placeholder="Cari judul resep...">
                </div>
                <button @click="openTambah()" class="shrink-0 bg-[#FF723A] hover:bg-[#E55A20] text-white px-4 py-2.5 rounded-xl text-sm font-bold shadow-lg flex items-center gap-2 transition-all">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                    Tambah
                </button>
            </div>
        </div>

        <div class="flex items-center gap-3 pb-2">
            <select x-model="filterKategori" class="w-full sm:w-56 bg-neutral-900 border border-neutral-700/50 text-white text-sm rounded-xl block p-2.5 focus:ring-[#FF723A] focus:border-[#FF723A]">
                <option value="semua">Semua Kategori</option>
                <template x-for="cat in uniqueCategories" :key="cat">
                    <option :value="cat" x-text="cat"></option>
                </template>
                <option value="lainnya" class="font-bold text-[#FF723A]">Kategori Lainnya...</option>
            </select>
            <div x-show="filterKategori === 'lainnya'" class="w-full sm:w-64 relative">
                <input type="text" x-model="filterKategoriCustom" class="w-full bg-neutral-900 border border-[#FF723A]/50 text-white text-sm rounded-xl block p-2.5" placeholder="Ketik kategori...">
            </div>
        </div>

        <div class="bg-neutral-800 border border-neutral-700/50 rounded-2xl overflow-hidden shadow-sm">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-neutral-400">
                    <thead class="bg-neutral-900/50 text-neutral-300 border-b border-neutral-700/50">
                        <tr>
                            <th class="px-6 py-4 font-bold whitespace-nowrap w-1/3">Judul Resep</th>
                            <th class="px-6 py-4 font-bold whitespace-nowrap">Kategori</th>
                            <th class="px-6 py-4 font-bold whitespace-nowrap">Komposisi</th>
                            <th class="px-6 py-4 font-bold whitespace-nowrap text-center">Favorit</th>
                            <th class="px-6 py-4 font-bold whitespace-nowrap text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-neutral-700/50">
                        <template x-show="filteredReseps.length > 0" x-for="resep in paginatedResep" :key="resep.id">
                            <tr class="hover:bg-neutral-700/20 transition-colors group">
                                <td class="px-6 py-4">
                                    <span class="text-white font-bold block" x-text="resep.judul"></span>
                                </td>
                                <td class="px-6 py-4">
                                    <span :class="getCategoryColor(resep.kategori)" class="border px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider inline-block" x-text="resep.kategori"></span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="text-neutral-400" x-text="`${resep.totalBahan} Bahan • ${resep.totalLangkah} Langkah`"></span>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <div class="inline-flex items-center gap-1.5 text-pink-500 font-bold bg-pink-500/10 px-2.5 py-1 rounded-lg">
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                                        <span x-text="resep.loves"></span>
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <button @click="openDetail(resep)" title="Detail Resep" class="p-2 bg-neutral-700 hover:bg-blue-500 text-white rounded-lg transition-colors">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                                        </button>
                                        <button @click="openEdit(resep)" title="Edit Resep" class="p-2 bg-neutral-700 hover:bg-[#FF723A] text-white rounded-lg transition-colors">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path></svg>
                                        </button>
                                        <button @click="confirmDelete(resep.id)" title="Hapus Resep" class="p-2 bg-neutral-700 hover:bg-red-500 text-white rounded-lg transition-colors">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </template>
                        <tr x-show="filteredReseps.length === 0">
                            <td colspan="5" class="px-6 py-8 text-center text-neutral-500">
                                Tidak ada data resep yang ditemukan dari Database.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div x-show="filteredReseps.length > 0" class="p-4 border-t border-neutral-700/50 flex flex-col sm:flex-row items-center justify-between text-sm text-neutral-400 gap-3">
                <span>
                    Menampilkan <span class="font-bold text-white" x-text="(currentPage - 1) * itemsPerPage + 1"></span> - 
                    <span class="font-bold text-white" x-text="Math.min(currentPage * itemsPerPage, filteredReseps.length)"></span> 
                    dari <span class="font-bold text-white" x-text="filteredReseps.length"></span> total resep
                </span>
                <div class="flex gap-2">
                    <button @click="prevPage()" :disabled="currentPage === 1" class="px-3 py-1.5 rounded-md bg-neutral-900 border border-neutral-700 hover:text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed">Sebelumnya</button>
                    <button @click="nextPage()" :disabled="currentPage === totalPages" class="px-3 py-1.5 rounded-md bg-neutral-900 border border-neutral-700 hover:text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed">Selanjutnya</button>
                </div>
            </div>
        </div>

        <div x-show="isModalTambahOpen || isModalEditOpen" style="display:none;" class="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="isModalTambahOpen = false; isModalEditOpen = false;"></div>
            <div x-show="isModalTambahOpen || isModalEditOpen" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-8 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" class="relative bg-neutral-900 border border-neutral-700/50 rounded-2xl shadow-2xl w-full max-w-2xl max-h-full overflow-hidden flex flex-col z-10">
                <div class="flex items-center justify-between p-6 border-b border-neutral-800 shrink-0">
                    <h3 class="text-xl font-bold text-white" x-text="isModalEditOpen ? 'Update Data Resep' : 'Tambah Resep Baru'"></h3>
                    <button @click="isModalTambahOpen = false; isModalEditOpen = false;" class="text-neutral-500 hover:text-white transition-colors">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                    </button>
                </div>
                
                <form class="p-6 space-y-5 overflow-y-auto max-h-[60vh] flex-1">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-neutral-300 mb-1.5">Judul Resep</label>
                            <input type="text" x-model="formResep.judul" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3" placeholder="Contoh: Udang Bakar Madu">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-neutral-300 mb-1.5">Kategori Olahan</label>
                            <select x-model="formResep.kategoriSelect" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3">
                                <template x-for="cat in uniqueCategories" :key="cat">
                                    <option :value="cat" x-text="cat"></option>
                                </template>
                                <option value="Lainnya">Lainnya (Isi Baru)</option>
                            </select>
                            <div x-show="formResep.kategoriSelect === 'Lainnya'" class="mt-2">
                                <input type="text" x-model="formResep.kategoriCustom" class="w-full bg-neutral-800 border border-[#FF723A]/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3" placeholder="Ketik kategori baru...">
                            </div>
                        </div>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-neutral-300 mb-1.5">Bahan-Bahan <span class="text-xs text-neutral-500 font-normal">(Pisahkan dengan baris baru / Enter)</span></label>
                        <textarea x-model="formResep.bahan" rows="4" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3" placeholder="1 Ekor Gurame&#10;2 Siung Bawang Putih"></textarea>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-neutral-300 mb-1.5">Langkah Memasak <span class="text-xs text-neutral-500 font-normal">(Pisahkan dengan baris baru / Enter)</span></label>
                        <textarea x-model="formResep.steps" rows="4" class="w-full bg-neutral-800 border border-neutral-700/50 text-white text-sm rounded-xl focus:ring-[#FF723A] focus:border-[#FF723A] block p-3" placeholder="1) Cuci bersih&#10;2) Goreng"></textarea>
                    </div>
                </form>
                
                <div class="flex items-center justify-end gap-3 p-6 border-t border-neutral-800 shrink-0">
                    <button type="button" @click="isModalTambahOpen = false; isModalEditOpen = false;" class="px-5 py-2.5 text-sm font-medium text-neutral-300 hover:text-white bg-neutral-800 hover:bg-neutral-700 rounded-xl transition-colors">Batal</button>
                    <button type="button" @click="saveData()" class="px-5 py-2.5 text-sm font-bold text-white bg-[#FF723A] hover:bg-[#E55A20] rounded-xl shadow-lg transition-all" x-text="isModalEditOpen ? 'Simpan Perubahan' : 'Simpan Resep'"></button>
                </div>
            </div>
        </div>

        <div x-show="isModalDetailOpen" style="display:none;" class="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="isModalDetailOpen = false"></div>
            <div x-show="isModalDetailOpen" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-8 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" class="relative bg-neutral-900 border border-neutral-700/50 rounded-2xl p-6 w-full max-w-2xl max-h-[85vh] overflow-y-auto flex flex-col z-10 shadow-2xl">
                
                <div class="flex items-start justify-between border-b border-neutral-800 pb-4 mb-4">
                    <div>
                        <h2 class="text-2xl font-bold text-white mb-2" x-text="detailResep.judul"></h2>
                        <div class="flex gap-2 items-center">
                            <span :class="getCategoryColor(detailResep.kategori || '')" class="border px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider" x-text="detailResep.kategori"></span>
                            <span class="text-xs text-pink-500 font-bold flex items-center gap-1 bg-pink-500/10 px-2 py-0.5 rounded"><svg class="w-3 h-3 fill-current" viewBox="0 0 24 24"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg><span x-text="detailResep.loves"></span></span>
                        </div>
                    </div>
                    <button @click="isModalDetailOpen = false" class="text-neutral-500 hover:text-white transition-colors bg-neutral-800 p-2 rounded-full">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                    </button>
                </div>

                <div class="space-y-6 text-sm text-neutral-300">
                    <div>
                        <h4 class="font-bold text-[#FF723A] uppercase tracking-wide mb-3 flex items-center gap-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                            Daftar Bahan
                        </h4>
                        <ul class="list-disc pl-5 space-y-1.5 marker:text-neutral-600">
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

        <div x-show="isModalHapusOpen" style="display:none;" class="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="isModalHapusOpen = false"></div>
            <div x-show="isModalHapusOpen" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-8 scale-95" x-transition:enter-end="opacity-100 translate-y-0 scale-100" class="relative bg-neutral-900 border border-neutral-700/50 rounded-2xl p-6 w-full max-w-sm text-center z-10 shadow-2xl">
                <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-500/10 mb-4">
                    <svg class="h-6 w-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
                </div>
                <h3 class="text-lg font-bold text-white mb-2">Hapus Data Ini?</h3>
                <p class="text-sm text-neutral-400 mb-6">Resep yang dihapus akan hilang dari database dan model AI akan di-update kembali.</p>
                <div class="flex gap-3">
                    <button @click="isModalHapusOpen = false" class="flex-1 py-2.5 text-sm font-medium text-neutral-300 bg-neutral-800 hover:bg-neutral-700 rounded-xl transition-colors">Batal</button>
                    <button @click="executeDelete()" class="flex-1 py-2.5 text-sm font-bold text-white bg-red-500 hover:bg-red-600 rounded-xl shadow-lg shadow-red-500/20 transition-all">Ya, Hapus</button>
                </div>
            </div>
        </div>

    </div>
</x-app-layout>