<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jadwal_makan', function (Blueprint $table) {
            $table->id('Id_JadwalMakan');
            $table->foreignId('Id_User');
            $table->foreignId('Id_Resep');
            $table->date('Tanggal');
            $table->string('Sesi Makan');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jadwal_makan');
    }
};