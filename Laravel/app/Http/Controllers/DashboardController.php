<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Budget;
use App\Models\Expense;
use App\Models\Inventory;
use Carbon\Carbon;

class DashboardController extends Controller
{
    /**
     * GET /api/dashboard/summary
     * Ambil ringkasan dashboard user hari ini
     */
    public function summary(Request $request)
    {
        $userId = $request->user()->id;
        $today = Carbon::today();

        // Ambil budget hari ini
        $budget = Budget::where('user_id', $userId)
            ->whereDate('tanggal', $today)
            ->first();

        // Ambil total pengeluaran hari ini
        $totalPengeluaranHariIni = Expense::where('user_id', $userId)
            ->whereDate('tanggal', $today)
            ->sum('jumlah');

        // Ambil pengeluaran 7 hari terakhir untuk grafik
        $pengeluaranHarian = Expense::where('user_id', $userId)
            ->whereBetween('tanggal', [Carbon::today()->subDays(6), $today])
            ->selectRaw('DATE(tanggal) as tanggal, SUM(jumlah) as total')
            ->groupBy('tanggal')
            ->orderBy('tanggal')
            ->get();

        // Ambil bahan yang hampir habis atau habis
        $bahanHabis = Inventory::where('user_id', $userId)
            ->whereIn('status', ['hampir_habis', 'habis'])
            ->get(['nama_bahan', 'jumlah', 'satuan', 'status']);

        // Hitung sisa budget hari ini
        $sisaBudget = $budget ? $budget->total_budget_harian - $totalPengeluaranHariIni : 0;

        // Tentukan status budget
        $status = 'aman';
        if ($budget) {
            $persenTerpakai = ($totalPengeluaranHariIni / $budget->total_budget_harian) * 100;
            if ($persenTerpakai >= 100) {
                $status = 'bahaya';
            } elseif ($persenTerpakai >= 75) {
                $status = 'hemat';
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'nama_user'             => $request->user()->name,
                'tanggal'               => $today->format('Y-m-d'),
                'total_budget_harian'   => $budget ? $budget->total_budget_harian : 0,
                'total_pengeluaran'     => $totalPengeluaranHariIni,
                'sisa_budget'           => $sisaBudget,
                'status_budget'         => $status,
                'pengeluaran_harian'    => $pengeluaranHarian,
                'bahan_habis'           => $bahanHabis,
            ]
        ]);
    }

    /**
     * GET /api/dashboard/pengeluaran-harian
     * Ambil pengeluaran harian untuk grafik laporan
     */
    public function pengeluaranHarian(Request $request)
    {
        $userId = $request->user()->id;

        // Default 30 hari terakhir
        $hari = $request->query('hari', 30);

        $pengeluaran = Expense::where('user_id', $userId)
            ->whereBetween('tanggal', [Carbon::today()->subDays($hari - 1), Carbon::today()])
            ->selectRaw('DATE(tanggal) as tanggal, SUM(jumlah) as total, kategori')
            ->groupBy('tanggal', 'kategori')
            ->orderBy('tanggal')
            ->get();

        // Hitung total per kategori
        $totalMasakSendiri = Expense::where('user_id', $userId)
            ->where('kategori', 'masak_sendiri')
            ->whereBetween('tanggal', [Carbon::today()->subDays($hari - 1), Carbon::today()])
            ->sum('jumlah');

        $totalJajan = Expense::where('user_id', $userId)
            ->where('kategori', 'jajan')
            ->whereBetween('tanggal', [Carbon::today()->subDays($hari - 1), Carbon::today()])
            ->sum('jumlah');

        $totalKeseluruhan = $totalMasakSendiri + $totalJajan;

        return response()->json([
            'success' => true,
            'data' => [
                'pengeluaran_harian'    => $pengeluaran,
                'total_masak_sendiri'   => $totalMasakSendiri,
                'total_jajan'           => $totalJajan,
                'total_keseluruhan'     => $totalKeseluruhan,
                'persen_masak_sendiri'  => $totalKeseluruhan > 0
                    ? round(($totalMasakSendiri / $totalKeseluruhan) * 100, 1)
                    : 0,
                'persen_jajan'          => $totalKeseluruhan > 0
                    ? round(($totalJajan / $totalKeseluruhan) * 100, 1)
                    : 0,
            ]
        ]);
    }
}