<?php

namespace App\Services;

use App\Models\Resep;
use App\Models\User;
use App\Models\UserResep;

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
 
        $userResep = $this->getUserResep($user);
        $userResep->Id_User        = (string) $user->id;
        $userResep->resep_queue    = $reseps;
        $userResep->queue_index    = 0;
        $userResep->queue_built_at = now()->toDateString();
        $userResep->save();
    }

    public function previewBerikutnya(User $user, int $jumlah): array
    {
        $userResep = $this->getUserResep($user);
         if (empty($userResep->resep_queue)) {
            $this->buildQueue($user);
            $userResep = $this->getUserResep($user);
        }

        $queue = $userResep->resep_queue;
        $index = $userResep->queue_index ?? 0;
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
         $userResep = $this->getUserResep($user);
 
        if (empty($userResep->resep_queue)) {
            $this->buildQueue($user);
            return;
        }
 
        $total    = count($userResep->resep_queue);
        $newIndex = ($userResep->queue_index ?? 0) + 1;
 
        if ($newIndex >= $total) {
            $this->buildQueue($user);
            return;
        }
 
        $userResep->queue_index = $newIndex;
        $userResep->save();
    }

    
    public function ambilBerikutnya(User $user, int $jumlah): array
    {
        $hasil = $this->previewBerikutnya($user, $jumlah);
 
        foreach ($hasil as $ignored) {
            $this->advanceIndex($user); 
        }
 
        return $hasil;
    }
}