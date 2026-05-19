<?php

namespace App\Http\Controllers;

use App\Models\Resep; // Pastikan kamu punya Model Resep
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ResepController extends Controller
{
    // 1. Ambil Semua Data Resep
    public function index()
    {
        $resep = Resep::all();
        return response()->json($resep);
    }

    // 2. Tambah Resep Baru
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'Title Cleaned' => 'required',
            'Ingredients Cleaned' => 'required',
            'Steps' => 'required',
            'Category' => 'required'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 400);
        }

        $resep = Resep::create($request->all());

        return response()->json([
            'status' => 'success',
            'message' => 'Resep berhasil ditambahkan!',
            'data' => $resep
        ], 201);
    }

    // 3. Update Resep
public function update(Request $request, $id)
{
    // Pakai where('_id', $id) buat mastiin MongoDB nangkep
    $resep = \App\Models\Resep::where('_id', $id)->first();

    if (!$resep) {
        return response()->json(['message' => 'ID: ' . $id . ' tidak ditemukan di database'], 404);
    }

    $resep->update($request->all());

        return response()->json([
            'status' => 'success',
            'message' => 'Resep berhasil diperbarui!',
            'data' => $resep
        ]);
    }

    // 4. Hapus Resep
    public function destroy($id)
    {
        // Pakai cara pencarian yang sama kayak update tadi biar aman
        $resep = \App\Models\Resep::where('_id', $id)->first();

        if (!$resep) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menghapus. ID: ' . $id . ' tidak ditemukan di database'
            ], 404);
        }

        $resep->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Resep berhasil dihapus !'
        ]);
    }
}