<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Keuangan;
use Illuminate\Support\Facades\Auth;

class BudgetController extends Controller
{
    /**
     * GET /api/budget/balance
     */
    public function balance()
    {
        $user        = Auth::user();
        $totalBudget = (float) ($user->Budget_Bulanan ?? 0);
        $userId      = (string) $user->id;

        $awalBulan  = now()->startOfMonth()->format('Y-m-d');
        $akhirBulan = now()->endOfMonth()->format('Y-m-d');

        $totalPengeluaran = (float) Keuangan::where('Id_User', $userId)
            ->where('Tanggal', '>=', $awalBulan)
            ->where('Tanggal', '<=', $akhirBulan)
            ->sum('Total Pengeluaran');

        $selisih       = $totalBudget - $totalPengeluaran;
        $sisaBudget    = max(0, $selisih);
        $overBudget    = $selisih < 0 ? abs($selisih) : 0;
        $isOverBudget  = $selisih < 0;
        $persen        = $totalBudget > 0
            ? round(($totalPengeluaran / $totalBudget) * 100)
            : 0;

        return response()->json([
            'success'           => true,
            'total_budget'      => $totalBudget,
            'total_pengeluaran' => $totalPengeluaran,
            'sisa_budget'       => $sisaBudget,
            'over_budget'       => $overBudget,
            'is_over_budget'    => $isOverBudget,
            'persen_terpakai'   => min($persen, 100),
        ]);
    }
}