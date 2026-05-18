<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Stok;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class StockController extends Controller
{
    public function index() {
        $stok = Stok::where('Id_User', Auth::id())->get();
        $grouped = $stok->groupBy('Kategori_Bahan')->map(function ($items, $kategori) {
            return [
                'kategori' => $kategori,
                'items' => $items->values()
            ];
        })->values();
        return response()->json(['status' => 'success', 'data' => $grouped]);
    }

    public function store(Request $request) {
        $data = $request->all();
        $data['Id_User'] = Auth::id();
        $stok = Stok::create($data);
        return response()->json(['status' => 'success', 'data' => $stok], 201);
    }

    public function update(Request $request, $id) {
        $stok = Stok::where('_id', $id)->where('Id_User', Auth::id())->firstOrFail();
        $stok->update($request->all());
        return response()->json(['status' => 'success', 'data' => $stok]);
    }

    public function deleteStock($id) {
        Stok::where('_id', $id)->where('Id_User', Auth::id())->delete();
        return response()->json(['status' => 'success', 'message' => 'Data stok berhasil dihapus']);
    }

    public function search(Request $request) {
        $query = $request->query('q');
        $results = Stok::where('Id_User', Auth::id())
                       ->where('Nama_Bahan', 'LIKE', "%{$query}%")
                       ->get();
        return response()->json(['status' => 'success', 'data' => $results]);
    }

    public function masakSelesai(Request $request) {
        // Logika sederhana: mengurangi stok berdasarkan bahan yang digunakan
        // Request berisi array [['id' => '...', 'jumlah' => 2], ...]
        foreach ($request->bahan as $item) {
            $stok = Stok::where('_id', $item['id'])->where('Id_User', Auth::id())->first();
            if ($stok) {
                $stok->decrement('Jumlah_Bahan', $item['jumlah']);
            }
        }
        return response()->json(['status' => 'success', 'message' => 'Stok diperbarui setelah memasak']);
    }
}