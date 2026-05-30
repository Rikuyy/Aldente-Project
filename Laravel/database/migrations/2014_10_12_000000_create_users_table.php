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
        Schema::create('users', function (Blueprint $table) {
            // Menggunakan string primary untuk menampung ObjectId MongoDB secara aman
            $table->string('Id_User')->primary(); 
            $table->string('Username');
            $table->string('Email')->unique();
            $table->string('Password');
            $table->string('Kategori_Favorit')->nullable();
            $table->integer('Jumlah_Makan')->nullable();
            $table->decimal('Budget_Bulanan', 15, 2)->nullable();
            $table->decimal('Saldo_Budget', 15, 2)->nullable(); // <-- Kolom Baru Tambahan Kamu
            $table->text('Alergi')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};