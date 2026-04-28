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
        Schema::create('budgets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // relasi ke tabel users
            $table->decimal('total_budget_harian', 15, 2);  // total budget per hari (misal: 50000)
            $table->decimal('sisa_budget', 15, 2);          // sisa budget hari ini
            $table->decimal('terpakai', 15, 2)->default(0); // total yang sudah terpakai hari ini
            $table->date('tanggal');                         // tanggal pengeluaran
            $table->enum('status', ['aman', 'hemat', 'bahaya'])->default('aman'); // status budget
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('budgets');
    }
};