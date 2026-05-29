<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Ambil koleksi MongoDB dari koneksi default mongodb
        $collection = DB::connection('mongodb')->getCollection('keuangan');

        // 1. Rename field 'Jenis_Pengeluaran' menjadi 'Kategori'
        $collection->updateMany(
            ['Jenis_Pengeluaran' => ['$exists' => true]],
            ['$rename' => ['Jenis_Pengeluaran' => 'Kategori']]
        );

        // 2. Hapus field 'is_debit' jika ada (karena tidak kita gunakan lagi)
        $collection->updateMany(
            ['is_debit' => ['$exists' => true]],
            ['$unset' => ['is_debit' => ""]]
        );

        // 3. Set default 'Kategori' = 'Lainnya' untuk dokumen yang belum punya field Kategori
        $collection->updateMany(
            ['Kategori' => ['$exists' => false]],
            ['$set' => ['Kategori' => 'Lainnya']]
        );
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $collection = DB::connection('mongodb')->getCollection('keuangan');

        // Kembalikan rename (untuk rollback)
        $collection->updateMany(
            ['Kategori' => ['$exists' => true]],
            ['$rename' => ['Kategori' => 'Jenis_Pengeluaran']]
        );

        // Catatan: Field is_debit yang dihapus tidak bisa dikembalikan secara otomatis.
    }
};