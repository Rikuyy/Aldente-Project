<head>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>

<x-app-layout>
    <x-slot name="header">
        Halaman Testing
    </x-slot>

    <div x-data='testingDashboard(@json($routes))' class="max-w-7xl mx-auto space-y-6" x-cloak>

        <div class="mb-8">
            <h1 class="text-3xl font-extrabold tracking-tight text-white mb-6">
                Halaman <span class="text-[#FF723A]">Testing</span>
            </h1>
            <div class="flex space-x-2 bg-neutral-900/50 p-1 rounded-xl w-max border border-neutral-800">
                <button @click="activeTab = 'evaluasi'" :class="activeTab === 'evaluasi' ? 'bg-[#FF723A] text-white shadow-lg' : 'text-neutral-400 hover:text-white'" class="px-6 py-2.5 rounded-lg font-bold transition-all flex items-center gap-2">
                    <i class="fas fa-microchip"></i> Evaluasi AI
                </button>
                <button @click="activeTab = 'api'" :class="activeTab === 'api' ? 'bg-[#FF723A] text-white shadow-lg' : 'text-neutral-400 hover:text-white'" class="px-6 py-2.5 rounded-lg font-bold transition-all flex items-center gap-2">
                    <i class="fas fa-satellite-dish"></i> API Tester
                </button>
            </div>
        </div>

        <div x-show="activeTab === 'evaluasi'" x-transition>
            <div class="bg-neutral-900 border border-neutral-800 rounded-2xl p-6 mb-6 shadow-xl flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
                <div>
                    <h2 class="text-xl font-bold text-white mb-1">Uji Akurasi Data Test</h2>
                    <p class="text-sm text-neutral-400">Mengetes otak AI (.pkl) dengan soal ujian (.csv).</p>
                </div>
                <button @click="runEvaluasi()" :disabled="isTesting" class="bg-blue-600 hover:bg-blue-500 text-white px-6 py-3 rounded-xl font-bold transition-all disabled:opacity-50 flex items-center gap-2">
                    <i class="fas" :class="isTesting ? 'fa-spinner fa-spin' : 'fa-play'"></i>
                    <span x-text="isTesting ? 'Sedang Menguji...' : 'Jalankan Pengujian'"></span>
                </button>
            </div>

            <div x-show="evalResult !== null" class="space-y-6" style="display:none;">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 border-l-4 border-l-green-500">
                        <p class="text-neutral-400 text-sm mb-1">Tingkat Akurasi</p>
                        <h3 class="text-3xl font-bold text-white"><span x-text="evalResult?.akurasi"></span>%</h3>
                    </div>
                    <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 border-l-4 border-l-blue-500">
                        <p class="text-neutral-400 text-sm mb-1">Total Data Uji</p>
                        <h3 class="text-3xl font-bold text-white" x-text="evalResult?.total_uji"></h3>
                    </div>
                    <div class="bg-neutral-900 p-6 rounded-2xl border border-neutral-800 border-l-4 border-l-pink-500">
                        <p class="text-neutral-400 text-sm mb-1">Prediksi Benar</p>
                        <h3 class="text-3xl font-bold text-white" x-text="evalResult?.prediksi_benar"></h3>
                    </div>
                </div>

                <div class="bg-neutral-900 border border-neutral-800 rounded-2xl overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-sm text-neutral-400">
                            <thead class="bg-neutral-800/50 text-neutral-300 border-b border-neutral-800">
                                <tr>
                                    <th class="px-6 py-3 font-bold">Input Resep/Bahan</th>
                                    <th class="px-6 py-3 font-bold">Target Asli</th>
                                    <th class="px-6 py-3 font-bold">Tebakan AI</th>
                                    <th class="px-6 py-3 font-bold text-center">Status</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-neutral-800">
                                <template x-for="(item, index) in evalResult?.detail_hasil" :key="index">
                                    <tr class="hover:bg-neutral-800/20">
                                        <td class="px-6 py-3 text-white font-medium" x-text="item.soal"></td>
                                        <td class="px-6 py-3" x-text="item.target"></td>
                                        <td class="px-6 py-3 font-bold" :class="item.status === 'Benar' ? 'text-green-500' : 'text-red-500'" x-text="item.prediksi"></td>
                                        <td class="px-6 py-3 text-center">
                                            <span :class="item.status === 'Benar' ? 'bg-green-500/10 text-green-500' : 'bg-red-500/10 text-red-500'" class="px-2 py-1 border rounded text-xs font-bold" x-text="item.status"></span>
                                        </td>
                                    </tr>
                                </template>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div x-show="activeTab === 'api'" x-transition style="display:none;" class="grid grid-cols-1 lg:grid-cols-2 gap-6">
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
                    <label class="text-xs font-bold text-neutral-500 uppercase">2. Pilih API (Otomatis dari api.php)</label>
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
                    <label class="text-xs font-bold text-neutral-500 uppercase mb-2 block">4. Request Body (Otomatis Menyesuaikan)</label>
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
                        <span x-show="apiStatus" :class="apiStatus?.includes('20') ? 'text-green-400' : 'text-red-400'" class="font-mono text-sm font-bold bg-black/30 px-3 py-1 rounded-full border border-white/5" x-text="apiStatus"></span>
                    </div>
                </div>
                <div class="p-4 flex-1 bg-neutral-950 overflow-auto min-h-[450px]">
                    <pre class="text-sm font-mono text-[#66d9ef] whitespace-pre-wrap" x-text="apiResponse || '// Hasil dari API akan muncul di sini...'"></pre>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('alpine:init', () => {
            Alpine.data('testingDashboard', (allRoutes) => ({
                activeTab: 'evaluasi',
                routes: allRoutes,
                filteredRoutes: [],
                
                apiMethod: 'GET',
                apiUrl: '',
                apiBody: '',
                apiResponse: '',
                apiStatus: '',
                isLoadingApi: false,

                init() {
                    this.filterUrls();
                },

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
                        this.apiBody = JSON.stringify({ 
                            message: "aku punya ayam dan bawang" 
                        }, null, 4);
                    } 
                    else if(url.includes('login')) {
                        this.apiBody = JSON.stringify({ 
                            email: "userflutter@cookcash.com",
                            password: "password123"
                        }, null, 4);
                    }
                    else if(url.includes('resep')) {
                        this.apiBody = JSON.stringify({ 
                            "Title Cleaned": "Ayam Goreng Spesial",
                            "Category": "ayam",
                            "Ingredients Cleaned": "ayam, bawang putih, garam, ketumbar",
                            "Steps": "1. Cuci ayam. 2. Ungkep dengan bumbu. 3. Goreng."
                        }, null, 4);
                    }
                    else {
                        this.apiBody = "{\n  \"key\": \"value\"\n}";
                    }
                },

                async sendApiRequest() {
                    if(!this.apiUrl) {
                        alert("Pilih atau isi URL dulu!");
                        return;
                    }

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

                isTesting: false,
                evalResult: null,
                async runEvaluasi() {
                    this.isTesting = true;
                    this.evalResult = null;
                    try {
                        const res = await fetch('/api/chatbot/evaluasi', { 
                            method: 'POST',
                            headers: { 'Accept': 'application/json' }
                        });
                        this.evalResult = await res.json();
                    } catch (e) {
                        alert("Gagal koneksi ke server Python/API!");
                    } finally {
                        this.isTesting = false;
                    }
                }
            }));
        });
    </script>
</x-app-layout>