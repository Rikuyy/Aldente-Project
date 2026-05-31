<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Keuangan;
use App\Models\Resep;
use App\Models\RiwayatRekomendasi; 
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

            // 1. SIKLUS BUDGET & PERHITUNGAN HARI DINAMIS
            $tanggalMulaiStr = $pengguna->Tanggal_Mulai_Siklus ?? $pengguna->created_at;
            $tanggalMulai    = Carbon::parse($tanggalMulaiStr)->startOfDay();
            $targetBulanDepan = $tanggalMulai->copy()->addMonth()->startOfDay();

            // PENGECEKAN PINTAR: Apakah User sudah top-up manual dari halaman keuangan?
            // Jika hari ini Pop-Up harusnya muncul, TAPI user sudah inisiatif Top-Up manual, geser siklusnya!
            $topUpBaru = Keuangan::where('Id_User', $idPengguna)
                ->where('Kategori', 'Pemasukan')
                ->where('Keterangan', 'Top Up')
                ->whereDate('Tanggal', '>=', $targetBulanDepan->toDateString())
                ->orderBy('Tanggal', 'asc')
                ->first();

            if ($topUpBaru) {
                // Simpan tanggal Top Up manual tersebut sebagai awal siklus baru
                $pengguna->Tanggal_Mulai_Siklus = Carbon::parse($topUpBaru->Tanggal)->toDateString();
                $pengguna->save();

                // Hitung ulang patokan tanggal berdasarkan siklus yang baru digeser
                $tanggalMulai = Carbon::parse($pengguna->Tanggal_Mulai_Siklus)->startOfDay();
                $targetBulanDepan = $tanggalMulai->copy()->addMonth()->startOfDay();
            }
            
            // Tentukan apakah pop-up harus muncul (Berdasarkan siklus terupdate)
            $isBudgetDue = $sekarang->greaterThanOrEqualTo($targetBulanDepan);
            
            // Hitung total hari dalam siklus (Misal: 28, 29, 30, atau 31)
            $totalHariSiklus = max($tanggalMulai->diffInDays($targetBulanDepan), 1);
            
            // Hari ke-X saat ini
            $hariKe = max($tanggalMulai->diffInDays($sekarang->copy()->startOfDay()) + 1, 1);

            // 2. SINKRONISASI SALDO KEUANGAN
            $totalPemasukan = Keuangan::where('Id_User', $idPengguna)
                ->where('Kategori', 'Pemasukan')
                ->whereBetween('Tanggal', [$tanggalMulai->toDateString(), $targetBulanDepan->toDateString()])
                ->sum('Total_Nominal');

            $totalKeluar = Keuangan::where('Id_User', $idPengguna)
                ->where('Kategori', 'Pengeluaran')
                ->whereBetween('Tanggal', [$tanggalMulai->toDateString(), $targetBulanDepan->toDateString()])
                ->sum('Total_Nominal');

            $sisaBulan = max($totalPemasukan - $totalKeluar, 0);
            
            // BUDGET PER HARI PRESISI
            $sisaHariAktif = max($totalHariSiklus - $hariKe + 1, 1);
            $budgetPerHari = round($sisaBulan / $sisaHariAktif);

            $persenSisa = $totalPemasukan > 0 ? round(($sisaBulan / $totalPemasukan) * 100) : 0;

            if ($persenSisa <= 10) {
                $statusBudget    = 'KRITIS';
                $pesanPeringatan = "Sisa budget tinggal {$persenSisa}%! Segera kurangi pengeluaran.";
            } elseif ($persenSisa <= 25) {
                $statusBudget    = 'WASPADA';
                $pesanPeringatan = "Sisa uang makan tinggal {$persenSisa}% dari total pemasukan.";
            } else {
                $statusBudget    = 'AMAN';
                $pesanPeringatan = null;
            }

            // 3. AMBIL AKTIVITAS TERAKHIR
            $transaksiTerakhir = Keuangan::where('Id_User', $idPengguna)->orderBy('created_at', 'desc')->first();
            $aktivitasTerakhir = null;
            if ($transaksiTerakhir) {
                $simbol = $transaksiTerakhir->Kategori == 'Pemasukan' ? '+' : '-';
                $aktivitasTerakhir = [
                    'nominal' => $simbol . ' Rp ' . number_format($transaksiTerakhir->Total_Nominal, 0, ',', '.'),
                    'keterangan' => $transaksiTerakhir->Keterangan,
                    'kategori' => $transaksiTerakhir->Kategori
                ];
            }

            // 4. LOGIKA REKOMENDASI (KUNCI RESEP 1 HARI + FITUR REFRESH MANUAL)
            $forceRefresh = $request->query('force_refresh') === '1';
            
            $awalHari = $sekarang->copy()->startOfDay();
            $akhirHari = $sekarang->copy()->endOfDay();

            if ($forceRefresh) {
                RiwayatRekomendasi::where('user_id', $idPengguna)
                    ->whereBetween('created_at', [$awalHari, $akhirHari])
                    ->delete();
            }

            $historiHariIni = RiwayatRekomendasi::where('user_id', $idPengguna)
                                ->whereBetween('created_at', [$awalHari, $akhirHari])
                                ->pluck('resep_id')
                                ->toArray();

            if (count($historiHariIni) >= 11 && !$forceRefresh) {
                $rekomendasiResep = Resep::whereIn('_id', $historiHariIni)
                    ->get(['_id', 'Title Cleaned', 'Category', 'Loves', 'Ingredients Cleaned', 'Steps'])
                    ->values();
            } else {
                $alergi = $pengguna->Alergi;
                // Tetap hindari resep yang SUDAH PERNAH direkomendasikan sebelumnya
                $recentIds = RiwayatRekomendasi::where('user_id', $idPengguna)->pluck('resep_id')->toArray();
                $query = Resep::query();

                if (!empty($recentIds)) $query->whereNotIn('_id', $recentIds);
                if (!empty($alergi) && is_array($alergi)) {
                    foreach ($alergi as $bahan) {
                        $query->where('Ingredients_Cleaned', 'not like', "%{$bahan}%");
                    }
                }

                $rekomendasiResep = $query->get(['_id', 'Title Cleaned', 'Category', 'Loves', 'Ingredients Cleaned', 'Steps'])
                    ->shuffle()
                    ->take(11)
                    ->values();

                // FIX MONGODB TTL: Menggunakan create() agar format Date tersimpan sebagai BSON Date 
                if ($rekomendasiResep->isNotEmpty()) {
                    foreach ($rekomendasiResep as $resep) {
                        RiwayatRekomendasi::create([
                            'user_id'  => $idPengguna,
                            'resep_id' => (string) $resep['_id']
                        ]);
                    }
                }
            }

            return response()->json([
                'success' => true,
                'data'    => [
                    'pengguna' => [
                        'nama'             => $pengguna->Username ?? 'Pengguna',
                        'inisial'          => strtoupper(substr($pengguna->Username ?? 'P', 0, 1)),
                        'jumlah_makan'     => $pengguna->Jumlah_Makan ?? 2,
                    ],
                    'budget' => [
                        'is_budget_due'      => $isBudgetDue,
                        'hari_ke'            => $hariKe, 
                        'sisa_bulan'         => (int) $sisaBulan,
                        'budget_per_hari'    => (int) $budgetPerHari, 
                        'aktivitas_terakhir' => $aktivitasTerakhir,
                        'total_budget'       => (int) $totalPemasukan,
                        'total_keluar'       => (int) $totalKeluar,
                        'persen_sisa'        => $persenSisa,
                        'status'             => $statusBudget,
                        'pesan_peringatan'   => $pesanPeringatan,
                    ],
                    'rekomendasi_resep' => $rekomendasiResep,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function simpanBudget(Request $request): JsonResponse
    {
        try {
            $request->validate(['total_budget' => ['required', 'numeric', 'min:0']]);
            $pengguna = $request->user();
            $pengguna->Budget_Bulanan = $request->total_budget;
            $pengguna->Tanggal_Mulai_Siklus = Carbon::now()->toDateString(); 
            $pengguna->save();

            return response()->json(['success' => true, 'message' => 'Siklus baru dimulai!'], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}