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
        Schema::create('stok', function (Blueprint $table) {
            $table->id('Id_Stok');
            $table->foreignId('Id_User')->constrained('users', 'Id_User')->onDelete('cascade');
            $table->string('Nama_Bahan');
            $table->string('Kategori_Bahan');
            $table->double('Jumlah_Bahan');
            $table->string('Satuan_Bahan');
            $table->date('Tanggal_Beli');
            $table->date('Tanggal_Kadaluarsa');
            $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('stok');
    }
};
