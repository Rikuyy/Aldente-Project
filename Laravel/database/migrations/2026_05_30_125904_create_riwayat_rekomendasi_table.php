<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::connection('mongodb')->create('riwayat_rekomendasi', function (Blueprint $collection) {
            // Index utama
            $collection->index('user_id');
            $collection->index('resep_id');
            
            // TTL Index: Data akan hangus otomatis setelah 7 Hari (604800 detik)
            $collection->index('created_at')->expireAfterSeconds(604800);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::connection('mongodb')->dropIfExists('riwayat_rekomendasi');
    }
};