<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JadwalMakan;
use App\Models\Keuangan;
use App\Models\Resep;
use App\Services\ResepQueueService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TodoCookController extends Controller
{
    public function __construct(private ResepQueueService $queueService) {}

    public function generate(Request $request)
    {
        $user    = Auth::user();
        $tanggal = $request->input('tanggal', now()->toDateString());

        // Jika jadwal hari ini sudah ada di DB (sudah dicentang sebagian/semua)
        // → kembalikan yang sudah tersimpan
        $sudahAda = JadwalMakan::where('Id_User', $user->id)
            ->where('Tanggal', $tanggal)
            ->exists();

        if ($sudahAda) {
            $jadwals = JadwalMakan::where('Id_User', $user->id)
                ->where('Tanggal', $tanggal)
                ->with('resep')
                ->get();

            return response()->json([
                'status' => 'existing',
                'data'   => $jadwals->map(fn($j) => [
                    'id_jadwal' => $j->Id_JadwalMakan,
                    'sesi'      => $j->{'Sesi Makan'},
                    'sesi_ke'   => $this->sesiKeAngka($j->{'Sesi Makan'}),
                    'resep'     => $this->formatResep($j->resep),
                    'is_done'   => true,
                ]),
            ]);
        }

        $jumlahSesi = $user->Jumlah_Makan ?? 3;

        // Gunakan previewBerikutnya() — index TIDAK digeser di sini.
        // Index baru maju saat user benar-benar store (centang).
        $resepIds = $this->queueService->previewBerikutnya($user, $jumlahSesi);

        if (empty($resepIds)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Tidak ada resep yang sesuai. Cek favorit dan alergi kamu.',
            ], 422);
        }

        $reseps     = Resep::whereIn('id', $resepIds)->get()->keyBy(fn($r) => (string) $r->id);
        $sesiLabels = $this->getSesiLabels($jumlahSesi);
        $data       = [];

        foreach ($resepIds as $i => $resepId) {
            $resep = $reseps[$resepId] ?? null;
            if (!$resep) continue;

            $data[] = [
                'id_jadwal' => null,
                'sesi'      => $sesiLabels[$i] ?? 'Sesi ' . ($i + 1),
                'sesi_ke'   => $i + 1,
                'resep'     => $this->formatResep($resep),
                'is_done'   => false,
            ];
        }

        return response()->json([
            'status'  => 'preview',
            'tanggal' => $tanggal,
            'data'    => $data,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Id_Resep'              => 'required',
            'Sesi Makan'            => 'required|string',
            'Tanggal'               => 'required|date',
            'Jenis_Pengeluaran'     => 'required|in:Beli,Masak',
            'Detail_Beli'           => 'required|array|min:1',
            'Detail_Beli.*.nama'    => 'required|string',
            'Detail_Beli.*.nominal' => 'required|numeric|min:0',
            'Total_Pengeluaran'     => 'required_if:Jenis_Pengeluaran,Masak|numeric|min:0',
        ]);

        $user = Auth::user();

        // Cegah duplikat sesi di hari yang sama
        $existing = JadwalMakan::where('Id_User', (string) $user->id)
            ->where('Tanggal', $request->input('Tanggal'))
            ->where('Sesi Makan', $request->input('Sesi Makan'))
            ->first();

        if ($existing) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Sesi ini sudah tercatat.',
            ], 409);
        }

        // 1. Simpan ke jadwal_makan
        $jadwal = new JadwalMakan([
            'Id_User'    => (string) $user->id,
            'Id_Resep'   => $request->input('Id_Resep'),
            'Tanggal'    => $request->input('Tanggal'),
            'Sesi Makan' => $request->input('Sesi Makan'),
        ]);
        $jadwal->save();

        $jadwalId = (string) $jadwal->_id;

        // 2. Hitung total pengeluaran
        $detailBeli = $request->input('Detail_Beli');
        $jenis      = $request->input('Jenis_Pengeluaran');

        if ($jenis === 'Beli') {
            $total = collect($detailBeli)->sum(fn($item) => (float) $item['nominal']);
        } else {
            $total = (float) $request->input('Total_Pengeluaran', 0);
        }

        // 3. Simpan ke keuangan
        Keuangan::create([
            'Id_User'           => (string) $user->id,
            'Id_JadwalMakan'    => $jadwalId,
            'Tanggal'           => $request->input('Tanggal'),
            'Waktu'             => now()->format('H:i'),
            'Jenis_Pengeluaran' => $jenis,
            'Detail_Beli'       => $detailBeli,
            'Total Pengeluaran' => $total,
        ]);

        // 4. Geser queue_index maju 1 — dilakukan SETELAH store berhasil.
        //    Ini memastikan index hanya maju kalau user benar-benar sudah makan,
        //    bukan hanya karena halaman di-refresh/relog.
        $user->refresh();
        $this->queueService->advanceIndex($user);

        return response()->json([
            'status' => 'success',
            'data'   => $jadwal,
        ], 201);
    }

    public function rebuildQueue()
    {
        $user = Auth::user();
        $this->queueService->buildQueue($user);

        return response()->json([
            'status'  => 'success',
            'message' => 'Antrian resep diperbarui.',
        ]);
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private function getSesiLabels(int $jumlah): array
    {
        $semua = ['Sesi 1', 'Sesi 2', 'Sesi 3', 'Sesi 4'];
        return array_slice($semua, 0, $jumlah);
    }

    private function sesiKeAngka(string $sesi): int
    {
        $map = ['Sesi 1' => 1, 'Sesi 2' => 2, 'Sesi 3' => 3, 'Sesi 4' => 4];
        return $map[$sesi] ?? 1;
    }

    private function formatResep($resep): array
    {
        if (!$resep) return [];
        return [
            'id'          => (string) $resep->id,
            'title'       => $resep->{'Title Cleaned'},
            'ingredients' => $resep->{'Ingredients Cleaned'},
            'steps'       => $resep->Steps,
            'category'    => $resep->Category,
        ];
    }
}