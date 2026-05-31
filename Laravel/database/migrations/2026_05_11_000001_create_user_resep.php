<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    protected $connection = 'mongodb';

    public function up(): void
    {
        Schema::connection('mongodb')->create('user_resep', function (Blueprint $collection) {
            $collection->id();
            $collection->string('Id_User');
            $collection->array('resep_queue')->default([]);
            $collection->integer('queue_index')->default(0);
            $collection->string('queue_built_at')->nullable();
            $collection->timestamps();

            $collection->unique('Id_User');
        });
    }

    public function down(): void
    {
        Schema::connection('mongodb')->dropIfExists('user_resep');
    }
};