<?php

namespace App\Services;

use App\Models\Resep;
use App\Models\User;

class ResepQueueService
{ 
    public function buildQueue(User $user): void
    {
        $favorit = $user->Kategori_Favorit ?? [];
        $alergi  = $user->Alergi ?? [];
 
        $reseps = Resep::whereIn('Category', $favorit)
            ->whereNotIn('Category', $alergi)
            ->orderBy('Title Cleaned', 'asc')
            ->pluck('id')
            ->toArray();
 
        $user->resep_queue    = $reseps;
        $user->queue_index    = 0;
        $user->queue_built_at = now()->toDateString();
        $user->save();
    }

    public function previewBerikutnya(User $user, int $jumlah): array
    {
        // Rebuild jika queue belum pernah dibuat
        if (empty($user->resep_queue)) {
            $this->buildQueue($user);
        }

        $queue = $user->resep_queue;
        $index = $user->queue_index ?? 0;
        $total = count($queue);
 
        if ($total === 0) {
            return [];
        }

        $hasil    = [];
        $tempIndex = $index;

        for ($i = 0; $i < $jumlah; $i++) {
            if ($tempIndex >= $total) {
                $tempIndex = 0;
            }

            $resepId = $queue[$tempIndex];
            $tempIndex++;
 
            if (in_array($resepId, $hasil)) {
                $i--; 
                if ($tempIndex >= $total) break;
                continue;
            }

            $hasil[] = $resepId;
        }
        return $hasil;
    }

    public function advanceIndex(User $user): void
    {
        if (empty($user->resep_queue)) {
            $this->buildQueue($user);
            return;
        }

        $queue    = $user->resep_queue;
        $total    = count($queue);
        $newIndex = ($user->queue_index ?? 0) + 1;

        if ($newIndex >= $total) {
            $this->buildQueue($user);
            return;
        }

        $user->queue_index = $newIndex;
        $user->save();
    }

    /**
     * @deprecated Gunakan previewBerikutnya() + advanceIndex() sebagai gantinya.
     */
    public function ambilBerikutnya(User $user, int $jumlah): array
    {
        $hasil = $this->previewBerikutnya($user, $jumlah);

        foreach ($hasil as $ignored) {
            $this->advanceIndex($user);
            $user->refresh();
        }

        return $hasil;
    }
}