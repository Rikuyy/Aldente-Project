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
    private function getBudget(Request $request): float
    {
        $user = $request->user();
        return (float) ($user->Budget_Bulanan ?? 3000000);
    }

    private function updateBudget(Request $request, float $change): void
    {
        $user = $request->user();
        $current = (float) ($user->Budget_Bulanan ?? 3000000);
        $user->Budget_Bulanan = max(0, $current + $change);
        $user->save();
    }

    public function ringkasan(Request $request): JsonResponse
    {
        try {
            $userId = $request->user()->_id;
            $bulanQuery = $request->query('bulan', Carbon::now()->format('Y-m'));
            $parsed = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate = $parsed->copy()->startOfMonth()->toDateString();
            $endDate = $parsed->copy()->endOfMonth()->toDateString();

            $transaksis = Keuangan::where('Id_User', $userId)
                ->whereBetween('Tanggal', [$startDate, $endDate])
                ->get();

            $pemasukanBudget = $this->getBudget($request);
            $pemasukanTopup = $transaksis->where('Kategori', 'Topup')->sum('Total_Pengeluaran');
            $totalPemasukan = $pemasukanBudget + $pemasukanTopup;

            $pengeluaran = $transaksis->filter(fn($t) => in_array($t->Kategori, ['Beli', 'Masak', 'Penarikan', 'Lainnya']))->sum('Total_Pengeluaran');
            $saldo = $totalPemasukan - $pengeluaran;

            $hariIni = min(Carbon::now()->day, $parsed->daysInMonth);
            if ($hariIni <= 0) $hariIni = 1;
            $rataPerHari = round($pengeluaran / $hariIni);
            $prediksiAkhir = round(($pengeluaran / $hariIni) * $parsed->daysInMonth);

            $totalMasak = $transaksis->where('Kategori', 'Masak')->sum('Total_Pengeluaran');
            $totalBeliLuar = $transaksis->where('Kategori', 'Beli')->sum('Total_Pengeluaran');
            $persenMasak = $pengeluaran > 0 ? round(($totalMasak / $pengeluaran) * 100) : 0;

            $isDefisit = $prediksiAkhir > $totalPemasukan;
            $pesanPrediksi = $isDefisit
                ? "Diprediksi total pengeluaran mencapai Rp " . number_format($prediksiAkhir, 0, ',', '.') . " (Melebihi total pemasukan)."
                : "Pengeluaran Anda bulan ini diprediksi masih aman.";

            $budgetPerHari = $totalPemasukan / max(1, $parsed->daysInMonth);
            $pengeluaranHariIni = $transaksis->filter(fn($t) => $t->Tanggal === Carbon::now()->toDateString() && in_array($t->Kategori, ['Beli','Masak','Penarikan','Lainnya']))->sum('Total_Pengeluaran');
            $isOverbudgetHariIni = $pengeluaranHariIni > $budgetPerHari;
            $overbudgetAmount = $pengeluaranHariIni - $budgetPerHari;

            $sisaHari = max(0, $parsed->daysInMonth - $hariIni);
            $sisaBudget = $totalPemasukan - $pengeluaran;
            $sisaBudgetPerHari = $sisaHari > 0 ? $sisaBudget / $sisaHari : 0;
            $isSisaTipis = $sisaBudgetPerHari < 10000 && $sisaBudgetPerHari > 0;

            return response()->json([
                'success' => true,
                'message' => 'Ringkasan keuangan berhasil diambil.',
                'data' => [
                    'data' => [
                        'saldo' => (double) $saldo,
                        'total_pemasukan' => (double) $totalPemasukan,
                        'total_pengeluaran' => (double) $pengeluaran,
                        'rata_per_hari' => (double) $rataPerHari,
                        'prediksi_akhir_bulan' => (double) $prediksiAkhir,
                        'prediksi_defisit' => $isDefisit,
                        'pesan_prediksi' => $pesanPrediksi,
                        'persen_masak' => (int) $persenMasak,
                        'komposisi' => [
                            ['kategori' => 'Masak Sendiri', 'jumlah' => (double) $totalMasak, 'warna' => 'orange'],
                            ['kategori' => 'Beli di Luar',  'jumlah' => (double) $totalBeliLuar, 'warna' => 'blue'],
                        ],
                        'budget_per_hari' => round($budgetPerHari, 2),
                        'pengeluaran_hari_ini' => (double) $pengeluaranHariIni,
                        'is_overbudget_hari_ini' => $isOverbudgetHariIni,
                        'overbudget_amount' => round($overbudgetAmount, 2),
                        'sisa_budget_per_hari' => round($sisaBudgetPerHari, 2),
                        'is_sisa_tipis' => $isSisaTipis,
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
            $userId = $request->user()->_id;
            $bulanQuery = $request->query('bulan', Carbon::now()->format('Y-m'));
            $parsed = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate = $parsed->copy()->startOfMonth()->toDateString();
            $endDate = $parsed->copy()->endOfMonth()->toDateString();

            $transaksis = Keuangan::where('Id_User', $userId)
                ->whereIn('Kategori', ['Beli', 'Masak', 'Penarikan', 'Lainnya'])
                ->whereBetween('Tanggal', [$startDate, $endDate])
                ->get();

            $grouped = $transaksis->groupBy('Tanggal')->map(fn($items) => $items->sum('Total_Pengeluaran'));

            $dataGrafik = [];
            for ($hari = 1; $hari <= $parsed->daysInMonth; $hari++) {
                $tanggal = $parsed->copy()->day($hari)->toDateString();
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
            $userId = $request->user()->_id;
            $query = Keuangan::where('Id_User', $userId);

            if ($request->has('tahun') && !empty($request->tahun) && $request->tahun != 0) {
                $tahun = (int) $request->tahun;
                $query->where('Tanggal', 'regex', "/^{$tahun}-/");
            }
            if ($request->has('bulan') && !empty($request->bulan)) {
                $bulan = (int) $request->bulan;
                $bulanStr = str_pad($bulan, 2, '0', STR_PAD_LEFT);
                $query->where('Tanggal', 'regex', "/-{$bulanStr}-/");
            }

            $transaksis = $query->orderBy('Tanggal', 'desc')
                                ->orderBy('Waktu', 'desc')
                                ->get();

            $formatted = [];
            foreach ($transaksis as $trans) {
                $item = $this->formatKeuangan($trans);
                if (!empty($trans->Id_JadwalMakan)) {
                    $jadwal = JadwalMakan::with('resep')->where('_id', new ObjectId($trans->Id_JadwalMakan))->first();
                    if ($jadwal) {
                        $item['sesi_makan'] = $jadwal->{'Sesi Makan'} ?? '';
                        $item['nama_resep'] = $jadwal->resep->title ?? '';
                        $item['resep_id'] = (string) $jadwal->Id_Resep;
                    }
                } else {
                    $item['sesi_makan'] = '';
                    $item['nama_resep'] = '';
                    $item['resep_id'] = '';
                }
                $formatted[] = $item;
            }

            $grouped = collect($formatted)->groupBy(fn($item) => $this->labelTanggal($item['tanggal']))
                ->map(fn($items, $label) => [
                    'tanggal_label' => $label,
                    'total_keluar'  => (double) $items->where('is_debit', true)->sum('jumlah'),
                    'total_masuk'   => (double) $items->where('is_debit', false)->sum('jumlah'),
                    'transaksi'     => $items->values(),
                ])->values();

            return response()->json([
                'success' => true,
                'message' => 'Data mutasi berhasil diambil.',
                'data'    => $grouped,
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
                'jumlah' => 'required|numeric|min:1',
                'keterangan' => 'nullable|string|max:255',
            ]);

            $user = $request->user();
            $userId = $user->_id;
            $jumlah = (float) $request->jumlah;
            $keterangan = $request->keterangan ?? 'Top-up saldo';

            $this->updateBudget($request, $jumlah);

            $keuangan = Keuangan::create([
                'Id_User'           => (string) $userId,
                'Id_JadwalMakan'    => null,
                'Tanggal'           => Carbon::now()->toDateString(),
                'Waktu'             => Carbon::now()->format('H:i:s'),
                'Kategori'          => 'Topup',
                'Detail_Beli'       => [['nama' => $keterangan, 'nominal' => $jumlah]],
                'Total_Pengeluaran' => $jumlah,
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
                'jumlah' => 'required|numeric|min:1',
                'keterangan' => 'required|string|max:255',
                'jenis' => 'required|in:penarikan,lainnya',
            ]);

            $user = $request->user();
            $userId = $user->_id;
            $jumlah = (float) $request->jumlah;
            $keterangan = $request->keterangan;
            $jenis = $request->jenis;

            if ($jenis === 'penarikan') {
                $this->updateBudget($request, -$jumlah);
                $kategori = 'Penarikan';
            } else {
                $kategori = 'Lainnya';
            }

            $keuangan = Keuangan::create([
                'Id_User'           => (string) $userId,
                'Id_JadwalMakan'    => null,
                'Tanggal'           => Carbon::now()->toDateString(),
                'Waktu'             => Carbon::now()->format('H:i:s'),
                'Kategori'          => $kategori,
                'Detail_Beli'       => [['nama' => $keterangan, 'nominal' => $jumlah]],
                'Total_Pengeluaran' => $jumlah,
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
        $jenisMapping = [
            'Beli' => 'food',
            'Masak' => 'cook',
            'Topup' => 'topup',
            'Penarikan' => 'withdrawal',
            'Lainnya' => 'other',
        ];
        $jenis = $jenisMapping[$keuangan->Kategori] ?? 'other';
        $isDebit = in_array($keuangan->Kategori, ['Beli','Masak','Penarikan','Lainnya']);

        $detail = $keuangan->Detail_Beli;
        $judul = '';
        $keterangan = '';

        if ($detail && is_array($detail) && count($detail) > 0) {
            $judul = $detail[0]['nama'] ?? 'Transaksi';
            $keterangan = count($detail) > 1 ? count($detail) . ' item' : '';
        } else {
            $judul = $keuangan->Kategori;
        }

        $tanggalParsed = Carbon::parse($keuangan->Tanggal);

        return [
            '_id'               => (string) $keuangan->_id,
            'judul'             => $judul,
            'keterangan'        => $keterangan,
            'waktu'             => $keuangan->Waktu,
            'tanggal'           => $keuangan->Tanggal,
            'jumlah'            => (double) $keuangan->Total_Pengeluaran,
            'is_debit'          => $isDebit,
            'jenis_pengeluaran' => $jenis,
            'bulan'             => (int) $tanggalParsed->month,
            'tahun'             => (int) $tanggalParsed->year,
        ];
    }
}