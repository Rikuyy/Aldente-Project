<?php

namespace App\Http\Controllers;

use App\Models\Resep; 
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ResepController extends Controller
{
    // 1. Ambil Semua Data Resep dari MongoDB
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

        // Hitung total komponen data secara otomatis
        $totalIngredients = count(explode(',', $request->input('Ingredients Cleaned')));
        $totalSteps = count(explode('.', $request->input('Steps')));

        // Buat objek array terstruktur sesuai kolom MongoDB
        $resep = Resep::create([
            'Title Cleaned' => $request->input('Title Cleaned'),
            'Ingredients Cleaned' => $request->input('Ingredients Cleaned'),
            'Steps' => $request->input('Steps'),
            'Category' => $request->input('Category'),
            'Loves' => (int) $request->input('Loves', 0),
            'Total Ingredients' => $totalIngredients,
            'Total Steps' => $totalSteps
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Resep berhasil ditambahkan!',
            'data' => $resep
        ], 201);
    }

    // 3. Update Resep Berdasarkan ID MongoDB
    public function update(Request $request, $id)
    {
        $resep = Resep::where('_id', $id)->first();

        if (!$resep) {
            return response()->json(['message' => 'ID: ' . $id . ' tidak ditemukan di database'], 404);
        }

        $validator = Validator::make($request->all(), [
            'Title Cleaned' => 'required',
            'Ingredients Cleaned' => 'required',
            'Steps' => 'required',
            'Category' => 'required'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 400);
        }

        $totalIngredients = count(explode(',', $request->input('Ingredients Cleaned')));
        $totalSteps = count(explode('.', $request->input('Steps')));

        $resep->update([
            'Title Cleaned' => $request->input('Title Cleaned'),
            'Ingredients Cleaned' => $request->input('Ingredients Cleaned'),
            'Steps' => $request->input('Steps'),
            'Category' => $request->input('Category'),
            'Loves' => (int) $request->input('Loves', 0),
            'Total Ingredients' => $totalIngredients,
            'Total Steps' => $totalSteps
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Resep berhasil diperbarui!',
            'data' => $resep
        ]);
    }

    // 4. Hapus Resep dari MongoDB
    public function destroy($id)
    {
        $resep = Resep::where('_id', $id)->first();

        if (!$resep) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menghapus. ID: ' . $id . ' tidak ditemukan di database'
            ], 404);
        }

        $resep->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Resep berhasil dihapus!'
        ]);
    }
}