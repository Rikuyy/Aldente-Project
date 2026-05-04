<?php

namespace App\Http\Controllers;

use App\Models\Resep; // Pastikan Model Resep sudah ada
use Illuminate\Http\Request;
use Carbon\Carbon; // Untuk format waktu

class DashboardController extends Controller
{
    public function index()
    {
        // 1. Total Resep
        $totalResep = Resep::count();

        // 2. Resep Paling Disukai (Loves tertinggi)
        $resepPopuler = Resep::orderBy('Loves', 'desc')->first();
        $namaResepPopuler = $resepPopuler ? $resepPopuler['Title Cleaned'] : 'Belum Ada';

        // 3. Rata-rata Bahan (Kompleksitas)
        // Ambil rata-rata dari kolom 'Total Ingredients', bulatkan angkanya
        $rataBahanRaw = Resep::avg('Total Ingredients');
        $rataBahan = $rataBahanRaw ? round($rataBahanRaw) : 0;

        // 4. Jejak Update AI (Data resep terakhir diubah)
        $resepTerakhir = Resep::orderBy('updated_at', 'desc')->first();
        if ($resepTerakhir && isset($resepTerakhir->updated_at)) {
            // Ubah format jadi misal: "03 Mei 2026, 14:30"
            $waktuUpdate = Carbon::parse($resepTerakhir->updated_at)->timezone('Asia/Jakarta')->translatedFormat('d M Y, H:i');
        } else {
            $waktuUpdate = 'Belum ada data';
        }

        // 5. Tabel Aktivitas (Ambil 5 resep paling baru)
        $resepTerbaru = Resep::orderBy('updated_at', 'desc')->take(5)->get();

        // Lempar semua variabel di atas ke file view dashboard.blade.php
        return view('dashboard', compact(
            'totalResep', 
            'namaResepPopuler', 
            'rataBahan', 
            'waktuUpdate', 
            'resepTerbaru'
        ));
    }
}