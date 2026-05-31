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
            $user     = $request->user();
            $userId   = $user->_id;
            
            // Paksa pakai waktu Asia/Jakarta
            $today = Carbon::now('Asia/Jakarta');
            
            // Ambil SEMUA transaksi pemasukan user
            $semuaPemasukan = Keuangan::where('Id_User', $userId)
                ->where('Kategori', 'Pemasukan')
                ->orderBy('Tanggal', 'asc')
                ->get();
            
            // Filter pemasukan yang MASIH BERLAKU (belum kadaluarsa)
            $pemasukanAktif = $semuaPemasukan->filter(function($pemasukan) use ($today) {
                $tanggalPemasukan = Carbon::parse($pemasukan->Tanggal);
                $tanggalKadaluarsa = $this->getTanggalKadaluarsa($tanggalPemasukan);
                return $today->lessThan($tanggalKadaluarsa);
            });
            
            // Pakai bulan dari created_at user
            $bulanQuery = Carbon::parse($user->created_at)->format('Y-m');
            $parsed = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate = $parsed->copy()->startOfMonth()->toDateString();
            $endDate = $parsed->copy()->endOfMonth()->toDateString();
            
            // ========== PERUBAHAN 1: HAPUS FILTER whereBetween UNTUK PENGELUARAN ==========
            $totalPengeluaran = (float) Keuangan::where('Id_User', $userId)
                ->where('Kategori', 'Pengeluaran')
                ->sum('Total_Nominal');
            
            // Tentukan tanggal mulai periode dari created_at user
            $tanggalMulaiPeriode = Carbon::parse($user->created_at ?? Carbon::now('Asia/Jakarta'));
            $tanggalKadaluarsaPeriode = $this->getTanggalKadaluarsa($tanggalMulaiPeriode);
            
            // Hitung jumlah hari dalam periode (diffInDays tanpa +1)
            $jumlahHariPeriode = $this->getJumlahHariPeriode($tanggalMulaiPeriode);
            
            if ($pemasukanAktif->isEmpty()) {
                // USER BARU
                // ========== PERUBAHAN 2: PAKAI TOTAL PEMASUKAN DARI DATABASE ==========
                $totalPemasukan = (float) Keuangan::where('Id_User', $userId)
                    ->where('Kategori', 'Pemasukan')
                    ->sum('Total_Nominal');
                
                // Jika belum ada pemasukan di database, fallback ke Budget_Bulanan
                if ($totalPemasukan == 0) {
                    $totalPemasukan = (float) ($user->Budget_Bulanan ?? 0);
                }
                
                // Target budget per hari (TETAP)
                $targetBudgetPerHari = $jumlahHariPeriode > 0 ? round($totalPemasukan / $jumlahHariPeriode) : 0;
                $saldo = $totalPemasukan - $totalPengeluaran;
            } else {
                // USER LAMA
                $totalPemasukan = 0;
                $totalBobotHari = 0;
                foreach ($pemasukanAktif as $pemasukan) {
                    $nominal = (float) $pemasukan->Total_Nominal;
                    $tanggalMulai = Carbon::parse($pemasukan->Tanggal);
                    $jmlHari = $this->getJumlahHariPeriode($tanggalMulai);
                    $totalPemasukan += $nominal;
                    $totalBobotHari += $jmlHari;
                }
                $targetBudgetPerHari = $totalBobotHari > 0 ? round($totalPemasukan / $totalBobotHari) : 0;
                $saldo = $totalPemasukan - $totalPengeluaran;
            }
            
            // ========== SISA BUDGET PER HARI (DINAMIS) ==========
            // Hitung sisa hari dari HARI INI sampai kadaluarsa (termasuk hari ini)
            $sisaHari = max(1, $today->diffInDays($tanggalKadaluarsaPeriode) + 1);
            
            // Sisa budget per hari (berubah setiap hari)
            $sisaBudgetPerHari = $sisaHari > 0 ? round($saldo / $sisaHari) : 0;
            $isSisaTipis = $sisaBudgetPerHari < 10000 && $sisaBudgetPerHari > 0;
            
            // Prediksi akhir bulan (untuk tampilan)
            $hariIni = min($today->day, $parsed->daysInMonth);
            if ($hariIni <= 0) $hariIni = 1;
            
            $rataAktual = $hariIni > 0 ? $totalPengeluaran / $hariIni : 0;
            $prediksiAkhir = round($rataAktual * $parsed->daysInMonth);
            
            $isDefisit = $prediksiAkhir > $totalPemasukan;
            $pesanPrediksi = $isDefisit
                ? "Diprediksi total pengeluaran mencapai Rp " . number_format($prediksiAkhir, 0, ',', '.') . " (Melebihi total pemasukan)."
                : "Pengeluaran Anda diprediksi masih aman.";
            
            // Komposisi Pengeluaran (untuk grafik, tetap pakai filter bulan)
            $transaksisBulanIni = Keuangan::where('Id_User', $userId)
                ->whereBetween('Tanggal', [$startDate, $endDate])
                ->get();
            
            $pengeluaranItems = $transaksisBulanIni->where('Kategori', 'Pengeluaran');
            $totalBeli  = (float) $pengeluaranItems->where('Keterangan', 'Beli')->sum('Total_Nominal');
            $totalMasak = (float) $pengeluaranItems->where('Keterangan', 'Masak')->sum('Total_Nominal');
            $totalKomposisi = $totalBeli + $totalMasak;
            $persenBeli  = $totalKomposisi > 0 ? round(($totalBeli  / $totalKomposisi) * 100) : 0;
            $persenMasak = $totalKomposisi > 0 ? round(($totalMasak / $totalKomposisi) * 100) : 0;
            
            // Pengeluaran hari ini
            $pengeluaranHariIni = (float) Keuangan::where('Id_User', $userId)
                ->where('Kategori', 'Pengeluaran')
                ->where('Tanggal', $today->toDateString())
                ->sum('Total_Nominal');
            
            // Overbudget hari ini (dibandingkan target tetap)
            $isOverbudgetHariIni = $pengeluaranHariIni > $targetBudgetPerHari;
            $overbudgetAmount = $pengeluaranHariIni - $targetBudgetPerHari;
            
            return response()->json([
                'success' => true,
                'message' => 'Ringkasan keuangan berhasil diambil.',
                'data'    => [
                    'data' => [
                        'saldo'                  => (double) $saldo,
                        'total_pemasukan'        => (double) $totalPemasukan,
                        'total_pengeluaran'      => (double) $totalPengeluaran,
                        'rata_per_hari'          => (double) $targetBudgetPerHari,
                        'prediksi_akhir_bulan'   => (double) $prediksiAkhir,
                        'prediksi_defisit'       => $isDefisit,
                        'pesan_prediksi'         => $pesanPrediksi,
                        'persen_masak'           => (int) $persenMasak,
                        'komposisi'              => [
                            ['kategori' => 'Beli di Luar',  'jumlah' => (double) $totalBeli,  'persen' => $persenBeli,  'warna' => 'blue'],
                            ['kategori' => 'Masak Sendiri', 'jumlah' => (double) $totalMasak, 'persen' => $persenMasak, 'warna' => 'orange'],
                        ],
                        'budget_per_hari'        => (double) $sisaBudgetPerHari,
                        'pengeluaran_hari_ini'   => (double) $pengeluaranHariIni,
                        'is_overbudget_hari_ini' => $isOverbudgetHariIni,
                        'overbudget_amount'      => round($overbudgetAmount, 2),
                        'sisa_budget_per_hari'   => (double) $sisaBudgetPerHari,
                        'is_sisa_tipis'          => $isSisaTipis,
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
            $userId = $user->_id;
            
            $bulanQuery = Carbon::parse($user->created_at)->format('Y-m');
            $parsed     = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate  = $parsed->copy()->startOfMonth()->toDateString();
            $endDate    = $parsed->copy()->endOfMonth()->toDateString();

            $transaksis = Keuangan::where('Id_User', $userId)
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
            $userId  = $request->user()->_id;
            $page    = max(1, (int) $request->query('page', 1));
            $perPage = max(1, min(50, (int) $request->query('per_page', 10)));

            $query = Keuangan::where('Id_User', $userId);

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
                'detail'        => 'nullable|array',
            ]);

            $userId = $request->user()->_id;
            $jumlah = (float) $request->total_nominal;

            $keuangan = Keuangan::create([
                'Id_User'       => (string) $userId,
                'Id_JadwalMakan'=> null,
                'Tanggal'       => Carbon::now('Asia/Jakarta')->toDateString(),
                'Waktu'         => Carbon::now('Asia/Jakarta')->format('H:i:s'),
                'Kategori'      => 'Pemasukan',
                'Keterangan'    => 'Top Up',
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

            $userId     = $request->user()->_id;
            $jumlah     = (float) $request->total_nominal;
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
            $userId = $request->user()->_id;
            $transaksi = Keuangan::where('Id_User', $userId)
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

    /**
     * Hitung tanggal kadaluarsa
     * - Untuk tanggal 31: paksa ke tanggal 30 bulan depan
     * - Untuk lainnya: tanggal yang sama di bulan depan
     */
    private function getTanggalKadaluarsa(Carbon $tanggalMulai): Carbon
    {
        $hari = $tanggalMulai->day;
        
        if ($hari == 31) {
            $tahun = $tanggalMulai->year;
            $bulan = $tanggalMulai->month + 1;
            return Carbon::create($tahun, $bulan, 30, 0, 0, 0, 'Asia/Jakarta');
        }
        
        $bulanDepan = $tanggalMulai->copy()->addMonth();
        $maxHari = $bulanDepan->daysInMonth;
        
        if ($hari <= $maxHari) {
            return $bulanDepan->copy()->day($hari);
        } else {
            return $bulanDepan->copy()->endOfMonth();
        }
    }

    /**
     * Hitung jumlah hari dalam periode
     */
    private function getJumlahHariPeriode(Carbon $tanggalMulai): int
    {
        $tanggalKadaluarsa = $this->getTanggalKadaluarsa($tanggalMulai);
        return $tanggalMulai->diffInDays($tanggalKadaluarsa);
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
            'is_debit'          => $keuangan->is_debit,
            'kategori'          => $keuangan->Kategori,
            'jenis_pengeluaran' => strtolower($keuangan->Kategori),
            'bulan'             => (int) $tanggalParsed->month,
            'tahun'             => (int) $tanggalParsed->year,
        ];
    }
}