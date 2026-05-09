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
        Schema::create('resep', function (Blueprint $table) {
            $table->id('Id_Resep');
            $table->string('Title Cleaned');
            $table->text('Ingredients Cleaned');
            $table->text('Steps');
            $table->integer('Loves')->default(0);
            $table->string('Category');
            $table->integer('Total Ingredients');
            $table->integer('Total Steps');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('inventories');
    }
};