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
            $bulanQuery = $request->query('bulan', Carbon::now()->format('Y-m'));
            $parsed     = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate  = $parsed->copy()->startOfMonth()->toDateString();
            $endDate    = $parsed->copy()->endOfMonth()->toDateString();

            $transaksis = Keuangan::where('Id_User', $userId)
                ->whereBetween('Tanggal', [$startDate, $endDate])
                ->get();

            // --- Saldo: Budget_Bulanan (saldo awal) + pemasukan bulan ini - pengeluaran bulan ini ---
            $saldoAwal        = (float) ($user->Budget_Bulanan ?? 0);
            $totalPemasukan   = (float) $transaksis->where('Kategori', 'Pemasukan')->sum('Total_Nominal');
            $totalPengeluaran = (float) $transaksis->where('Kategori', 'Pengeluaran')->sum('Total_Nominal');
            $saldo            = $saldoAwal + $totalPemasukan - $totalPengeluaran;

            // --- Rata-rata per hari: Budget_Bulanan dibagi jumlah hari bulan ---
            $budgetBulanan  = (float) ($user->Budget_Bulanan ?? 0);
            $jumlahHari     = $parsed->daysInMonth;
            $rataPerHari    = $jumlahHari > 0 ? round($budgetBulanan / $jumlahHari) : 0;

            // --- Prediksi akhir bulan (tetap pakai rata-rata aktual pengeluaran) ---
            $hariIni        = min(Carbon::now()->day, $jumlahHari);
            if ($hariIni <= 0) $hariIni = 1;
            $rataAktual     = $totalPengeluaran / $hariIni;
            $prediksiAkhir  = round($rataAktual * $jumlahHari);

            $isDefisit      = $prediksiAkhir > ($saldoAwal + $totalPemasukan);
            $pesanPrediksi  = $isDefisit
                ? "Diprediksi total pengeluaran mencapai Rp " . number_format($prediksiAkhir, 0, ',', '.') . " (Melebihi total pemasukan)."
                : "Pengeluaran Anda bulan ini diprediksi masih aman.";

            // --- Komposisi: Keterangan "Beli" dan "Masak" dari transaksi Pengeluaran ---
            $pengeluaranItems = $transaksis->where('Kategori', 'Pengeluaran');
            $totalBeli  = (float) $pengeluaranItems->where('Keterangan', 'Beli')->sum('Total_Nominal');
            $totalMasak = (float) $pengeluaranItems->where('Keterangan', 'Masak')->sum('Total_Nominal');
            $totalKomposisi = $totalBeli + $totalMasak;
            $persenBeli  = $totalKomposisi > 0 ? round(($totalBeli  / $totalKomposisi) * 100) : 0;
            $persenMasak = $totalKomposisi > 0 ? round(($totalMasak / $totalKomposisi) * 100) : 0;

            // --- Budget per hari & overbudget hari ini ---
            $budgetPerHari      = $jumlahHari > 0 ? $budgetBulanan / $jumlahHari : 0;
            $pengeluaranHariIni = (float) $transaksis
                ->where('Kategori', 'Pengeluaran')
                ->where('Tanggal', Carbon::now()->toDateString())
                ->sum('Total_Nominal');
            $isOverbudgetHariIni = $pengeluaranHariIni > $budgetPerHari;
            $overbudgetAmount    = $pengeluaranHariIni - $budgetPerHari;

            $sisaHari         = max(0, $jumlahHari - $hariIni);
            $sisaBudgetPerHari = $sisaHari > 0 ? $saldo / $sisaHari : 0;
            $isSisaTipis      = $sisaBudgetPerHari < 10000 && $sisaBudgetPerHari > 0;

            return response()->json([
                'success' => true,
                'message' => 'Ringkasan keuangan berhasil diambil.',
                'data'    => [
                    'data' => [
                        'saldo'                  => (double) $saldo,
                        'total_pemasukan'        => (double) $totalPemasukan,
                        'total_pengeluaran'      => (double) $totalPengeluaran,
                        'rata_per_hari'          => (double) $rataPerHari,
                        'prediksi_akhir_bulan'   => (double) $prediksiAkhir,
                        'prediksi_defisit'       => $isDefisit,
                        'pesan_prediksi'         => $pesanPrediksi,
                        'persen_masak'           => (int) $persenMasak,
                        'komposisi'              => [
                            ['kategori' => 'Beli di Luar',  'jumlah' => (double) $totalBeli,  'persen' => $persenBeli,  'warna' => 'blue'],
                            ['kategori' => 'Masak Sendiri', 'jumlah' => (double) $totalMasak, 'persen' => $persenMasak, 'warna' => 'orange'],
                        ],
                        'budget_per_hari'        => round($budgetPerHari, 2),
                        'pengeluaran_hari_ini'   => (double) $pengeluaranHariIni,
                        'is_overbudget_hari_ini' => $isOverbudgetHariIni,
                        'overbudget_amount'      => round($overbudgetAmount, 2),
                        'sisa_budget_per_hari'   => round($sisaBudgetPerHari, 2),
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
            $userId     = $request->user()->_id;
            $bulanQuery = $request->query('bulan', Carbon::now()->format('Y-m'));
            $parsed     = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate  = $parsed->copy()->startOfMonth()->toDateString();
            $endDate    = $parsed->copy()->endOfMonth()->toDateString();

            // Tren pengeluaran harian: hanya Kategori "Pengeluaran"
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
                        // Id_JadwalMakan bukan format ObjectId valid, skip lookup
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

            // Group per tanggal (raw date) agar urutan konsisten, lalu paginate per grup
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
                'jumlah'     => 'required|numeric|min:1',
                'keterangan' => 'nullable|string|max:255',
            ]);

            $user        = $request->user();
            $userId      = $user->_id;
            $jumlah      = (float) $request->jumlah;
            $keterangan  = $request->keterangan ?? 'Top-up saldo';

            // Update Budget_Bulanan user (saldo awal)
            $user->Budget_Bulanan = (float) ($user->Budget_Bulanan ?? 0) + $jumlah;
            $user->save();

            $keuangan = Keuangan::create([
                'Id_User'       => (string) $userId,
                'Id_JadwalMakan'=> null,
                'Tanggal'       => Carbon::now()->toDateString(),
                'Waktu'         => Carbon::now()->format('H:i:s'),
                'Kategori'      => 'Pemasukan',
                'Keterangan'    => $keterangan,
                'Detail'        => [],
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
                'jumlah'     => 'required|numeric|min:1',
                'keterangan' => 'required|string|max:255',
                'jenis'      => 'required|in:penarikan,lainnya',
            ]);

            $user       = $request->user();
            $userId     = $user->_id;
            $jumlah     = (float) $request->jumlah;
            $keterangan = $request->keterangan;
            $jenis      = $request->jenis;

            // Penarikan mengurangi Budget_Bulanan (saldo awal)
            if ($jenis === 'penarikan') {
                $user->Budget_Bulanan = max(0, (float) ($user->Budget_Bulanan ?? 0) - $jumlah);
                $user->save();
            }

            $keuangan = Keuangan::create([
                'Id_User'       => (string) $userId,
                'Id_JadwalMakan'=> null,
                'Tanggal'       => Carbon::now()->toDateString(),
                'Waktu'         => Carbon::now()->format('H:i:s'),
                'Kategori'      => 'Pengeluaran',
                'Keterangan'    => $keterangan,
                'Detail'        => [],
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

    private function labelTanggal(string $tanggal): string
    {
        try {
            $tgl = Carbon::parse($tanggal)->startOfDay();
            $hariIni = Carbon::now()->startOfDay();

            if ($tgl->equalTo($hariIni)) return 'Hari ini';
            if ($tgl->equalTo($hariIni->copy()->subDay())) return 'Kemarin';
            if ($tgl->year === Carbon::now()->year) return $tgl->translatedFormat('j M');
            return $tgl->translatedFormat('j M Y');
        } catch (\Exception $e) {
            return $tanggal;
        }
    }

    private function formatKeuangan(Keuangan $keuangan): array
    {
        $tanggalParsed = Carbon::parse($keuangan->Tanggal);

        return [
            '_id'               => (string) $keuangan->_id,
            'judul'             => $keuangan->Keterangan ?? $keuangan->Kategori,
            'keterangan'        => $keuangan->Keterangan ?? '',
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