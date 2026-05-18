<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Budget;
use App\Models\Keuangan;
use App\Models\Resep;
use Illuminate\Http\Request;
use Carbon\Carbon;

class DashboardController extends Controller
{
    // ─────────────────────────────────────────
    // GET /api/dashboard
    // ─────────────────────────────────────────
    public function index(Request $request)
    {
        $user   = $request->user();
        $userId = $user->id;
        $now    = Carbon::now();

        $bulan      = $now->format('Y-m');
        $awalBulan  = $now->copy()->startOfMonth()->toDateString();
        $akhirBulan = $now->copy()->endOfMonth()->toDateString();
        $sisaHari   = $now->daysInMonth - $now->day + 1;

        // ── 1. Budget bulan ini ──────────────────
        $budget      = Budget::where('Id_User', $userId)->where('Bulan', $bulan)->first();
        $totalBudget = $budget ? $budget->Total_Budget : 0;

        // ── 2. Total pengeluaran bulan ini ───────
        $totalKeluar = Keuangan::where('Id_User', $userId)
            ->whereBetween('Tanggal', [$awalBulan, $akhirBulan])
            ->sum('Total Pengeluaran');

        // ── 3. Hitung sisa ───────────────────────
        $sisaBulan   = max($totalBudget - $totalKeluar, 0);
        $sisaHariIni = $sisaHari > 0 ? round($sisaBulan / $sisaHari) : 0;

        // ── 4. Status warning ────────────────────
        $persenSisa = $totalBudget > 0
            ? round(($sisaBulan / $totalBudget) * 100)
            : 0;

        if ($persenSisa <= 10) {
            $statusBudget = 'Kritis';
            $warningMsg   = "Sisa budget tinggal {$persenSisa}%! Segera kurangi pengeluaran.";
        } elseif ($persenSisa <= 20) {
            $statusBudget = 'Waspada';
            $warningMsg   = "Sisa uang makan tinggal {$persenSisa}% dari jatah bulan ini. Hati-hati defisit!";
        } else {
            $statusBudget = 'Aman';
            $warningMsg   = null;
        }

        // ── 5. Rekomendasi Resep ─────────────────
        $kategoriFavorit = $user->Kategori_Favorit;
        $alergi          = $user->Alergi; // nullable

        // Filter berdasarkan kategori favorit user, urutkan loves terbanyak
        $query = Resep::where('Category', $kategoriFavorit)
            ->orderBy('Loves', 'desc');

        // Exclude resep yang mengandung bahan alergi user
        // Alergi disimpan sebagai string dipisah koma, misal: "udang, kacang, susu"
        if (!empty($alergi)) {
            $daftarAlergi = array_map('trim', explode(',', $alergi));
            foreach ($daftarAlergi as $bahan) {
                $query->where('Ingredients Cleaned', 'not like', "%{$bahan}%");
            }
        }

        $rekomendasi = $query->take(10)->get([
            '_id',
            'Title Cleaned',
            'Category',
            'Loves',
            'Total Ingredients',
            'Total Steps',
        ]);

        // ── 6. User info ─────────────────────────
        $nama    = $user->Username ?? 'User';
        $inisial = strtoupper(substr($nama, 0, 1));

        return response()->json([
            'user' => [
                'nama'             => $nama,
                'inisial'          => $inisial,
                'kategori_favorit' => $kategoriFavorit,
                'alergi'           => $alergi,
            ],
            'budget' => [
                'total_budget'  => $totalBudget,
                'total_keluar'  => $totalKeluar,
                'sisa_bulan'    => $sisaBulan,
                'sisa_hari_ini' => $sisaHariIni,
                'persen_sisa'   => $persenSisa,
                'status'        => $statusBudget,
                'warning_msg'   => $warningMsg,
            ],
            'rekomendasi_resep' => $rekomendasi,
        ]);
    }

    // ─────────────────────────────────────────
    // POST /api/dashboard/budget
    // Set / update budget bulan ini
    // ─────────────────────────────────────────
    public function setBudget(Request $request)
    {
        $request->validate([
            'total_budget' => 'required|numeric|min:0',
            'bulan'        => 'nullable|date_format:Y-m',
        ]);

        $userId = $request->user()->id;
        $bulan  = $request->input('bulan', Carbon::now()->format('Y-m'));

        $budget = Budget::updateOrCreate(
            ['Id_User' => $userId, 'Bulan' => $bulan],
            ['Total_Budget' => $request->total_budget]
        );

        return response()->json([
            'message' => 'Budget berhasil disimpan',
            'data'    => $budget,
        ]);
    }
}