<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Keuangan;
use App\Models\Resep;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        try {
            $pengguna = $request->user();
            $idPengguna = $pengguna->id;
            $sekarang   = Carbon::now();

            $awalBulan  = $sekarang->copy()->startOfMonth()->toDateString();
            $akhirBulan = $sekarang->copy()->endOfMonth()->toDateString();
            $sisaHari   = $sekarang->daysInMonth - $sekarang->day + 1;

            $totalBudget = $pengguna->Budget_Bulanan ?? 0;

            $totalKeluar = Keuangan::where('Id_User', $idPengguna)
                ->whereBetween('Tanggal', [$awalBulan, $akhirBulan])
                ->sum('Total_Pengeluaran');

            $sisaBulan   = max($totalBudget - $totalKeluar, 0);
            $sisaHariIni = $sisaHari > 0 ? round($sisaBulan / $sisaHari) : 0;

            $persenSisa = $totalBudget > 0
                ? round(($sisaBulan / $totalBudget) * 100)
                : 0;

            if ($persenSisa <= 10) {
                $statusBudget    = 'Kritis';
                $pesanPeringatan = "Sisa budget tinggal {$persenSisa}%! Segera kurangi pengeluaran.";
            } elseif ($persenSisa <= 20) {
                $statusBudget    = 'Waspada';
                $pesanPeringatan = "Sisa uang makan tinggal {$persenSisa}% dari jatah bulan ini. Hati-hati defisit!";
            } else {
                $statusBudget    = 'Aman';
                $pesanPeringatan = null;
            }

            // Kategori favorit bisa array
            $kategoriFavorit = $pengguna->Kategori_Favorit;
            $alergi          = $pengguna->Alergi;

            $query = Resep::query();

            if (!empty($kategoriFavorit)) {
                if (is_array($kategoriFavorit)) {
                    $query->whereIn('Category', $kategoriFavorit);
                } else {
                    $query->where('Category', $kategoriFavorit);
                }
            }

            if (!empty($alergi) && is_array($alergi)) {
                foreach ($alergi as $bahan) {
                    $query->where('Ingredients_Cleaned', 'not like', "%{$bahan}%");
                }
            }

            $rekomendasiResep = $query->orderBy('Loves', 'desc')
                ->take(10)
                ->get([
                    '_id',
                    'Title Cleaned',
                    'Category',
                    'Loves',
                    'Total Ingredients',
                    'Total Steps',
                ]);

            $nama    = $pengguna->Username ?? 'Pengguna';
            $inisial = strtoupper(substr($nama, 0, 1));

            return response()->json([
                'success' => true,
                'message' => 'Data dashboard berhasil diambil.',
                'data'    => [
                    'pengguna' => [
                        'nama'             => $nama,
                        'inisial'          => $inisial,
                        'kategori_favorit' => $kategoriFavorit,
                        'alergi'           => $alergi,
                    ],
                    'budget' => [
                        'total_budget'     => (int) $totalBudget,
                        'total_keluar'     => (int) $totalKeluar,
                        'sisa_bulan'       => (int) $sisaBulan,
                        'sisa_hari_ini'    => (int) $sisaHariIni,
                        'persen_sisa'      => $persenSisa,
                        'status'           => $statusBudget,
                        'pesan_peringatan' => $pesanPeringatan,
                    ],
                    'rekomendasi_resep' => $rekomendasiResep,
                ],
            ], 200);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    public function simpanBudget(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'total_budget' => ['required', 'numeric', 'min:0'],
            ]);

            $pengguna = $request->user();
            $pengguna->Budget_Bulanan = $request->total_budget;
            $pengguna->save();

            return response()->json([
                'success' => true,
                'message' => 'Budget berhasil disimpan.',
                'data'    => [
                    'budget_bulanan' => $pengguna->Budget_Bulanan,
                ],
            ], 200);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
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