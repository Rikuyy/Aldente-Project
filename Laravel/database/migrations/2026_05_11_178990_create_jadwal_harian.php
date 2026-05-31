<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    protected $connection = 'mongodb';

    public function up(): void
    {
        Schema::connection('mongodb')->create('jadwal_harian', function (Blueprint $collection) {
            $collection->id();
            $collection->string('Id_User');
            $collection->string('Tanggal');
            $collection->integer('sesi_ke');
            $collection->string('Sesi Makan');
            $collection->string('Id_Resep');
            $collection->timestamps();

            $collection->index(['Id_User', 'Tanggal']);
            $collection->index(['Id_User', 'Tanggal', 'sesi_ke']);
        });
    }

    public function down(): void
    {
        Schema::connection('mongodb')->dropIfExists('jadwal_harian');
    }
};