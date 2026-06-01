<head>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <style>
        [x-cloak] { display: none !important; }
        
        @keyframes pulse-glow {
            0%, 100% { box-shadow: 0 0 20px rgba(255, 114, 58, 0.3); }
            50% { box-shadow: 0 0 40px rgba(255, 114, 58, 0.6); }
        }
        .evaluating { animation: pulse-glow 1.5s ease-in-out infinite; }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<x-app-layout>
    <x-slot name="header">
        Halaman Testing & Evaluasi Model
    </x-slot>

    <div x-data='testingDashboard(@json($routes))' class="max-w-7xl mx-auto space-y-6" x-cloak>

        {{-- Header --}}
        <div class="mb-8">
            <h1 class="text-3xl font-extrabold tracking-tight text-white mb-6">
                Halaman <span class="text-[#FF723A]">Testing</span>
            </h1>
            <div class="flex space-x-2 bg-neutral-900/50 p-1 rounded-xl w-max border border-neutral-800">
                <button @click="activeTab = 'evaluasi'" 
                        :class="activeTab === 'evaluasi' ? 'bg-[#FF723A] text-white shadow-lg' : 'text-neutral-400 hover:text-white'" 
                        class="px-6 py-2.5 rounded-lg font-bold transition-all flex items-center gap-2">
                    <i class="fas fa-microchip"></i> Evaluasi Model
                </button>
                <button @click="activeTab = 'api'" 
                        :class="activeTab === 'api' ? 'bg-[#FF723A] text-white shadow-lg' : 'text-neutral-400 hover:text-white'" 
                        class="px-6 py-2.5 rounded-lg font-bold transition-all flex items-center gap-2">
                    <i class="fas fa-satellite-dish"></i> API Tester
                </button>
            </div>
        </div>

        {{-- ==================== TAB EVALUASI ==================== --}}
        <div x-show="activeTab === 'evaluasi'" x-transition>
            
            {{-- Panel Kontrol --}}
            <div class="bg-neutral-900 border border-neutral-800 rounded-2xl p-6 mb-6 shadow-xl flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
                <div>
                    <h2 class="text-xl font-bold text-white mb-1">
                        <i class="fas fa-flask text-[#FF723A] mr-2"></i>Uji Akurasi Model
                    </h2>
                </div>
                <button @click="runEvaluasi()" 
                        :disabled="isTesting" 
                        class="bg-blue-600 hover:bg-blue-500 text-white px-8 py-3 rounded-xl font-bold transition-all disabled:opacity-50 flex items-center gap-2">
                    <i class="fas" :class="isTesting ? 'fa-spinner fa-spin' : 'fa-play'"></i>
                    <span x-text="isTesting ? 'Sedang Menguji...' : 'Jalankan Pengujian'"></span>
                </button>
            </div>

            {{-- Loading State --}}
            <div x-show="isTesting" class="text-center py-12">
                <div class="inline-block bg-neutral-900 border border-neutral-800 rounded-2xl p-8">
                    <i class="fas fa-spinner fa-spin text-4xl text-[#FF723A] mb-4"></i>
                    <p class="text-neutral-400">Model sedang mengevaluasi data uji...</p>
                    <p class="text-xs text-neutral-600 mt-2">Proses ini mungkin memakan waktu beberapa saat</p>
                </div>
            </div>

            {{-- Error State --}}
            <div x-show="evalError" x-transition class="bg-red-500/10 border border-red-500/30 rounded-2xl p-6">
                <div class="flex items-center gap-2 text-red-400">
                    <i class="fas fa-exclamation-triangle"></i>
                    <span x-text="evalError"></span>
                </div>
            </div>

            {{-- Hasil Evaluasi --}}
            <template x-if="evalResult && evalResult.status === 'success'">
                <div class="space-y-6">
                    
                    {{-- Ringkasan Metrik Utama --}}
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div class="bg-gradient-to-br from-neutral-800 to-neutral-900 rounded-2xl border border-neutral-700 p-6 text-center">
                            <i class="fas fa-chart-line text-3xl text-blue-400 mb-3"></i>
                            <p class="text-neutral-400 text-sm">Precision@K</p>
                            <p class="text-4xl font-bold text-white mt-2" x-text="evalResult.ringkasan?.akurasi?.toFixed(2) + '%' ?? '0%'"></p>
                            <p class="text-xs text-neutral-500 mt-1">Rata-rata rekomendasi relevan di top-K</p>
                        </div>
                        <div class="bg-gradient-to-br from-neutral-800 to-neutral-900 rounded-2xl border border-neutral-700 p-6 text-center">
                            <i class="fas fa-chart-simple text-3xl text-green-400 mb-3"></i>
                            <p class="text-neutral-400 text-sm">Recall@K</p>
                            <p class="text-4xl font-bold text-white mt-2" x-text="evalResult.ringkasan?.recall?.toFixed(2) + '%' ?? '0%'"></p>
                            <p class="text-xs text-neutral-500 mt-1">Persentase total relevan yang tertangkap</p>
                        </div>
                        <div class="bg-gradient-to-br from-neutral-800 to-neutral-900 rounded-2xl border border-neutral-700 p-6 text-center">
                            <i class="fas fa-database text-3xl text-purple-400 mb-3"></i>
                            <p class="text-neutral-400 text-sm">Total Data Uji</p>
                            <p class="text-4xl font-bold text-white mt-2" x-text="evalResult.ringkasan?.total_data_diproses ?? 0"></p>
                            <p class="text-xs text-neutral-500 mt-1">Resep yang dievaluasi</p>
                        </div>
                    </div>


                    {{-- Detail Hasil (tabel murni rekomendasi) --}}
                    <template x-if="evalResult.detail_hasil && evalResult.detail_hasil.length > 0">
                        <div class="bg-neutral-900 border border-neutral-800 rounded-2xl overflow-hidden mt-6">
                            <div class="p-4 border-b border-neutral-800 flex justify-between items-center">
                                <h3 class="text-lg font-bold text-white flex items-center gap-2">
                                    <i class="fas fa-table text-blue-400"></i> Detail Hasil Rekomendasi
                                </h3>
                                <span class="text-sm text-neutral-400">
                                    Total: <span class="text-white font-bold" x-text="safeArrayData.length"></span> data
                                </span>
                            </div>
                            <div class="overflow-x-auto">
                                <table class="w-full text-left text-sm">
                                    <thead class="bg-neutral-800/50 text-neutral-300">
                                        <tr>
                                            <th class="px-4 py-3 w-12">#</th>
                                            <th class="px-4 py-3">Input Bahan</th>
                                            <th class="px-4 py-3">Rekomendasi Teratas</th>
                                            <th class="px-4 py-3">Similarity</th>
                                            <th class="px-4 py-3 text-center">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-neutral-800">
                                        <template x-for="item in paginatedResults" :key="item.no">
                                            <tr class="hover:bg-neutral-800/20">
                                                <td class="px-4 py-3 text-neutral-500" x-text="item.no"></td>
                                                <td class="px-4 py-3 text-white max-w-xs truncate" :title="item.soal" x-text="item.soal"></td>
                                                <td class="px-4 py-3 font-bold text-[#FF723A]" x-text="item.rekomendasi"></td>
                                                <td class="px-4 py-3 text-neutral-400" x-text="(item.similarity ?? 0).toFixed(1) + '%'"></td>
                                                <td class="px-4 py-3 text-center">
                                                    <span :class="item.status === 'Relevan' ? 'bg-green-500/10 text-green-400 border-green-500/30' : 'bg-red-500/10 text-red-400 border-red-500/30'"
                                                          class="px-2 py-1 border rounded text-xs font-bold"
                                                          x-text="item.status"></span>
                                                </td>
                                            </tr>
                                        </template>
                                    </tbody>
                                </table>
                            </div>
                            
                            {{-- Pagination --}}
                            <div x-show="safeArrayData.length > 0" 
                                 class="p-4 border-t border-neutral-800 bg-neutral-800/30 flex flex-col sm:flex-row justify-between items-center gap-4">
                                <span class="text-sm text-neutral-400">
                                    Halaman <span x-text="currentPage" class="font-bold text-white"></span> 
                                    dari <span x-text="totalPages" class="font-bold text-white"></span>
                                </span>
                                <div class="flex space-x-2">
                                    <button @click="prevPage()" 
                                            :disabled="currentPage === 1" 
                                            class="px-4 py-2 bg-neutral-800 border border-neutral-700 hover:bg-neutral-700 hover:text-white disabled:opacity-50 disabled:cursor-not-allowed text-neutral-400 rounded-lg text-sm font-bold transition-all">
                                        <i class="fas fa-chevron-left mr-1"></i> Prev
                                    </button>
                                    <button @click="nextPage()" 
                                            :disabled="currentPage === totalPages" 
                                            class="px-4 py-2 bg-neutral-800 border border-neutral-700 hover:bg-neutral-700 hover:text-white disabled:opacity-50 disabled:cursor-not-allowed text-neutral-400 rounded-lg text-sm font-bold transition-all">
                                        Next <i class="fas fa-chevron-right ml-1"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </template>

                </div>
            </template>

        </div>

        {{-- ==================== TAB API TESTER ==================== --}}
        <div x-show="activeTab === 'api'" x-transition class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div class="bg-neutral-900 border border-neutral-800 rounded-2xl p-6 flex flex-col gap-4">
                
                <div class="flex flex-col gap-2">
                    <label class="text-xs font-bold text-neutral-500 uppercase">1. Pilih Method</label>
                    <div class="flex gap-2">
                        <template x-for="item in [
                            {m: 'GET', d: 'Ambil Data'}, 
                            {m: 'POST', d: 'Simpan Baru'}, 
                            {m: 'PUT', d: 'Update/Edit'}, 
                            {m: 'DELETE', d: 'Hapus Data'}
                        ]">
                            <button @click="apiMethod = item.m; filterUrls()" 
                                :class="apiMethod === item.m ? 'bg-[#FF723A] text-white shadow-lg shadow-[#FF723A]/20' : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'"
                                class="flex-1 py-2 px-1 rounded-lg transition-all flex flex-col items-center justify-center gap-1 border border-neutral-700">
                                <span class="font-bold text-sm" x-text="item.m"></span>
                                <span class="text-[10px] opacity-80" x-text="item.d"></span>
                            </button>
                        </template>
                    </div>
                </div>

                <div class="flex flex-col gap-2">
                    <label class="text-xs font-bold text-neutral-500 uppercase">2. Pilih API</label>
                    <select x-model="apiUrl" @change="updateBody()" class="w-full bg-neutral-800 border border-neutral-700 text-white rounded-xl p-3 focus:border-[#FF723A] outline-none">
                        <option value="">-- Pilih Endpoint --</option>
                        <template x-for="route in filteredRoutes" :key="route.uri">
                            <option :value="route.uri" x-text="route.uri"></option>
                        </template>
                    </select>
                </div>

                <div class="flex flex-col gap-2">
                    <label class="text-xs font-bold text-neutral-500 uppercase">3. URL (Edit kalau butuh ID)</label>
                    <input type="text" x-model="apiUrl" class="w-full bg-neutral-800 border border-neutral-700 text-white rounded-xl p-3" placeholder="/api/endpoint">
                </div>

                <div x-show="apiMethod !== 'GET' && apiMethod !== 'DELETE'">
                    <label class="text-xs font-bold text-neutral-500 uppercase mb-2 block">4. Request Body</label>
                    <textarea x-model="apiBody" rows="8" class="w-full bg-neutral-950 border border-neutral-700 text-[#a6e22e] font-mono text-sm rounded-xl p-4 focus:border-[#FF723A] outline-none"></textarea>
                </div>
                
                <button @click="sendApiRequest()" :disabled="isLoadingApi" class="w-full py-4 bg-[#FF723A] text-white rounded-xl font-bold flex justify-center items-center gap-2 shadow-lg shadow-[#FF723A]/20 transition-all active:scale-95 hover:bg-[#ff8c5a]">
                    <i class="fas" :class="isLoadingApi ? 'fa-spinner fa-spin' : 'fa-paper-plane'"></i> Kirim Request
                </button>
            </div>

            <div class="bg-neutral-900 border border-neutral-800 rounded-2xl flex flex-col overflow-hidden shadow-2xl">
                <div class="p-4 border-b border-neutral-800 bg-neutral-800/30 flex justify-between items-center">
                    <h3 class="font-bold text-white">Hasil Response</h3>
                    <div class="flex items-center gap-2">
                        <span x-show="apiStatus" 
                              :class="apiStatus?.includes('20') ? 'text-green-400' : 'text-red-400'" 
                              class="font-mono text-sm font-bold bg-black/30 px-3 py-1 rounded-full border border-white/5" 
                              x-text="apiStatus"></span>
                    </div>
                </div>
                <div class="p-4 flex-1 bg-neutral-950 overflow-auto min-h-[450px]">
                    <pre class="text-sm font-mono text-[#66d9ef] whitespace-pre-wrap" x-text="apiResponse || '// Hasil dari API akan muncul di sini...'"></pre>
                </div>
            </div>
        </div>
    </div>

    {{-- ==================== ALPINE.JS ==================== --}}
    <script>
        document.addEventListener('alpine:init', () => {
            Alpine.data('testingDashboard', (allRoutes) => ({
                activeTab: 'evaluasi',
                routes: allRoutes,
                filteredRoutes: [],
                
                // API Tester
                apiMethod: 'GET',
                apiUrl: '',
                apiBody: '',
                apiResponse: '',
                apiStatus: '',
                isLoadingApi: false,

                // Evaluasi
                isTesting: false,
                evalResult: null,
                evalError: null,
                currentPage: 1,
                itemsPerPage: 10,

                init() {
                    this.filterUrls();
                },

                getPersentase(nilai, total) {
                    if (!total || total === 0) return '0%';
                    return ((nilai / total) * 100).toFixed(1) + '% dari total';
                },

                // ============ PAGINATION ============
                get safeArrayData() {
                    if (!this.evalResult?.detail_hasil) return [];
                    let data = this.evalResult.detail_hasil;
                    if (typeof data === 'string') {
                        try { data = JSON.parse(data); } catch(e) { return []; }
                    }
                    return Array.isArray(data) ? data : [];
                },

                get paginatedResults() {
                    const start = (this.currentPage - 1) * this.itemsPerPage;
                    return this.safeArrayData.slice(start, start + this.itemsPerPage);
                },

                get totalPages() {
                    return Math.max(1, Math.ceil(this.safeArrayData.length / this.itemsPerPage));
                },

                nextPage() {
                    if (this.currentPage < this.totalPages) this.currentPage++;
                },

                prevPage() {
                    if (this.currentPage > 1) this.currentPage--;
                },

                // ============ API TESTER ============
                filterUrls() {
                    this.filteredRoutes = this.routes.filter(r => r.method === this.apiMethod);
                    this.apiUrl = ''; 
                    this.apiBody = '';
                    this.apiResponse = '';
                    this.apiStatus = '';
                },

                updateBody() {
                    const url = this.apiUrl;
                    if(this.apiMethod === 'GET' || this.apiMethod === 'DELETE') {
                        this.apiBody = "";
                        return;
                    }

                    if(url.includes('rekomendasi')) {
                        this.apiBody = JSON.stringify({ message: "aku punya ayam dan bawang" }, null, 4);
                    } else if(url.includes('login')) {
                        this.apiBody = JSON.stringify({ email: "userflutter@cookcash.com", password: "password123" }, null, 4);
                    } else if(url.includes('resep')) {
                        this.apiBody = JSON.stringify({ 
                            "Title Cleaned": "Ayam Goreng Spesial",
                            "Category": "ayam",
                            "Ingredients Cleaned": "ayam, bawang putih, garam",
                            "Steps": "Masak sampai matang."
                        }, null, 4);
                    } else {
                        this.apiBody = "{\n  \"key\": \"value\"\n}";
                    }
                },

                async sendApiRequest() {
                    if(!this.apiUrl) return alert("Pilih URL dulu!");
                    this.isLoadingApi = true;
                    this.apiResponse = "// Menghubungi server...";
                    
                    try {
                        const response = await fetch(this.apiUrl, {
                            method: this.apiMethod,
                            headers: { 
                                'Content-Type': 'application/json', 
                                'Accept': 'application/json',
                                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.content
                            },
                            body: (this.apiMethod !== 'GET' && this.apiMethod !== 'DELETE') ? this.apiBody : null
                        });
                        
                        this.apiStatus = response.status + ' ' + response.statusText;
                        const data = await response.json();
                        this.apiResponse = JSON.stringify(data, null, 4);
                    } catch (e) {
                        this.apiStatus = "Error";
                        this.apiResponse = "Gagal memproses request: " + e.message;
                    } finally {
                        this.isLoadingApi = false;
                    }
                },

                // ============ EVALUASI ============
                async runEvaluasi() {
                    this.isTesting = true;
                    this.evalResult = null;
                    this.evalError = null;
                    this.currentPage = 1;
                    
                    try {
                        const res = await fetch('/api/chatbot/evaluasi', { 
                            method: 'POST',
                            headers: { 
                                'Accept': 'application/json',
                                'Content-Type': 'application/json',
                                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.content
                            }
                        });
                        
                        if (!res.ok) {
                            throw new Error(`HTTP Error: ${res.status} ${res.statusText}`);
                        }
                        
                        const data = await res.json();
                        
                        if (data.status === 'error') {
                            this.evalError = data.message || 'Error dari server';
                            return;
                        }
                        
                        if (data.status === 'success') {
                            this.evalResult = data;
                        } else {
                            throw new Error('Status response tidak dikenali: ' + data.status);
                        }
                        
                    } catch (e) {
                        console.error(e);
                        this.evalError = "Gagal: " + e.message;
                        this.evalResult = null;
                    } finally {
                        this.isTesting = false;
                    }
                }
            }));
        });
    </script>
</x-app-layout>