<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Keuangan;
use App\Models\Resep;
use App\Models\RiwayatRekomendasi; 
use App\Models\JadwalHarian; 
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        try {
            $pengguna = $request->user();
            // Amankan pembacaan ID untuk MongoDB
            $idPengguna = $pengguna->id ?? $pengguna->_id; 
            $sekarang   = Carbon::now('Asia/Jakarta');

            // 1. SIKLUS BUDGET & PERHITUNGAN HARI DINAMIS
            $tanggalMulaiStr = $pengguna->Tanggal_Mulai_Siklus ?? $pengguna->created_at;
            $tanggalMulai    = Carbon::parse($tanggalMulaiStr)->startOfDay();
            
            // Mencegah overflow (misal 31 Januari otomatis jadi 28/29 Februari, tidak meluber ke Maret)
            $targetBulanDepan = $tanggalMulai->copy()->addMonthNoOverflow()->startOfDay();

            // Pengecekan Pintar Top Up Manual (Auto Geser Siklus)
            $topUpBaru = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pemasukan')
                ->where('Keterangan', 'Top Up')
                ->whereDate('Tanggal', '>=', $targetBulanDepan->toDateString())
                ->orderBy('Tanggal', 'asc')
                ->first();

            if ($topUpBaru) {
                $pengguna->Tanggal_Mulai_Siklus = Carbon::parse($topUpBaru->Tanggal)->toDateString();
                $pengguna->save();

                $tanggalMulai = Carbon::parse($pengguna->Tanggal_Mulai_Siklus)->startOfDay();
                $targetBulanDepan = $tanggalMulai->copy()->addMonthNoOverflow()->startOfDay();
            }
            
            $akhirSiklus = $targetBulanDepan->copy()->subDay()->endOfDay();
            $isBudgetDue = $sekarang->greaterThanOrEqualTo($targetBulanDepan);
            
            $totalHariSiklus = max($tanggalMulai->diffInDays($targetBulanDepan), 1);
            $hariKe = max($tanggalMulai->diffInDays($sekarang->copy()->startOfDay()) + 1, 1);

            // =========================================================================
            // REVISI LOGIKA 1: SALDO KUMULATIF (SEPANJANG MASA, TIDAK DI-RESET)
            // =========================================================================
            $totalPemasukanAllTime = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pemasukan')
                ->sum('Total_Nominal');

            // Cek apakah user sudah mencatat pemasukan di hari pertama daftar
            $adaPemasukanAwal = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pemasukan')
                ->whereDate('Tanggal', Carbon::parse($pengguna->created_at)->toDateString())
                ->exists();

            // Jika tidak ada riwayat top-up awal, jadikan Budget_Bulanan sebagai "Modal Virtual Awal"
            if (!$adaPemasukanAwal) {
                $totalPemasukanAllTime += ($pengguna->Budget_Bulanan ?? 0);
            }

            $totalPengeluaranAllTime = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pengeluaran')
                ->sum('Total_Nominal');

            // Saldo tidak akan hangus dari bulan lalu!
            $saldoKumulatif = max($totalPemasukanAllTime - $totalPengeluaranAllTime, 0);

            // =========================================================================
            // REVISI LOGIKA 2: IKHTISAR SIKLUS INI (HANYA UNTUK INFO UI BULANAN)
            // =========================================================================
            $totalPemasukanSiklus = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pemasukan')
                ->whereBetween('Tanggal', [$tanggalMulai->toDateString(), $akhirSiklus->toDateString()])
                ->sum('Total_Nominal');

            // Fallback UI: Jika siklus pertama belum ada mutasi Top Up
            if ($totalPemasukanSiklus == 0 && $tanggalMulai->toDateString() == Carbon::parse($pengguna->created_at)->startOfDay()->toDateString()) {
                $totalPemasukanSiklus = $pengguna->Budget_Bulanan ?? 0;
            }

            $totalKeluarSiklus = Keuangan::where('Id_User', (string) $idPengguna)
                ->where('Kategori', 'Pengeluaran')
                ->whereBetween('Tanggal', [$tanggalMulai->toDateString(), $akhirSiklus->toDateString()])
                ->sum('Total_Nominal');

            // =========================================================================
            // REVISI LOGIKA 3: BUDGET PER HARI MENGGUNAKAN UANG YANG BENAR-BENAR NYISA
            // =========================================================================
            $sisaHariAktif = max($totalHariSiklus - $hariKe + 1, 1);
            $budgetPerHari = round($saldoKumulatif / $sisaHariAktif);

            // 3. AMBIL AKTIVITAS TERAKHIR
            $transaksiTerakhir = Keuangan::where('Id_User', (string) $idPengguna)->orderBy('created_at', 'desc')->first();
            $aktivitasTerakhir = null;
            if ($transaksiTerakhir) {
                $simbol = $transaksiTerakhir->Kategori == 'Pemasukan' ? '+' : '-';
                $aktivitasTerakhir = [
                    'nominal' => $simbol . ' Rp ' . number_format($transaksiTerakhir->Total_Nominal, 0, ',', '.'),
                    'keterangan' => $transaksiTerakhir->Keterangan,
                    'kategori' => $transaksiTerakhir->Kategori
                ];
            }

            // 4. MENGAMBIL JADWAL MENU HARI INI
            // FIX MONGODB BUG: Menggunakan (string) $idPengguna agar cocok dengan tipe di Database
            $jadwalData = JadwalHarian::where('Id_User', (string) $idPengguna)
                ->where('Tanggal', $sekarang->toDateString())
                ->get();

            $jadwalHariIni = new \stdClass(); 
            foreach ($jadwalData as $jadwal) {
                $sesiKe = (string) $jadwal->sesi_ke;
                $idResep = $jadwal->Id_Resep;
                $resep = Resep::find($idResep);
                if ($resep) {
                    $jadwalHariIni->$sesiKe = $resep->{'Title Cleaned'} ?? 'Resep';
                }
            }

            // 5. LOGIKA REKOMENDASI (KUNCI RESEP 1 HARI)
            $forceRefresh = $request->query('force_refresh') === '1';
            $awalHari = $sekarang->copy()->startOfDay();
            $akhirHari = $sekarang->copy()->endOfDay();

            if ($forceRefresh) {
                RiwayatRekomendasi::where('user_id', (string) $idPengguna)
                    ->whereBetween('created_at', [$awalHari, $akhirHari])
                    ->delete();
            }

            $historiHariIni = RiwayatRekomendasi::where('user_id', (string) $idPengguna)
                                ->whereBetween('created_at', [$awalHari, $akhirHari])
                                ->pluck('resep_id')
                                ->toArray();

            if (count($historiHariIni) >= 11 && !$forceRefresh) {
                $rekomendasiResep = Resep::whereIn('_id', $historiHariIni)
                    ->get(['_id', 'Title Cleaned', 'Category', 'Loves', 'Ingredients Cleaned', 'Steps'])
                    ->values();
            } else {
                $alergi = $pengguna->Alergi;
                $recentIds = RiwayatRekomendasi::where('user_id', (string) $idPengguna)->pluck('resep_id')->toArray();
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

                if ($rekomendasiResep->isNotEmpty()) {
                    foreach ($rekomendasiResep as $resep) {
                        RiwayatRekomendasi::create([
                            'user_id'    => (string) $idPengguna,
                            'resep_id'   => (string) $resep['_id']
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
                        'sisa_bulan'         => (int) $saldoKumulatif, // UPDATE: Pakai saldo kumulatif anti reset
                        'budget_per_hari'    => (int) $budgetPerHari, 
                        'aktivitas_terakhir' => $aktivitasTerakhir,
                        'total_budget'       => (int) $totalPemasukanSiklus,
                        'total_keluar'       => (int) $totalKeluarSiklus,
                        'pesan_peringatan'   => null, // UPDATE: Warning Overbudget Dihapus
                    ],
                    'jadwal_hari_ini'   => $jadwalHariIni, 
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
            $pengguna->Tanggal_Mulai_Siklus = Carbon::now('Asia/Jakarta')->toDateString(); 
            $pengguna->save();

            return response()->json(['success' => true, 'message' => 'Siklus baru dimulai!'], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}