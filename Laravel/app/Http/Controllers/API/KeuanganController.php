<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Keuangan;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;
use MongoDB\BSON\ObjectId;

class KeuanganController extends Controller
{
    private function idPengguna(Request $request): string
    {
        return (string) $request->user()->_id;
    }

    private function getBudget(Request $request): float
    {
        $user = $request->user();
        return (float) ($user->Budget_Bulanan ?? 300000);
    }

    // ============================================================
    // 1. RINGKASAN
    // ============================================================
    public function ringkasan(Request $request): JsonResponse
    {
        try {
            $idPengguna = $this->idPengguna($request);
            $bulanQuery = $request->query('bulan', Carbon::now()->format('Y-m'));
            $parsed = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate = $parsed->copy()->startOfMonth()->toDateString();
            $endDate = $parsed->copy()->endOfMonth()->toDateString();

            $transaksis = Keuangan::where('Id_User', $idPengguna)
                ->whereBetween('Tanggal', [$startDate, $endDate])
                ->get();

            $totalPengeluaran = $transaksis->sum('Total_Pengeluaran');
            $budget = $this->getBudget($request);
            $totalPemasukan = $budget;
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
                            ['kategori' => 'Belanja Bahan',  'jumlah' => 0.0, 'warna' => 'green'],
                        ],
                    ]
                ],
            ], 200);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // 2. GRAFIK
    // ============================================================
    public function grafik(Request $request): JsonResponse
    {
        try {
            $idPengguna = $this->idPengguna($request);
            $bulanQuery = $request->query('bulan', Carbon::now()->format('Y-m'));
            $parsed = Carbon::createFromFormat('Y-m', $bulanQuery);
            $startDate = $parsed->copy()->startOfMonth()->toDateString();
            $endDate = $parsed->copy()->endOfMonth()->toDateString();

            $transaksis = Keuangan::where('Id_User', $idPengguna)
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

    // ============================================================
    // 3. MUTASI (dengan filter bulan & tahun opsional)
    // ============================================================
    public function mutasi(Request $request): JsonResponse
    {
        try {
            $idPengguna = $this->idPengguna($request);
            $bulan = $request->query('bulan');
            $tahun = $request->query('tahun');

            $query = Keuangan::where('Id_User', $idPengguna);

            if ($bulan && $tahun) {
                // Buat tanggal awal dan akhir bulan
                $date = Carbon::createFromDate((int) $tahun, (int) $bulan, 1);
                $startDate = $date->copy()->startOfMonth()->toDateString();
                $endDate = $date->copy()->endOfMonth()->toDateString();
                $query->whereBetween('Tanggal', [$startDate, $endDate]);
            }

            $transaksis = $query->orderBy('Tanggal', 'desc')
                                ->orderBy('Waktu', 'desc')
                                ->get();

            $dikelompokkan = $transaksis
                ->groupBy(fn($item) => $this->labelTanggal($item['Tanggal']))
                ->map(fn($items, $label) => [
                    'tanggal_label' => $label,
                    'total_keluar'  => (double) $items->sum('Total_Pengeluaran'),
                    'transaksi'     => $items->map(fn($item) => $this->formatKeuangan($item))->values(),
                ])->values();

            return response()->json([
                'success' => true,
                'message' => 'Data mutasi berhasil diambil.',
                'data'    => $dikelompokkan,
            ], 200);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // 4. DETAIL
    // ============================================================
    public function detail(Request $request, string $id): JsonResponse
    {
        try {
            $idPengguna = $this->idPengguna($request);
            $transaksi = Keuangan::where('Id_User', $idPengguna)
                ->where('_id', new ObjectId($id))
                ->first();

            if (!$transaksi) {
                return response()->json([
                    'success' => false,
                    'message' => 'Transaksi tidak ditemukan.',
                ], 404);
            }

            return response()->json([
                'success' => true,
                'message' => 'Detail transaksi berhasil diambil.',
                'data'    => $this->formatKeuangan($transaksi),
            ], 200);
        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // HELPER
    // ============================================================
    private function labelTanggal(string $tanggal): string
    {
        $tgl = Carbon::parse($tanggal)->startOfDay();
        $hariIni = Carbon::now()->startOfDay();

        if ($tgl->equalTo($hariIni)) {
            return 'Hari ini';
        } elseif ($tgl->equalTo($hariIni->copy()->subDay())) {
            return 'Kemarin';
        } elseif ($tgl->year === Carbon::now()->year) {
            return $tgl->translatedFormat('j M');
        } else {
            return $tgl->translatedFormat('j M Y');
        }
    }

    private function formatKeuangan(Keuangan $keuangan): array
    {
        $jenisMapping = ['Masak' => 'cook', 'Beli' => 'food'];
        $jenis = $jenisMapping[$keuangan->Jenis_Pengeluaran] ?? 'food';

        $detail = $keuangan->Detail_Beli;
        $judul = '';
        $keterangan = '';
        if ($detail && is_array($detail) && count($detail) > 0) {
            $judul = $detail[0]['nama'] ?? 'Transaksi';
            $keterangan = count($detail) . ' item';
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
            'is_debit'          => true,
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