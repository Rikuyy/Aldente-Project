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
        Schema::create('Keuangan', function (Blueprint $table) {
            $table->id('Id_Keuangan');
            $table->foreignId('Id_User')->constrained('users', 'Id_User')->onDelete('cascade');
            $table->foreignId('Id_JadwalMakan')->nullable()->constrained('meal_schedules', 'Id_JadwalMakan')->onDelete('set null');
            $table->date('Tanggal');
            $table->time('Waktu');
            $table->enum('Jenis_Pengeluaran', ['Beli', 'Masak']);
            $table->string('Nama Pengeluaran')->nullable();
            $table->decimal('Nominal', 15, 2);
            $table->decimal('Total Pengeluaran', 15, 2);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('Keuangan');
    }
};