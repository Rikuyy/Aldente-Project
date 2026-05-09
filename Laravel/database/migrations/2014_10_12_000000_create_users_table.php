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
            $table->id('Id_User');
            $table->string('Username');
            $table->string('Email')->unique();
            $table->string('Password');
            $table->string('Kategori_Favorit')->nullable();
            $table->integer('Jumlah_Makan');
            $table->decimal('Budget_Bulanan', 15, 2);
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
