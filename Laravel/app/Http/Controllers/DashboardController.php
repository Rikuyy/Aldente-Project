<?php

namespace App\Http\Controllers;

<<<<<<< HEAD
use Illuminate\Http\Request;
use App\Models\Budget;
use App\Models\Expense;
use App\Models\Inventory;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function summary(Request $request)
    {
        $userId = $request->user()->id;
        $today = Carbon::today();
        $startOfWeek = Carbon::now()->startOfWeek();
        $endOfWeek = Carbon::now()->endOfWeek();

        $budget = Budget::where('user_id', $userId)->whereDate('tanggal', $today)->first();
        $pengeluaranHariIni = Expense::where('user_id', $userId)->whereDate('tanggal', $today)->sum('jumlah');
        $sisaBudgetHariIni = $budget ? max(0, $budget->total_budget_harian - $pengeluaranHariIni) : 0;
        $pengeluaranMingguIni = Expense::where('user_id', $userId)->whereBetween('tanggal', [$startOfWeek, $endOfWeek])->sum('jumlah');
        $budgetMingguIni = $budget ? $budget->total_budget_harian * 7 : 0;
        $sisaBudgetMingguIni = max(0, $budgetMingguIni - $pengeluaranMingguIni);
        $persenSisa = $budgetMingguIni > 0 ? ($sisaBudgetMingguIni / $budgetMingguIni) * 100 : 0;

        $statusBudget = 'aman';
        $pesanStatus = 'Budget kamu masih aman hari ini!';
        if ($persenSisa <= 20) {
            $statusBudget = 'bahaya';
            $pesanStatus = 'Sisa uang makan tinggal ' . round($persenSisa) . '% dari jatah minggu ini. Hati-hati defisit!';
        } elseif ($persenSisa <= 50) {
            $statusBudget = 'waspada';
            $pesanStatus = 'Sisa uang makan tinggal ' . round($persenSisa) . '% dari jatah minggu ini. Mulai hemat!';
        }

        $bahanHabis = Inventory::where('user_id', $userId)->whereIn('status', ['hampir_habis', 'habis'])->get(['nama_bahan', 'jumlah', 'satuan', 'status']);

        return response()->json([
            'success' => true,
            'data'    => [
                'nama_user'              => $request->user()->name,
                'tanggal'                => $today->format('Y-m-d'),
                'budget_harian'          => $budget ? $budget->total_budget_harian : 0,
                'pengeluaran_hari_ini'   => $pengeluaranHariIni,
                'sisa_budget_hari_ini'   => $sisaBudgetHariIni,
                'sisa_budget_minggu_ini' => $sisaBudgetMingguIni,
                'status_budget'          => $statusBudget,
                'pesan_status'           => $pesanStatus,
                'persen_sisa'            => round($persenSisa, 1),
                'bahan_habis'            => $bahanHabis,
            ]
        ]);
    }

    public function laporan(Request $request)
    {
        $userId = $request->user()->id;
        $today = Carbon::today();
        $periode = $request->query('periode', 'minggu');

        if ($periode === 'bulan') {
            $startDate = Carbon::now()->startOfMonth();
            $endDate = Carbon::now()->endOfMonth();
        } else {
            $startDate = Carbon::now()->startOfWeek();
            $endDate = Carbon::now()->endOfWeek();
        }

        $totalPengeluaran = Expense::where('user_id', $userId)->whereBetween('tanggal', [$startDate, $endDate])->sum('jumlah');
        $jumlahHari = $startDate->diffInDays($today) + 1;
        $rataRataPerHari = $jumlahHari > 0 ? $totalPengeluaran / $jumlahHari : 0;

        $periodePanjang = $startDate->diffInDays($endDate) + 1;
        $prevStart = $startDate->copy()->subDays($periodePanjang);
        $prevEnd = $startDate->copy()->subDay();
        $totalSebelumnya = Expense::where('user_id', $userId)->whereBetween('tanggal', [$prevStart, $prevEnd])->sum('jumlah');
        $persenPerubahan = $totalSebelumnya > 0 ? (($totalPengeluaran - $totalSebelumnya) / $totalSebelumnya) * 100 : 0;

        $grafikHarian = [];
        for ($i = 6; $i >= 0; $i--) {
            $tanggal = Carbon::today()->subDays($i);
            $total = Expense::where('user_id', $userId)->whereDate('tanggal', $tanggal)->sum('jumlah');
            $grafikHarian[] = ['hari' => $tanggal->locale('id')->isoFormat('ddd'), 'tanggal' => $tanggal->format('Y-m-d'), 'total' => (float) $total];
        }

        $totalMasakSendiri = Expense::where('user_id', $userId)->where('kategori', 'masak_sendiri')->whereBetween('tanggal', [$startDate, $endDate])->sum('jumlah');
        $totalJajan = Expense::where('user_id', $userId)->where('kategori', 'jajan')->whereBetween('tanggal', [$startDate, $endDate])->sum('jumlah');
        $totalKeseluruhan = $totalMasakSendiri + $totalJajan;
        $persenMasakSendiri = $totalKeseluruhan > 0 ? round(($totalMasakSendiri / $totalKeseluruhan) * 100) : 0;

        $hariDalamBulan = Carbon::now()->daysInMonth;
        $hariTerlewat = Carbon::now()->day;
        $prediksiAkhirBulan = $hariTerlewat > 0 ? ($totalPengeluaran / $hariTerlewat) * $hariDalamBulan : 0;
        $budget = Budget::where('user_id', $userId)->whereDate('tanggal', $today)->first();
        $budgetBulanan = $budget ? $budget->total_budget_harian * $hariDalamBulan : 0;

        return response()->json([
            'success' => true,
            'data'    => [
                'periode'              => $periode,
                'total_pengeluaran'    => (float) $totalPengeluaran,
                'rata_rata_per_hari'   => round($rataRataPerHari),
                'persen_perubahan'     => round(abs($persenPerubahan), 1),
                'trend_naik'           => $persenPerubahan > 0,
                'grafik_harian'        => $grafikHarian,
                'komposisi'            => [
                    'masak_sendiri'        => (float) $totalMasakSendiri,
                    'jajan'                => (float) $totalJajan,
                    'persen_masak_sendiri' => $persenMasakSendiri,
                    'persen_jajan'         => 100 - $persenMasakSendiri,
                ],
                'prediksi_akhir_bulan' => round($prediksiAkhirBulan),
                'budget_bulanan'       => (float) $budgetBulanan,
                'is_defisit'           => $prediksiAkhirBulan > $budgetBulanan,
            ]
        ]);
=======
use App\Models\Resep; // Pastikan Model Resep sudah ada
use Illuminate\Http\Request;
use Carbon\Carbon; // Untuk format waktu

class DashboardController extends Controller
{
    public function index()
    {
        // 1. Total Resep
        $totalResep = Resep::count();

        // 2. Resep Paling Disukai (Loves tertinggi)
        $resepPopuler = Resep::orderBy('Loves', 'desc')->first();
        $namaResepPopuler = $resepPopuler ? $resepPopuler['Title Cleaned'] : 'Belum Ada';

        // 3. Rata-rata Bahan (Kompleksitas)
        // Ambil rata-rata dari kolom 'Total Ingredients', bulatkan angkanya
        $rataBahanRaw = Resep::avg('Total Ingredients');
        $rataBahan = $rataBahanRaw ? round($rataBahanRaw) : 0;

        // 4. Jejak Update AI (Data resep terakhir diubah)
        $resepTerakhir = Resep::orderBy('updated_at', 'desc')->first();
        if ($resepTerakhir && isset($resepTerakhir->updated_at)) {
            // Ubah format jadi misal: "03 Mei 2026, 14:30"
            $waktuUpdate = Carbon::parse($resepTerakhir->updated_at)->timezone('Asia/Jakarta')->translatedFormat('d M Y, H:i');
        } else {
            $waktuUpdate = 'Belum ada data';
        }

        // 5. Tabel Aktivitas (Ambil 5 resep paling baru)
        $resepTerbaru = Resep::orderBy('updated_at', 'desc')->take(5)->get();

        // Lempar semua variabel di atas ke file view dashboard.blade.php
        return view('dashboard', compact(
            'totalResep', 
            'namaResepPopuler', 
            'rataBahan', 
            'waktuUpdate', 
            'resepTerbaru'
        ));
>>>>>>> 6e0998e2e85b3d5cd7cc289d45055d4409ca031d
    }
}