<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JadwalHarian;
use App\Models\JadwalMakan;
use App\Models\Keuangan;
use App\Models\Resep;
use App\Services\ResepQueueService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TodoCookController extends Controller
{
    public function __construct(private ResepQueueService $queueService) {}

    // =========================================================================
    // GENERATE — ambil jadwal hari ini
    // =========================================================================
    public function generate(Request $request)
    {
        $user    = Auth::user();
        $tanggal = $request->input('tanggal', now()->toDateString());

        // 1. Cek apakah jadwal_harian sudah ada untuk hari ini
        //    (mencakup kondisi: belum dicentang, sudah ganti resep, dll)
        $harianAda = JadwalHarian::where('Id_User', $user->id)
            ->where('Tanggal', $tanggal)
            ->exists();

        if ($harianAda) {
            $harianList = JadwalHarian::where('Id_User', $user->id)
                ->where('Tanggal', $tanggal)
                ->orderBy('sesi_ke', 'asc')
                ->with('resep')
                ->get();

            // Cek sesi mana yang sudah dicentang (ada di jadwal_makan)
            $sudahDone = JadwalMakan::where('Id_User', $user->id)
                ->where('Tanggal', $tanggal)
                ->pluck('Sesi Makan')
                ->toArray();

            return response()->json([
                'status' => 'existing',
                'data'   => $harianList->map(fn($h) => [
                    'id_jadwal_harian' => (string) $h->_id,
                    'sesi'             => $h->{'Sesi Makan'},
                    'sesi_ke'          => $h->sesi_ke,
                    'resep'            => $this->formatResep($h->resep),
                    'is_done'          => in_array($h->{'Sesi Makan'}, $sudahDone),
                ]),
            ]);
        }

        // 2. Cek jadwal_makan — kalau semua sesi sudah dicentang hari ini
        //    (edge case: jadwal_harian terhapus tapi jadwal_makan masih ada)
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
                    'id_jadwal_harian' => null,
                    'sesi'             => $j->{'Sesi Makan'},
                    'sesi_ke'          => $this->sesiKeAngka($j->{'Sesi Makan'}),
                    'resep'            => $this->formatResep($j->resep),
                    'is_done'          => true,
                ]),
            ]);
        }

        // 3. Belum ada sama sekali — generate baru dari queue
        $jumlahSesi = $user->Jumlah_Makan ?? 3;
        $resepIds   = $this->queueService->previewBerikutnya($user, $jumlahSesi);

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
            $resep = $reseps[(string) $resepId] ?? null;
            if (!$resep) continue;

            $sesiLabel = $sesiLabels[$i] ?? 'Sesi ' . ($i + 1);
            $sesiKe    = $i + 1;

            // Simpan ke jadwal_harian agar persisten
            JadwalHarian::create([
                'Id_User'    => (string) $user->id,
                'Tanggal'    => $tanggal,
                'sesi_ke'    => $sesiKe,
                'Sesi Makan' => $sesiLabel,
                'Id_Resep'   => (string) $resepId,
            ]);

            $data[] = [
                'id_jadwal_harian' => null, // baru saja dibuat, tidak kritis untuk frontend
                'sesi'             => $sesiLabel,
                'sesi_ke'          => $sesiKe,
                'resep'            => $this->formatResep($resep),
                'is_done'          => false,
            ];
        }

        return response()->json([
            'status'  => 'preview',
            'tanggal' => $tanggal,
            'data'    => $data,
        ]);
    }

    // =========================================================================
    // GANTI RESEP — update Id_Resep di jadwal_harian
    // =========================================================================
    public function gantiResep(Request $request)
    {
        $request->validate([
            'sesi_ke'  => 'required|integer|min:1',
            'resep_id' => 'required|string',
            'tanggal'  => 'nullable|date',
        ]);

        $user    = Auth::user();
        $tanggal = $request->input('tanggal', now()->toDateString());
        $sesiKe  = $request->input('sesi_ke');
        $resepId = $request->input('resep_id');

        // Pastikan resep valid
        $resep = Resep::find($resepId);
        if (!$resep) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Resep tidak ditemukan.',
            ], 404);
        }

        // Pastikan sesi belum dicentang
        $sudahDone = JadwalMakan::where('Id_User', $user->id)
            ->where('Tanggal', $tanggal)
            ->where('Sesi Makan', $this->sesiKeLabel($sesiKe))
            ->exists();

        if ($sudahDone) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Sesi ini sudah dicentang, tidak bisa diganti.',
            ], 409);
        }

        // Update jadwal_harian
        $updated = JadwalHarian::where('Id_User', $user->id)
            ->where('Tanggal', $tanggal)
            ->where('sesi_ke', $sesiKe)
            ->first();

        if (!$updated) {
            // Jadwal harian belum ada (edge case) — buat baru
            JadwalHarian::create([
                'Id_User'    => (string) $user->id,
                'Tanggal'    => $tanggal,
                'sesi_ke'    => $sesiKe,
                'Sesi Makan' => $this->sesiKeLabel($sesiKe),
                'Id_Resep'   => $resepId,
            ]);
        } else {
            $updated->Id_Resep = $resepId;
            $updated->save();
        }

        return response()->json([
            'status' => 'success',
            'data'   => [
                'sesi_ke'  => $sesiKe,
                'resep'    => $this->formatResep($resep),
            ],
        ]);
    }

    // =========================================================================
    // STORE — simpan saat user centang (selesai makan)
    // =========================================================================
    public function store(Request $request)
    {
        $request->validate([
            'Id_Resep'         => 'required',
            'Sesi Makan'       => 'required|string',
            'Tanggal'          => 'required|date',
            'Keterangan'       => 'required|in:Beli,Masak',
            'Kategori'         => 'required|in:Pemasukan,Pengeluaran',
            'Detail'           => 'required|array|min:1',
            'Detail.*.nama'    => 'required|string',
            'Detail.*.nominal' => 'required|numeric|min:0',
            'Total_Nominal'    => 'required_if:Keterangan,Masak|numeric|min:0',
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

        // Ambil resep_id dari jadwal_harian (sumber kebenaran)
        // agar resep yang dipakai adalah yang sudah diganti, bukan dari frontend
        $sesiKe  = $this->sesiKeAngka($request->input('Sesi Makan'));
        $harian  = JadwalHarian::where('Id_User', (string) $user->id)
            ->where('Tanggal', $request->input('Tanggal'))
            ->where('sesi_ke', $sesiKe)
            ->first();

        // Prioritaskan Id_Resep dari jadwal_harian; fallback ke request
        $resepId = $harian ? (string) $harian->Id_Resep : $request->input('Id_Resep');

        // 1. Simpan ke jadwal_makan
        $jadwal = new JadwalMakan([
            'Id_User'    => (string) $user->id,
            'Id_Resep'   => $resepId,
            'Tanggal'    => $request->input('Tanggal'),
            'Sesi Makan' => $request->input('Sesi Makan'),
        ]);
        $jadwal->save();

        $jadwalId = (string) $jadwal->_id;

        // 2. Hitung total pengeluaran
        $detail = $request->input('Detail');
        $jenis  = $request->input('Keterangan');

        if ($jenis === 'Beli') {
            $total = collect($detail)->sum(fn($item) => (float) $item['nominal']);
        } else {
            $total = (float) $request->input('Total_Nominal', 0);
        }

        // 3. Simpan ke keuangan
        Keuangan::create([
            'Id_User'        => (string) $user->id,
            'Id_JadwalMakan' => $jadwalId,
            'Tanggal'        => $request->input('Tanggal'),
            'Waktu'          => now()->format('H:i'),
            'Keterangan'     => $jenis,
            'Kategori'       => $request->input('Kategori', 'Pengeluaran'),
            'Detail'         => $detail,
            'Total_Nominal'  => $total,
        ]);

        // 4. Geser queue_index maju 1
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
        return array_slice(['Sesi 1', 'Sesi 2', 'Sesi 3', 'Sesi 4'], 0, $jumlah);
    }

    private function sesiKeAngka(string $sesi): int
    {
        return ['Sesi 1' => 1, 'Sesi 2' => 2, 'Sesi 3' => 3, 'Sesi 4' => 4][$sesi] ?? 1;
    }

    private function sesiKeLabel(int $sesiKe): string
    {
        return ['Sesi 1', 'Sesi 2', 'Sesi 3', 'Sesi 4'][$sesiKe - 1] ?? 'Sesi 1';
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