<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('riwayat_chatbot', function (Blueprint $table) {
            $table->id('Id_Riwayat');
            $table->foreignId('Id_User');
            $table->enum('Role', ['user', 'bot']); // Untuk menandai siapa yang ngomong
            $table->text('Message'); // Isi pesan chat-nya
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('riwayat_chatbot');
    }
};