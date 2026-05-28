<?php

namespace App\Services;

use App\Models\Resep;
use App\Models\User;

class ResepQueueService
{
    /**
     * Build ulang antrian resep untuk user.
     * Dipanggil saat: user ubah favorit/alergi, atau queue habis.
     *
     * Logika:
     * 1. Ambil resep dari kategori favorit user
     * 2. Filter keluar resep yang mengandung kategori alergi user
     * 3. Urutkan A-Z by 'Title Cleaned'
     * 4. Simpan array Id_Resep + reset index ke 0 di dokumen user MongoDB
     */
    public function buildQueue(User $user): void
    {
        $favorit = $user->Kategori_Favorit ?? [];   // array of string, misal ["ayam", "sapi"]
        $alergi  = $user->Alergi ?? [];   // array of string, misal ["udang"]

        // Ambil resep dari kategori favorit, lalu exclude kategori alergi
        $reseps = Resep::whereIn('Category', $favorit)
            ->whereNotIn('Category', $alergi)
            ->orderBy('Title Cleaned', 'asc')
            ->pluck('id')
            ->toArray();

        // Simpan ke dokumen user
        $user->resep_queue    = $reseps;
        $user->queue_index    = 0;
        $user->queue_built_at = now()->toDateString();
        $user->save();
    }

    /**
     * Ambil $jumlah resep berikutnya dari antrian user.
     * Otomatis rebuild jika queue kosong atau habis.
     *
     * Returns array of Id_Resep (string).
     */
    public function ambilBerikutnya(User $user, int $jumlah): array
    {
        // Rebuild jika queue belum pernah dibuat
        if (empty($user->resep_queue)) {
            $this->buildQueue($user);
        }

        $queue = $user->resep_queue;
        $index = $user->queue_index ?? 0;
        $total = count($queue);

        // Jika queue lebih sedikit dari jumlah sesi, kembalikan semua yang ada
        if ($total === 0) {
            return [];
        }

        $hasil    = [];
        $newIndex = $index;

        for ($i = 0; $i < $jumlah; $i++) {
            // Jika index sudah sampai akhir → rebuild lalu lanjut dari 0
            if ($newIndex >= $total) {
                $this->buildQueue($user);
                $user->refresh();
                $queue    = $user->resep_queue;
                $total    = count($queue);
                $newIndex = 0;

                if ($total === 0) break;
            }

            $resepId = $queue[$newIndex];
            $newIndex++;

            // Hindari resep duplikat dalam satu generate (satu hari)
            if (in_array($resepId, $hasil)) {
                continue;
            }

            $hasil[] = $resepId;
        }

        // Simpan posisi index terbaru
        $user->queue_index = $newIndex;
        $user->save();

        return $hasil;
    }
}