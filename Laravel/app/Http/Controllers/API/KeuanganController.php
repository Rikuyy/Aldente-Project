<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller; 
use App\Models\Keuangan;
use Illuminate\Http\Request;
use Carbon\Carbon;

class KeuanganController extends Controller
{
    // ─────────────────────────────────────────
    // Helper: ambil Id_User dari token login
    // ─────────────────────────────────────────
    private function userId(Request $request): string
    {
        return $request->user()->id; // sesuaikan kalau beda
    }

    // ─────────────────────────────────────────
    // 1. RINGKASAN BULANAN
    //    GET /api/keuangan/ringkasan?bulan=2025-05
    // ─────────────────────────────────────────
    public function ringkasan(Request $request)
    {
        $userId = $this->userId($request);

        // Default: bulan & tahun sekarang
        $bulan  = $request->query('bulan', Carbon::now()->format('Y-m'));
        $parsed = Carbon::createFromFormat('Y-m', $bulan);

        $awal  = $parsed->copy()->startOfMonth()->toDateString(); // "2025-05-01"
        $akhir = $parsed->copy()->endOfMonth()->toDateString();   // "2025-05-31"
        $hariDalamBulan = $parsed->daysInMonth;

        // Ambil semua transaksi bulan ini milik user
        $transaksi = Keuangan::where('Id_User', $userId)
            ->whereBetween('Tanggal', [$awal, $akhir])
            ->get();

        $totalPengeluaran = $transaksi->sum('Total Pengeluaran');
        $jumlahHari       = $transaksi->groupBy('Tanggal')->count(); // hari yang ada transaksi
        $rataPerHari      = $jumlahHari > 0
            ? round($totalPengeluaran / $jumlahHari)
            : 0;

        // Prediksi akhir bulan: rata-rata per hari × sisa hari
        $hariIni          = min(Carbon::now()->day, $hariDalamBulan);
        $prediksiAkhir    = $hariDalamBulan > 0
            ? round(($totalPengeluaran / max($hariIni, 1)) * $hariDalamBulan)
            : 0;

        // Komposisi: Masak vs Beli
        $totalMasak = $transaksi->where('Jenis_Pengeluaran', 'Masak')->sum('Total Pengeluaran');
        $totalBeli  = $transaksi->where('Jenis_Pengeluaran', 'Beli')->sum('Total Pengeluaran');
        $persen     = $totalPengeluaran > 0
            ? round(($totalMasak / $totalPengeluaran) * 100)
            : 0;

        // Bulan lalu untuk perbandingan trend
        $awalLalu  = $parsed->copy()->subMonth()->startOfMonth()->toDateString();
        $akhirLalu = $parsed->copy()->subMonth()->endOfMonth()->toDateString();

        $totalLalu = Keuangan::where('Id_User', $userId)
            ->whereBetween('Tanggal', [$awalLalu, $akhirLalu])
            ->sum('Total Pengeluaran');

        $trendPersen = $totalLalu > 0
            ? round((($totalPengeluaran - $totalLalu) / $totalLalu) * 100, 1)
            : 0;

        return response()->json([
            'bulan'              => $bulan,
            'total_pengeluaran'  => $totalPengeluaran,
            'rata_per_hari'      => $rataPerHari,
            'prediksi_akhir_bulan' => $prediksiAkhir,
            'trend_persen'       => $trendPersen,         // positif = naik, negatif = turun
            'komposisi' => [
                ['kategori' => 'Masak Sendiri', 'jumlah' => $totalMasak],
                ['kategori' => 'Beli / Jajan',  'jumlah' => $totalBeli],
            ],
            'persen_masak' => $persen,
        ]);
    }

    // ─────────────────────────────────────────
    // 2. GRAFIK TREN HARIAN
    //    GET /api/keuangan/grafik?bulan=2025-05
    // ─────────────────────────────────────────
    public function grafik(Request $request)
    {
        $userId = $this->userId($request);
        $bulan  = $request->query('bulan', Carbon::now()->format('Y-m'));
        $parsed = Carbon::createFromFormat('Y-m', $bulan);

        $awal  = $parsed->copy()->startOfMonth()->toDateString();
        $akhir = $parsed->copy()->endOfMonth()->toDateString();

        $transaksi = Keuangan::where('Id_User', $userId)
            ->whereBetween('Tanggal', [$awal, $akhir])
            ->get(['Tanggal', 'Total Pengeluaran']);

        // Group by tanggal, sum per hari
        $grouped = $transaksi
            ->groupBy('Tanggal')
            ->map(fn($rows) => $rows->sum('Total Pengeluaran'));

        // Buat array lengkap semua hari dalam bulan (hari tanpa transaksi = 0)
        $hariDalamBulan = $parsed->daysInMonth;
        $data = [];
        for ($d = 1; $d <= $hariDalamBulan; $d++) {
            $tgl    = $parsed->copy()->day($d)->toDateString();
            $data[] = [
                'tanggal' => $tgl,
                'hari'    => $d,
                'jumlah'  => $grouped[$tgl] ?? 0,
            ];
        }

        return response()->json([
            'bulan' => $bulan,
            'data'  => $data,
        ]);
    }

    // ─────────────────────────────────────────
    // 3. LIST MUTASI (kayak buku tabungan)
    //    GET /api/keuangan/mutasi?bulan=2025-05&page=1
    // ─────────────────────────────────────────
    public function mutasi(Request $request)
    {
        $userId = $this->userId($request);
        $bulan  = $request->query('bulan', Carbon::now()->format('Y-m'));
        $parsed = Carbon::createFromFormat('Y-m', $bulan);

        $awal  = $parsed->copy()->startOfMonth()->toDateString();
        $akhir = $parsed->copy()->endOfMonth()->toDateString();

        $data = Keuangan::where('Id_User', $userId)
            ->whereBetween('Tanggal', [$awal, $akhir])
            ->orderBy('Tanggal', 'desc')
            ->orderBy('Waktu', 'desc')
            ->paginate(20); // 20 item per halaman

        return response()->json($data);
    }

    // ─────────────────────────────────────────
    // 4. DETAIL SATU TRANSAKSI
    //    GET /api/keuangan/{id}
    // ─────────────────────────────────────────
    public function detail(Request $request, string $id)
    {
        $userId = $this->userId($request);

        $transaksi = Keuangan::where('Id_User', $userId)
            ->where('Id_Keuangan', $id)
            ->firstOrFail();

        return response()->json($transaksi);
    }
}