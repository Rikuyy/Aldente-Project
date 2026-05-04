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
        Schema::create('inventories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // relasi ke tabel users
            $table->string('nama_bahan');                    // nama bahan (misal: Telur Ayam)
            $table->string('kategori');                      // kategori (Protein, Sayur & Buah, Karbohidrat, Bumbu)
            $table->decimal('jumlah', 10, 2);               // jumlah stok
            $table->string('satuan');                        // satuan (kg, butir, pcs, liter, dll)
            $table->decimal('harga_satuan', 15, 2)->default(0); // harga per satuan
            $table->enum('status', ['tersedia', 'hampir_habis', 'habis'])->default('tersedia'); // status stok
            $table->date('tanggal_beli')->nullable();        // tanggal beli
            $table->date('tanggal_kadaluarsa')->nullable(); // tanggal kadaluarsa
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('inventories');
    }
};