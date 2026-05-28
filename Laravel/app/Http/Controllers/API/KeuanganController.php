<?php
// app/Http/Controllers/Api/KeuanganController.php

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
    // Helper dapatkan budget user
    private function getBudget(Request $request): float
    {
        $user = $request->user();
        return (float) ($user->Budget_Bulanan ?? 3000000);
    }

    // Helper update budget user (setelah topup)
    private function updateBudget(Request $request, float $newBudget): void
    {
        $user = $request->user();
        $user->Budget_Bulanan = $newBudget;
        $user->save();
    }

    // ==================== 1. RINGKASAN (hanya pengeluaran, pemasukan tidak dihitung) ====================
    public function ringkasan(Request $request): JsonResponse
    {
        try {
            $userId = $request->user()->_id;
            $bulanQuery = $request->query('bulan', Carbon::now()->format('Y-m'));
            $parsed = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate = $parsed->copy()->startOfMonth()->toDateString();
            $endDate = $parsed->copy()->endOfMonth()->toDateString();

            // Hanya transaksi pengeluaran (is_debit = true)
            $transaksis = Keuangan::where('Id_User', $userId)
                ->where('is_debit', true)
                ->whereBetween('Tanggal', [$startDate, $endDate])
                ->get();

            $totalPengeluaran = $transaksis->sum('Total_Pengeluaran');
            $budget = $this->getBudget($request);
            $totalPemasukan = $budget; // budget saat ini dianggap pemasukan bulanan
            $saldo = $budget - $totalPengeluaran;

            $hariDenganTransaksi = $transaksis->groupBy('Tanggal')->count();
            $rataPerHari = $hariDenganTransaksi > 0 ? round($totalPengeluaran / $hariDenganTransaksi) : 0;

            $hariIni = min(Carbon::now()->day, $parsed->daysInMonth);
            $prediksiAkhir = $hariIni > 0 ? round(($totalPengeluaran / $hariIni) * $parsed->daysInMonth) : 0;

            $totalMasak = $transaksis->where('Jenis_Pengeluaran', 'Masak')->sum('Total_Pengeluaran');
            $totalBeliLuar = $transaksis->where('Jenis_Pengeluaran', 'Beli')->sum('Total_Pengeluaran');
            $persenMasak = $totalPengeluaran > 0 ? round(($totalMasak / $totalPengeluaran) * 100) : 0;

            $isDefisit = $prediksiAkhir > $budget;
            $pesanPrediksi = $isDefisit
                ? "Diprediksi total pengeluaran mencapai Rp " . number_format($prediksiAkhir, 0, ',', '.') . " (Melebihi budget Anda)."
                : "Pengeluaran Anda bulan ini diprediksi masih aman sesuai budget.";

            return response()->json([
                'success' => true,
                'message' => 'Ringkasan keuangan berhasil diambil.',
                'data' => [
                    'data' => [
                        'saldo'                => (double) $saldo,
                        'total_pemasukan'      => (double) $totalPemasukan,
                        'total_pengeluaran'    => (double) $totalPengeluaran,
                        'rata_per_hari'        => (double) $rataPerHari,
                        'prediksi_akhir_bulan' => (double) $prediksiAkhir,
                        'prediksi_defisit'     => $isDefisit,
                        'pesan_prediksi'       => $pesanPrediksi,
                        'persen_masak'         => (int) $persenMasak,
                        'komposisi'            => [
                            ['kategori' => 'Masak Sendiri', 'jumlah' => (double) $totalMasak, 'warna' => 'orange'],
                            ['kategori' => 'Beli di Luar',  'jumlah' => (double) $totalBeliLuar, 'warna' => 'blue'],
                        ],
                    ]
                ],
            ], 200);
        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ==================== 2. GRAFIK (pengeluaran per hari) ====================
    public function grafik(Request $request): JsonResponse
    {
        try {
            $userId = $request->user()->_id;
            $bulanQuery = $request->query('bulan', Carbon::now()->format('Y-m'));
            $parsed = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate = $parsed->copy()->startOfMonth()->toDateString();
            $endDate = $parsed->copy()->endOfMonth()->toDateString();

            $transaksis = Keuangan::where('Id_User', $userId)
                ->where('is_debit', true)
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
            return $this->serverError($e);
        }
    }

    // ==================== 3. MUTASI (dengan lookup jadwal makan) ====================
    public function mutasi(Request $request): JsonResponse
    {
        try {
            $userId = $request->user()->_id;
            
            // Ambil semua transaksi, urutkan descending tanggal & waktu
            $transaksis = Keuangan::where('Id_User', $userId)
                ->orderBy('Tanggal', 'desc')
                ->orderBy('Waktu', 'desc')
                ->get();

            // Format setiap transaksi dan tambahkan data jadwal jika ada
            $formatted = [];
            foreach ($transaksis as $trans) {
                $item = $this->formatKeuangan($trans);
                // Jika ada Id_JadwalMakan, ambil data jadwal
                if (!empty($trans->Id_JadwalMakan)) {
                    $jadwal = JadwalMakan::with('resep')->where('_id', new ObjectId($trans->Id_JadwalMakan))->first();
                    if ($jadwal) {
                        $item['sesi_makan'] = $jadwal->{'Sesi Makan'} ?? '';
                        $item['nama_resep'] = $jadwal->resep->title ?? '';
                        $item['resep_id'] = (string) $jadwal->Id_Resep;
                    } else {
                        $item['sesi_makan'] = '';
                        $item['nama_resep'] = '';
                        $item['resep_id'] = '';
                    }
                } else {
                    $item['sesi_makan'] = '';
                    $item['nama_resep'] = '';
                    $item['resep_id'] = '';
                }
                $formatted[] = $item;
            }

            // Grouping berdasarkan label tanggal
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
            \Log::error('Mutasi error: ' . $e->getMessage());
            return $this->serverError($e);
        }
    }

    // ==================== 4. TAMBAH PEMASUKAN (Top-up) ====================
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

            // Update budget user
            $budgetLama = $this->getBudget($request);
            $budgetBaru = $budgetLama + $jumlah;
            $this->updateBudget($request, $budgetBaru);

            // Catat ke tabel keuangan
            $keuangan = Keuangan::create([
                'Id_User'           => (string) $userId,
                'Id_JadwalMakan'    => null,
                'Tanggal'           => Carbon::now()->toDateString(),
                'Waktu'             => Carbon::now()->format('H:i:s'),
                'Jenis_Pengeluaran' => 'Topup',
                'Detail_Beli'       => [['nama' => $keterangan, 'nominal' => $jumlah]],
                'Total_Pengeluaran' => $jumlah,
                'is_debit'          => false, // pemasukan
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pemasukan berhasil ditambahkan.',
                'data'    => $this->formatKeuangan($keuangan),
            ], 201);
        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ==================== 5. DETAIL SATU TRANSAKSI ====================
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
            return $this->serverError($e);
        }
    }

    // ==================== HELPER METHODS ====================
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
        $jenisMapping = ['Masak' => 'cook', 'Beli' => 'food', 'Topup' => 'topup'];
        $jenis = $jenisMapping[$keuangan->Jenis_Pengeluaran] ?? 'other';

        $detail = $keuangan->Detail_Beli;
        $judul = '';
        $keterangan = '';

        if ($detail && is_array($detail) && count($detail) > 0) {
            if ($keuangan->Jenis_Pengeluaran == 'Topup') {
                $judul = 'Topup Saldo';
                $keterangan = $detail[0]['nama'] ?? '';
            } else {
                $judul = $detail[0]['nama'] ?? 'Transaksi';
                $keterangan = count($detail) . ' item';
            }
        } else {
            $judul = $keuangan->Jenis_Pengeluaran == 'Masak' ? 'Masak sendiri' : 'Beli di luar';
            $keterangan = '';
        }

        $tanggalParsed = Carbon::parse($keuangan->Tanggal);

        return [
            '_id'               => (string) $keuangan->_id,
            'judul'             => $judul,
            'keterangan'        => $keterangan,
            'waktu'             => $keuangan->Waktu,
            'tanggal'           => $keuangan->Tanggal,
            'jumlah'            => (double) $keuangan->Total_Pengeluaran,
            'is_debit'          => $keuangan->is_debit ?? true,
            'jenis_pengeluaran' => $jenis,
            'bulan'             => (int) $tanggalParsed->month,
            'tahun'             => (int) $tanggalParsed->year,
        ];
    }

    private function serverError(\Exception $e): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan server.',
            'error'   => $e->getMessage(),
        ], 500);
    }
}