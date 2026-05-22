<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Keuangan;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;

class KeuanganController extends Controller
{
    // ============================================================
    // Helper: ambil ID pengguna dari token login
    // ============================================================
    private function idPengguna(Request $request): string
    {
        return $request->user()->id;
    }

    // ============================================================
    // 1. GET /api/keuangan/ringkasan?bulan=2025-05
    // Ringkasan pengeluaran bulanan: total, rata-rata, prediksi, tren
    // ============================================================
    public function ringkasan(Request $request): JsonResponse
    {
        try {
            $idPengguna = $this->idPengguna($request);

            $bulan  = $request->query('bulan', Carbon::now()->format('Y-m'));
            $parsed = Carbon::createFromFormat('Y-m', $bulan);

            $awalBulan      = $parsed->copy()->startOfMonth()->toDateString();
            $akhirBulan     = $parsed->copy()->endOfMonth()->toDateString();
            $hariDalamBulan = $parsed->daysInMonth;

            $transaksi = Keuangan::where('id_pengguna', $idPengguna)
                ->whereBetween('tanggal', [$awalBulan, $akhirBulan])
                ->get();

            // ── Total & rata-rata ────────────────────────────────────
            $totalPengeluaran = $transaksi->where('is_debit', true)->sum('jumlah');
            $totalPemasukan   = $transaksi->where('is_debit', false)->sum('jumlah');
            $saldo            = $totalPemasukan - $totalPengeluaran;

            $jumlahHari  = $transaksi->where('is_debit', true)->groupBy('tanggal')->count();
            $rataPerHari = $jumlahHari > 0
                ? round($totalPengeluaran / $jumlahHari)
                : 0;

            // ── Prediksi akhir bulan ─────────────────────────────────
            $hariIni       = min(Carbon::now()->day, $hariDalamBulan);
            $prediksiAkhir = $hariDalamBulan > 0
                ? round(($totalPengeluaran / max($hariIni, 1)) * $hariDalamBulan)
                : 0;

            // ── Komposisi 3 kategori (sesuai pie chart Flutter) ──────
            // jenis_pengeluaran: 'Masak Sendiri' | 'Beli di Luar' | 'Belanja Bahan'
            $totalMasak    = $transaksi->where('jenis_pengeluaran', 'Masak Sendiri')->sum('jumlah');
            $totalBeliLuar = $transaksi->where('jenis_pengeluaran', 'Beli di Luar')->sum('jumlah');
            $totalBelanja  = $transaksi->where('jenis_pengeluaran', 'Belanja Bahan')->sum('jumlah');

            $persenMasak = $totalPengeluaran > 0
                ? round(($totalMasak / $totalPengeluaran) * 100)
                : 0;

            // ── Tren vs bulan lalu ───────────────────────────────────
            $awalBulanLalu  = $parsed->copy()->subMonth()->startOfMonth()->toDateString();
            $akhirBulanLalu = $parsed->copy()->subMonth()->endOfMonth()->toDateString();

            $totalBulanLalu = Keuangan::where('id_pengguna', $idPengguna)
                ->whereBetween('tanggal', [$awalBulanLalu, $akhirBulanLalu])
                ->where('is_debit', true)
                ->sum('jumlah');

            $trenPersen = $totalBulanLalu > 0
                ? round((($totalPengeluaran - $totalBulanLalu) / $totalBulanLalu) * 100, 1)
                : 0;

            // ── Status prediksi ──────────────────────────────────────
            // Ambil budget bulan ini dari koleksi keuangan (pemasukan/topup)
            $totalBudget     = $transaksi->where('jenis_pengeluaran', 'Pengisian Budget')->sum('jumlah');
            $isDefisit       = $prediksiAkhir > $totalBudget && $totalBudget > 0;
            $pesanPrediksi   = $isDefisit
                ? "Dengan pengeluaran saat ini, diprediksi total pengeluaran akhir bulan mencapai Rp " .
                  number_format($prediksiAkhir, 0, ',', '.') .
                  " (melebihi budget Rp " . number_format($totalBudget, 0, ',', '.') . "). Kurangi jajan di luar!"
                : null;

            return response()->json([
                'success' => true,
                'message' => 'Ringkasan keuangan berhasil diambil.',
                'data'    => [
                    'bulan'             => $bulan,
                    'saldo'             => $saldo,
                    'total_pemasukan'   => $totalPemasukan,
                    'total_pengeluaran' => $totalPengeluaran,
                    'rata_per_hari'     => $rataPerHari,
                    'prediksi_akhir_bulan' => $prediksiAkhir,
                    'tren_persen'       => $trenPersen, // positif = naik, negatif = turun
                    'prediksi_defisit'  => $isDefisit,
                    'pesan_prediksi'    => $pesanPrediksi,
                    'komposisi'         => [
                        // Urutan sesuai pie chart Flutter
                        ['kategori' => 'Masak Sendiri',  'jumlah' => $totalMasak,    'warna' => 'orange'],
                        ['kategori' => 'Beli di Luar',   'jumlah' => $totalBeliLuar, 'warna' => 'blue'],
                        ['kategori' => 'Belanja Bahan',  'jumlah' => $totalBelanja,  'warna' => 'green'],
                    ],
                    'persen_masak' => $persenMasak,
                ],
            ], 200);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // 2. GET /api/keuangan/grafik?bulan=2025-05
    // Data grafik tren pengeluaran harian dalam satu bulan
    // ============================================================
    public function grafik(Request $request): JsonResponse
    {
        try {
            $idPengguna = $this->idPengguna($request);

            $bulan  = $request->query('bulan', Carbon::now()->format('Y-m'));
            $parsed = Carbon::createFromFormat('Y-m', $bulan);

            $awalBulan  = $parsed->copy()->startOfMonth()->toDateString();
            $akhirBulan = $parsed->copy()->endOfMonth()->toDateString();

            $transaksi = Keuangan::where('id_pengguna', $idPengguna)
                ->whereBetween('tanggal', [$awalBulan, $akhirBulan])
                ->where('is_debit', true)
                ->get(['tanggal', 'jumlah']);

            // Kelompokkan per tanggal, jumlahkan pengeluaran per hari
            $dikelompokkan = $transaksi
                ->groupBy('tanggal')
                ->map(fn($baris) => $baris->sum('jumlah'));

            // Buat array lengkap semua hari dalam bulan (hari tanpa transaksi = 0)
            $hariDalamBulan = $parsed->daysInMonth;
            $dataGrafik     = [];

            for ($hari = 1; $hari <= $hariDalamBulan; $hari++) {
                $tanggal      = $parsed->copy()->day($hari)->toDateString();
                $dataGrafik[] = [
                    'tanggal' => $tanggal,
                    'hari'    => $hari,
                    'jumlah'  => $dikelompokkan[$tanggal] ?? 0,
                ];
            }

            return response()->json([
                'success' => true,
                'message' => 'Data grafik keuangan berhasil diambil.',
                'data'    => [
                    'bulan'       => $bulan,
                    'per_tanggal' => $dataGrafik,
                ],
            ], 200);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // 3. GET /api/keuangan/mutasi?bulan=2025-05&tahun=2025&page=1
    // Daftar mutasi pengeluaran, dikelompokkan per tanggal
    // Filter: bulan (1-12 atau 0=semua) & tahun (0=semua)
    // ============================================================
    public function mutasi(Request $request): JsonResponse
    {
        try {
            $idPengguna = $this->idPengguna($request);

            $bulan = (int) $request->query('bulan', 0);  // 0 = semua bulan
            $tahun = (int) $request->query('tahun', 0);  // 0 = semua tahun

            $query = Keuangan::where('id_pengguna', $idPengguna)
                ->orderBy('tanggal', 'desc')
                ->orderBy('waktu', 'desc');

            // Filter bulan & tahun sesuai pilihan di Flutter
            if ($tahun > 0) {
                $query->whereYear('tanggal', $tahun);
            }
            if ($bulan > 0) {
                $query->whereMonth('tanggal', $bulan);
            }

            $data = $query->paginate(20);

            // Format & kelompokkan per tanggal (seperti tampilan Flutter)
            $dikelompokkan = collect($data->items())
                ->groupBy(fn($item) => $this->labelTanggal($item->tanggal))
                ->map(fn($items, $label) => [
                    'tanggal'         => $label,
                    'total_keluar'    => $items->where('is_debit', true)->sum('jumlah'),
                    'transaksi'       => $items->map(fn($item) => $this->formatKeuangan($item))->values(),
                ])->values();

            return response()->json([
                'success'      => true,
                'message'      => 'Data mutasi keuangan berhasil diambil.',
                'data'         => $dikelompokkan,
                'halaman'      => $data->currentPage(),
                'total_halaman' => $data->lastPage(),
                'total_data'   => $data->total(),
            ], 200);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // 4. GET /api/keuangan/{id}
    // Detail satu transaksi keuangan berdasarkan ID
    // ============================================================
    public function detail(Request $request, string $id): JsonResponse
    {
        try {
            $idPengguna = $this->idPengguna($request);

            $transaksi = Keuangan::where('id_pengguna', $idPengguna)
                ->where('_id', $id)
                ->first();

            if (!$transaksi) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data transaksi tidak ditemukan.',
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
    // Helper: label tanggal relatif (Hari ini, Kemarin, tgl bulan)
    // Sesuai tampilan grup mutasi di Flutter
    // ============================================================
    private function labelTanggal(string $tanggal): string
    {
        $tgl   = Carbon::parse($tanggal)->startOfDay();
        $hari  = Carbon::now()->startOfDay();

        if ($tgl->equalTo($hari)) {
            return 'Hari ini';
        } elseif ($tgl->equalTo($hari->copy()->subDay())) {
            return 'Kemarin';
        } elseif ($tgl->year === Carbon::now()->year) {
            return $tgl->translatedFormat('j M'); // "14 Mei"
        } else {
            return $tgl->translatedFormat('j M Y'); // "20 Des 2024"
        }
    }

    // ============================================================
    // Helper: format data keuangan ke response JSON
    // Sesuai field _Transaction di Flutter
    // ============================================================
    private function formatKeuangan(Keuangan $keuangan): array
    {
        return [
            '_id'              => $keuangan->_id,
            'judul'            => $keuangan->judul,            // title di Flutter
            'keterangan'       => $keuangan->keterangan,       // subtitle di Flutter
            'waktu'            => $keuangan->waktu,            // time di Flutter
            'tanggal'          => $keuangan->tanggal,          // date di Flutter
            'jumlah'           => $keuangan->jumlah,           // amount di Flutter
            'is_debit'         => $keuangan->is_debit,         // isDebit di Flutter
            'jenis_pengeluaran' => $keuangan->jenis_pengeluaran, // category di Flutter
            // Nilai category Flutter:
            // 'Masak Sendiri' → cook (hijau)
            // 'Beli di Luar'  → food (orange)
            // 'Belanja Bahan' → grocery (biru)
            // 'Pengisian Budget' → topup (ungu)
            // 'Refund'        → refund (hijau muda)
            'bulan'            => $keuangan->bulan,
            'tahun'            => $keuangan->tahun,
        ];
    }

    // ============================================================
    // Helper: response error 500 jika terjadi kendala server
    // ============================================================
    private function serverError(\Exception $e): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan server.',
            'error'   => $e->getMessage(),
        ], 500);
    }
}