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
    // ============================================================
    // 1. GET /api/dashboard
    // ============================================================
    public function index(Request $request): JsonResponse
    {
        try {
            $pengguna = $request->user();
            $idPengguna = $pengguna->id;
            $sekarang   = Carbon::now();

            $bulan      = $sekarang->format('Y-m');
            $awalBulan  = $sekarang->copy()->startOfMonth()->toDateString();
            $akhirBulan = $sekarang->copy()->endOfMonth()->toDateString();
            $sisaHari   = $sekarang->daysInMonth - $sekarang->day + 1;

            // ── 1. Budget dari field user ────────────────────────────
            $totalBudget = $pengguna->Budget_Bulanan ?? 0;

            // ── 2. Total pengeluaran bulan ini ───────────────────────
            $totalKeluar = Keuangan::where('Id_User', $idPengguna)
                ->whereBetween('Tanggal', [$awalBulan, $akhirBulan])
                ->sum('Total_Pengeluaran');

            // ── 3. Hitung sisa ───────────────────────────────────────
            $sisaBulan   = max($totalBudget - $totalKeluar, 0);
            $sisaHariIni = $sisaHari > 0 ? round($sisaBulan / $sisaHari) : 0;

            // ── 4. Status peringatan ─────────────────────────────────
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

            // ── 5. Rekomendasi resep ─────────────────────────────────
            $kategoriFavorit = $pengguna->Kategori_Favorit;
            $alergi          = $pengguna->Alergi;

            $query = Resep::where('Category', $kategoriFavorit)
                          ->orderBy('Loves', 'desc');

            if (!empty($alergi)) {
                $daftarAlergi = is_array($alergi)
                    ? $alergi
                    : array_map('trim', explode(',', $alergi));

                foreach ($daftarAlergi as $bahan) {
                    $query->where('Ingredients_Cleaned', 'not like', "%{$bahan}%");
                }
            }

            $rekomendasiResep = $query->take(10)->get([
                '_id',
                'Title Cleaned',
                'Category',
                'Loves',
                'Total Ingredients',
                'Total Steps',
            ]);

            // ── 6. Info pengguna ─────────────────────────────────────
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
                        'total_budget'     => $totalBudget,
                        'total_keluar'     => $totalKeluar,
                        'sisa_bulan'       => $sisaBulan,
                        'sisa_hari_ini'    => $sisaHariIni,
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

    // ============================================================
    // 2. POST /api/dashboard/budget
    // Simpan budget bulanan ke field Budget_Bulanan di users
    // ============================================================
    public function simpanBudget(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'total_budget' => ['required', 'numeric', 'min:0'],
            ], [
                'total_budget.required' => 'Total budget wajib diisi.',
                'total_budget.numeric'  => 'Total budget harus berupa angka.',
                'total_budget.min'      => 'Total budget tidak boleh negatif.',
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

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak valid.',
                'errors'  => $e->errors(),
            ], 422);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // Helper: response error 500
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