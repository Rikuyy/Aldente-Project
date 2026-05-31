<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Keuangan;
use App\Models\JadwalMakan;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;
use MongoDB\BSON\ObjectId;

class KeuanganController extends Controller
{
    public function ringkasan(Request $request): JsonResponse
    {
        try {
            $pengguna = $request->user();
            $idPengguna = $pengguna->id ?? $pengguna->_id; 
            $sekarang   = Carbon::now('Asia/Jakarta');

            // 1. SIKLUS BUDGET & PERHITUNGAN HARI DINAMIS
            $tanggalMulaiStr = $pengguna->Tanggal_Mulai_Siklus ?? $pengguna->created_at;
            $tanggalMulai    = Carbon::parse($tanggalMulaiStr)->startOfDay();
            
            // Mencegah overflow (misal 31 Januari tidak akan jadi 3 Maret)
            $targetBulanDepan = $tanggalMulai->copy()->addMonthNoOverflow()->startOfDay();

            // Pengecekan Pintar Top Up Manual (Auto Geser Siklus)
            $topUpBaru = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pemasukan')
                ->where('Keterangan', 'Top Up')
                ->whereDate('Tanggal', '>=', $targetBulanDepan->toDateString())
                ->orderBy('Tanggal', 'asc')
                ->first();

            if ($topUpBaru) {
                // Geser tanggal siklus user ke tanggal top-up manual
                $pengguna->Tanggal_Mulai_Siklus = Carbon::parse($topUpBaru->Tanggal)->toDateString();
                $pengguna->save();

                $tanggalMulai = Carbon::parse($pengguna->Tanggal_Mulai_Siklus)->startOfDay();
                $targetBulanDepan = $tanggalMulai->copy()->addMonthNoOverflow()->startOfDay();
            }
            
            $akhirSiklus = $targetBulanDepan->copy()->subDay()->endOfDay();
            $totalHariSiklus = max($tanggalMulai->diffInDays($targetBulanDepan), 1);
            $hariKe = max($tanggalMulai->diffInDays($sekarang->copy()->startOfDay()) + 1, 1);

            // =========================================================================
            // REVISI LOGIKA 1: SALDO KUMULATIF (SEPANJANG MASA, TIDAK DI-RESET)
            // =========================================================================
            $totalPemasukanAllTime = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pemasukan')
                ->sum('Total_Nominal');

            // Cek apakah user sudah mencatat pemasukan di hari pertama daftar
            $adaPemasukanAwal = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pemasukan')
                ->whereDate('Tanggal', Carbon::parse($pengguna->created_at)->toDateString())
                ->exists();

            // Jika tidak ada riwayat top-up awal, jadikan Budget_Bulanan sebagai "Modal Virtual Awal"
            if (!$adaPemasukanAwal) {
                $totalPemasukanAllTime += ($pengguna->Budget_Bulanan ?? 0);
            }

            $totalPengeluaranAllTime = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pengeluaran')
                ->sum('Total_Nominal');

            // INI ADALAH SALDO ASLI YANG AKAN TERUS TERAKUMULASI (Tidak hangus)
            $saldoKumulatif = max($totalPemasukanAllTime - $totalPengeluaranAllTime, 0);


            // =========================================================================
            // REVISI LOGIKA 2: IKHTISAR SIKLUS INI (HANYA UNTUK INFO UI BULANAN)
            // =========================================================================
            $totalPemasukanSiklus = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pemasukan')
                ->whereBetween('Tanggal', [$tanggalMulai->toDateString(), $akhirSiklus->toDateString()])
                ->sum('Total_Nominal');

            // Fallback UI: Jika siklus pertama belum ada mutasi Top Up
            if ($totalPemasukanSiklus == 0 && $tanggalMulai->toDateString() == Carbon::parse($pengguna->created_at)->startOfDay()->toDateString()) {
                $totalPemasukanSiklus = $pengguna->Budget_Bulanan ?? 0;
            }

            $totalPengeluaranSiklus = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pengeluaran')
                ->whereBetween('Tanggal', [$tanggalMulai->toDateString(), $akhirSiklus->toDateString()])
                ->sum('Total_Nominal');


            // =========================================================================
            // REVISI LOGIKA 3: BUDGET PER HARI MENGGUNAKAN UANG YANG BENAR-BENAR NYISA
            // =========================================================================
            $sisaHariAktif = max($totalHariSiklus - $hariKe + 1, 1);
            $sisaBudgetPerHari = round($saldoKumulatif / $sisaHariAktif);

            // KOMPOSISI PENGELUARAN SIKLUS INI (Untuk Pie Chart)
            $pengeluaranItems = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pengeluaran')
                ->whereBetween('Tanggal', [$tanggalMulai->toDateString(), $akhirSiklus->toDateString()])
                ->get();
            
            $totalBeli  = (float) $pengeluaranItems->where('Keterangan', 'Beli')->sum('Total_Nominal');
            $totalMasak = (float) $pengeluaranItems->where('Keterangan', 'Masak')->sum('Total_Nominal');
            $totalKomposisi = $totalBeli + $totalMasak;
            $persenBeli  = $totalKomposisi > 0 ? round(($totalBeli  / $totalKomposisi) * 100) : 0;
            $persenMasak = $totalKomposisi > 0 ? round(($totalMasak / $totalKomposisi) * 100) : 0;

            return response()->json([
                'success' => true,
                'message' => 'Ringkasan keuangan berhasil diambil.',
                'data'    => [
                    'data' => [
                        'saldo'                  => (double) $saldoKumulatif, // Saldo All Time
                        'total_pemasukan'        => (double) $totalPemasukanSiklus, // Pemasukan bulan ini saja
                        'total_pengeluaran'      => (double) $totalPengeluaranSiklus, // Pengeluaran bulan ini saja
                        'rata_per_hari'          => 0, 
                        'prediksi_akhir_bulan'   => 0, 
                        'prediksi_defisit'       => false,
                        'pesan_prediksi'         => '',
                        'persen_masak'           => (int) $persenMasak,
                        'komposisi'              => [
                            ['kategori' => 'Beli di Luar',  'jumlah' => (double) $totalBeli,  'persen' => $persenBeli,  'warna' => 'blue'],
                            ['kategori' => 'Masak Sendiri', 'jumlah' => (double) $totalMasak, 'persen' => $persenMasak, 'warna' => 'orange'],
                        ],
                        'budget_per_hari'        => (double) $sisaBudgetPerHari, // Dibagi berdasarkan sisa hari
                        'pengeluaran_hari_ini'   => 0,
                        'is_overbudget_hari_ini' => false, // Fitur warning ditiadakan
                        'overbudget_amount'      => 0,
                        'sisa_budget_per_hari'   => (double) $sisaBudgetPerHari,
                        'is_sisa_tipis'          => false, // Fitur warning ditiadakan
                    ]
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function grafik(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $userId = $user->id ?? $user->_id;
            
            // Perbaikan Grafik: Gunakan bulan dari parameter filter agar tidak nyangkut di bulan pendaftaran
            $bulanQuery = $request->query('bulan', Carbon::now('Asia/Jakarta')->format('Y-m'));
            $parsed     = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate  = $parsed->copy()->startOfMonth()->toDateString();
            $endDate    = $parsed->copy()->endOfMonth()->toDateString();

            $transaksis = Keuangan::where('Id_User', (string) $userId)
                ->where('Kategori', 'Pengeluaran')
                ->whereBetween('Tanggal', [$startDate, $endDate])
                ->get();

            $grouped = $transaksis->groupBy('Tanggal')
                ->map(fn($items) => $items->sum('Total_Nominal'));

            $dataGrafik = [];
            for ($hari = 1; $hari <= $parsed->daysInMonth; $hari++) {
                $tanggal      = $parsed->copy()->day($hari)->toDateString();
                $dataGrafik[] = [
                    'tanggal' => $tanggal,
                    'hari'    => $hari,
                    'jumlah'  => (double) ($grouped[$tanggal] ?? 0),
                ];
            }

            return response()->json([
                'success' => true,
                'message' => 'Data grafik keuangan berhasil diambil.',
                'data'    => [
                    'bulan'       => $bulanQuery,
                    'per_tanggal' => $dataGrafik,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Grafik error: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function mutasi(Request $request): JsonResponse
    {
        try {
            $userId  = $request->user()->id ?? $request->user()->_id;
            $page    = max(1, (int) $request->query('page', 1));
            $perPage = max(1, min(50, (int) $request->query('per_page', 10)));

            $query = Keuangan::where('Id_User', (string) $userId);

            if ($request->filled('tahun') && $request->tahun != 0) {
                $tahun = (int) $request->tahun;
                $query->where('Tanggal', 'regex', "/^{$tahun}-/");
            }
            if ($request->filled('bulan')) {
                $bulanStr = str_pad((int) $request->bulan, 2, '0', STR_PAD_LEFT);
                $query->where('Tanggal', 'regex', "/-{$bulanStr}-/");
            }

            $transaksis = $query->orderBy('Tanggal', 'desc')
                                ->orderBy('Waktu', 'desc')
                                ->get();

            $formatted = [];
            foreach ($transaksis as $trans) {
                $item = $this->formatKeuangan($trans);
                if (!empty($trans->Id_JadwalMakan)) {
                    try {
                        $jadwal = JadwalMakan::with('resep')
                            ->where('_id', new ObjectId($trans->Id_JadwalMakan))
                            ->first();
                        if ($jadwal) {
                            $item['sesi_makan'] = $jadwal->{'Sesi Makan'} ?? '';
                            $item['nama_resep'] = $jadwal->resep->title ?? '';
                            $item['resep_id']   = (string) $jadwal->Id_Resep;
                        } else {
                            $item['sesi_makan'] = '';
                            $item['nama_resep'] = '';
                            $item['resep_id']   = '';
                        }
                    } catch (\Exception $e) {
                        $item['sesi_makan'] = '';
                        $item['nama_resep'] = '';
                        $item['resep_id']   = '';
                    }
                } else {
                    $item['sesi_makan'] = '';
                    $item['nama_resep'] = '';
                    $item['resep_id']   = '';
                }
                $formatted[] = $item;
            }

            $allGrouped = collect($formatted)
                ->groupBy(fn($item) => $item['tanggal'])
                ->sortKeysDesc()
                ->map(fn($items, $tanggal) => [
                    'tanggal_label' => $this->labelTanggal($tanggal),
                    'total_keluar'  => (double) collect($items)->where('is_debit', true)->sum('jumlah'),
                    'total_masuk'   => (double) collect($items)->where('is_debit', false)->sum('jumlah'),
                    'transaksi'     => collect($items)->values(),
                ])->values();

            $totalGrup  = $allGrouped->count();
            $totalPages = (int) ceil($totalGrup / $perPage);
            $hasMore    = $page < $totalPages;

            $pagedData = $allGrouped->forPage($page, $perPage)->values();

            return response()->json([
                'success' => true,
                'message' => 'Data mutasi berhasil diambil.',
                'data'    => $pagedData,
                'meta'    => [
                    'page'        => $page,
                    'per_page'    => $perPage,
                    'total_grup'  => $totalGrup,
                    'total_pages' => $totalPages,
                    'has_more'    => $hasMore,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Mutasi error: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function tambahPemasukan(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'total_nominal' => 'required|numeric|min:1',
                'keterangan'    => 'nullable|string', // Validasi keterangan dari Flutter
                'detail'        => 'nullable|array',
            ]);

            $user = $request->user();
            $userId = $user->id ?? $user->_id;
            $jumlah = (float) $request->total_nominal;

            $keuangan = Keuangan::create([
                'Id_User'       => (string) $userId,
                'Id_JadwalMakan'=> null,
                'Tanggal'       => Carbon::now('Asia/Jakarta')->toDateString(),
                'Waktu'         => Carbon::now('Asia/Jakarta')->format('H:i:s'),
                'Kategori'      => 'Pemasukan',
                'Keterangan'    => $request->keterangan ?? 'Top Up', // Mengambil data dari aplikasi
                'Detail'        => $request->detail ?? [],
                'Total_Nominal' => $jumlah,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pemasukan berhasil ditambahkan.',
                'data'    => $this->formatKeuangan($keuangan),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menambah pemasukan: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function tambahPengeluaran(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'total_nominal' => 'required|numeric|min:1',
                'keterangan'    => 'required|in:Pengurangan Budget,Lainnya',
                'detail'        => 'nullable|array',
            ]);

            $user = $request->user();
            $userId = $user->id ?? $user->_id;
            $jumlah = (float) $request->total_nominal;
            $keterangan = $request->keterangan;

            $keuangan = Keuangan::create([
                'Id_User'       => (string) $userId,
                'Id_JadwalMakan'=> null,
                'Tanggal'       => Carbon::now('Asia/Jakarta')->toDateString(),
                'Waktu'         => Carbon::now('Asia/Jakarta')->format('H:i:s'),
                'Kategori'      => 'Pengeluaran',
                'Keterangan'    => $keterangan,
                'Detail'        => $request->detail ?? [],
                'Total_Nominal' => $jumlah,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pengeluaran berhasil dicatat.',
                'data'    => $this->formatKeuangan($keuangan),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menambah pengeluaran: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function detail(Request $request, string $id): JsonResponse
    {
        try {
            $user = $request->user();
            $userId = $user->id ?? $user->_id;
            $transaksi = Keuangan::where('Id_User', (string) $userId)
                ->where('_id', new ObjectId($id))
                ->first();

            if (!$transaksi) {
                return response()->json([
                    'success' => false,
                    'message' => 'Transaksi tidak ditemukan.',
                ], 404);
            }

            $data = $this->formatKeuangan($transaksi);
            if (!empty($transaksi->Id_JadwalMakan)) {
                $jadwal = JadwalMakan::with('resep')->where('_id', new ObjectId($transaksi->Id_JadwalMakan))->first();
                if ($jadwal) {
                    $data['sesi_makan'] = $jadwal->{'Sesi Makan'} ?? '';
                    $data['nama_resep'] = $jadwal->resep->title ?? '';
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Detail transaksi berhasil diambil.',
                'data'    => $data,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Detail error: ' . $e->getMessage(),
            ], 500);
        }
    }

    private function labelTanggal(string $tanggal): string
    {
        try {
            $tgl = Carbon::parse($tanggal)->startOfDay();
            $hariIni = Carbon::now('Asia/Jakarta')->startOfDay();

            if ($tgl->equalTo($hariIni)) return 'Hari ini';
            if ($tgl->equalTo($hariIni->copy()->subDay())) return 'Kemarin';
            if ($tgl->year === Carbon::now('Asia/Jakarta')->year) return $tgl->translatedFormat('j M');
            return $tgl->translatedFormat('j M Y');
        } catch (\Exception $e) {
            return $tanggal;
        }
    }

    private function formatKeuangan(Keuangan $keuangan): array
    {
        $tanggalParsed = Carbon::parse($keuangan->Tanggal);
        
        $catatanBebas = '';
        if (is_array($keuangan->Detail)) {
            $catatanBebas = $keuangan->Detail['info'] ?? $keuangan->Detail['catatan'] ?? '';
        }

        return [
            '_id'               => (string) $keuangan->_id,
            'judul'             => $keuangan->Keterangan ?? $keuangan->Kategori,
            'keterangan'        => !empty($catatanBebas) ? $catatanBebas : ($keuangan->Keterangan ?? ''),
            'waktu'             => $keuangan->Waktu,
            'tanggal'           => $keuangan->Tanggal,
            'jumlah'            => (double) $keuangan->Total_Nominal,
            'is_debit'          => $keuangan->is_debit ?? ($keuangan->Kategori === 'Pengeluaran'),
            'kategori'          => $keuangan->Kategori,
            'jenis_pengeluaran' => strtolower($keuangan->Kategori),
            'bulan'             => (int) $tanggalParsed->month,
            'tahun'             => (int) $tanggalParsed->year,
        ];
    }
}