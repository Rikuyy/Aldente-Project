<x-app-layout>
    <div class="py-10">
        <div class="max-w-4xl mx-auto sm:px-6 lg:px-8">
            
            <div class="mb-8">
                <h2 class="text-2xl font-bold text-white tracking-wide flex items-center gap-2">
                    <svg class="w-6 h-6 text-[#FF723A]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path></svg>
                    Halaman Pengujian API (API Tester)
                </h2>
                <p class="text-sm text-neutral-400 mt-1">
                    Gunakan halaman ini untuk mendemonstrasikan hasil balasan JSON dari API secara langsung tanpa aplikasi eksternal (Postman).
                </p>
            </div>

            <div class="bg-neutral-950 border border-neutral-800 rounded-2xl overflow-hidden shadow-lg mb-6">
                
                <div class="p-6 border-b border-neutral-800 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                    <div>
                        <h3 class="text-lg font-bold text-white flex items-center gap-2">
                            Test API Resep
                        </h3>
                        <div class="mt-2 flex items-center gap-2">
                            <span class="px-2 py-0.5 rounded text-xs font-bold bg-[#FF723A]/10 text-[#FF723A] border border-[#FF723A]/20">
                                GET
                            </span>
                            <code class="text-sm text-neutral-300 font-mono">/api/resep</code>
                        </div>
                    </div>

                    <button id="btn-test-resep" onclick="jalankanTest()" class="px-5 py-2.5 bg-[#FF723A] hover:bg-[#E56634] text-white text-sm rounded-xl font-bold transition-all shadow-[0_0_15px_rgba(255,114,58,0.2)] hover:shadow-[0_0_20px_rgba(255,114,58,0.4)] flex items-center gap-2 w-full md:w-auto justify-center">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                        <span id="text-btn-resep">Jalankan Test (Send)</span>
                    </button>
                </div>

                <div class="bg-[#0D0D0E] p-4 relative">
                    <div class="absolute top-0 left-0 w-full flex justify-between items-center px-4 py-1.5 bg-[#18181A] border-b border-neutral-800 text-xs font-mono">
                        <div class="flex items-center gap-2 text-neutral-500">
                            <div class="w-2.5 h-2.5 rounded-full bg-red-500/80"></div>
                            <div class="w-2.5 h-2.5 rounded-full bg-yellow-500/80"></div>
                            <div class="w-2.5 h-2.5 rounded-full bg-green-500/80"></div>
                            <span class="ml-2">Response Output</span>
                        </div>
                        <span id="status-code" class="text-neutral-500">Status: Menunggu...</span>
                    </div>

                    <pre id="output-layar" class="text-green-400 font-mono text-sm pt-8 pb-4 px-2 h-72 overflow-y-auto whitespace-pre-wrap break-words">
Menunggu instruksi... 
Silakan klik tombol "Jalankan Test" di atas untuk menembak API.
                    </pre>
                </div>

            </div>

        </div>
    </div>

    <script>
        async function jalankanTest() {
            const btn = document.getElementById('btn-test-resep');
            const textBtn = document.getElementById('text-btn-resep');
            const layarOutput = document.getElementById('output-layar');
            const statusCode = document.getElementById('status-code');

            // 1. Ubah tampilan tombol & layar jadi proses loading
            textBtn.innerText = "Loading...";
            btn.disabled = true;
            btn.classList.add('opacity-70', 'cursor-not-allowed');
            layarOutput.innerText = "Menembak URL http://127.0.0.1:8000/api/resep ...\nMenunggu balasan dari server...";
            layarOutput.classList.replace('text-green-400', 'text-yellow-400');
            statusCode.innerText = "Status: Fetching...";

            try {
                // 2. Nembak API diem-diem pake FETCH
                const response = await fetch('/api/resep');
                const data = await response.json();

                // 3. Tampilkan Status Code HTTP
                if (response.ok) {
                    statusCode.innerText = `Status: ${response.status} OK`;
                    statusCode.className = "text-green-400 font-bold";
                    layarOutput.classList.replace('text-yellow-400', 'text-green-400');
                    layarOutput.classList.replace('text-red-400', 'text-green-400');
                } else {
                    statusCode.innerText = `Status: ${response.status} Error`;
                    statusCode.className = "text-red-400 font-bold";
                    layarOutput.classList.replace('text-yellow-400', 'text-red-400');
                }

                // 4. Ubah format JSON ke string dengan indentasi
                layarOutput.innerText = JSON.stringify(data, null, 4);

            } catch (error) {
                // 5. Kalau servernya mati atau error jaringan
                statusCode.innerText = "Status: Connection Failed";
                statusCode.className = "text-red-500 font-bold";
                layarOutput.classList.replace('text-yellow-400', 'text-red-400');
                layarOutput.innerText = "ERROR: Gagal terhubung ke API.\n\nPesan Error:\n" + error.message;
            } finally {
                // 6. Kembalikan tombol ke bentuk semula
                textBtn.innerText = "Jalankan Test (Send)";
                btn.disabled = false;
                btn.classList.remove('opacity-70', 'cursor-not-allowed');
            }
        }
    </script>
</x-app-layout>