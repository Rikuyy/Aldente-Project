<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Stock;

class StockController extends Controller
{
    public function deleteStock($id)
{
    $stock = \App\Models\Stock::findOrFail($id);
    $namaBahan = $stock->ingredient_name;
    
    $stock->delete();

    return response()->json([
        'status' => 'success',
        'message' => "Stok $namaBahan berhasil dihapus dari daftar."
    ]);
}//
}
