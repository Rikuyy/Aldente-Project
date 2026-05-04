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
        Schema::create('expenses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // relasi ke tabel users
            $table->foreignId('budget_id')->constrained()->onDelete('cascade'); // relasi ke tabel budgets
            $table->string('nama_pengeluaran');              // nama pengeluaran (misal: Beli Telur)
            $table->decimal('jumlah', 15, 2);               // jumlah pengeluaran
            $table->enum('kategori', ['masak_sendiri', 'jajan', 'lainnya'])->default('lainnya'); // kategori pengeluaran
            $table->date('tanggal');                         // tanggal pengeluaran
            $table->text('catatan')->nullable();             // catatan tambahan
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('expenses');
    }
};