<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('keuangan', function (Blueprint $table) {
            $table->id('Id_Keuangan');
            $table->foreignId('Id_User');
            $table->foreignId('Id_JadwalMakan')->nullable();
            $table->date('Tanggal');
            $table->time('Waktu');
            $table->enum('Jenis_Pengeluaran', ['Beli', 'Masak']);
            
            // Kolom ini yang akan menampung banyak barang sekaligus!
            $table->json('Detail_Beli')->nullable(); 
            
            $table->decimal('Total_Pengeluaran', 15, 2);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('keuangan');
    }
};