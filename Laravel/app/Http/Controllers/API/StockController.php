<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Stok;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class StockController extends Controller
{
    private function getUserId()
    {
        if ($user = auth('api')->user()) {
            return $user->getKey();
        }
        $firstUser = \App\Models\User::first();
        return $firstUser ? $firstUser->getKey() : 'guest_system_user';
    }

    public function index(): JsonResponse
    {
        try {
            $idPengguna = $this->getUserId();
            $stok = Stok::where('Id_User', $idPengguna)->get();

            $dikelompokkan = $stok->groupBy('Kategori_Bahan')->map(function ($items, $kategori) {
                return [
                    'kategori' => $kategori ?? 'Lainnya',
                    'bahan'    => $items->map(fn($item) => $this->formatStok($item))->values(),
                ];
            })->values();

            return response()->json([
                'success' => true,
                'message' => 'Data stok berhasil diambil.',
                'data'    => $dikelompokkan,
            ], 200);
        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    public function simpan(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'Nama_Bahan'         => 'required|string|max:255',
                'Kategori_Bahan'     => 'required|string|max:100',
                'Jumlah_Bahan'       => 'required|numeric|min:0',
                'Satuan_Bahan'       => 'required|string|max:50',
                'Tipe_Bahan'         => 'required|in:segar,kemasan',
                'Tanggal_Beli'       => 'nullable|string',
                'Tanggal_Kadaluarsa' => 'nullable|string',
            ]);

            $stok = new Stok();
            $stok->Id_User            = $this->getUserId();
            $stok->Nama_Bahan         = $validated['Nama_Bahan'];
            $stok->Kategori_Bahan     = $validated['Kategori_Bahan'];
            $stok->Jumlah_Bahan       = (double) $validated['Jumlah_Bahan'];
            $stok->Satuan_Bahan       = $validated['Satuan_Bahan'];
            $stok->Tipe_Bahan         = $validated['Tipe_Bahan'];
            $stok->Tanggal_Beli       = $request->filled('Tanggal_Beli') 
                ? date('Y-m-d', strtotime($validated['Tanggal_Beli'])) 
                : now()->toDateString();
            
            if ($request->filled('Tanggal_Kadaluarsa') && $validated['Tipe_Bahan'] === 'kemasan') {
                $stok->Tanggal_Kadaluarsa = date('Y-m-d', strtotime($validated['Tanggal_Kadaluarsa']));
            }

            $stok->save();

            return response()->json([
                'success' => true,
                'message' => 'Stok bahan berhasil ditambahkan.',
                'data'    => $this->formatStok($stok),
            ], 201);
        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    public function perbarui(Request $request, string $id): JsonResponse
    {
        try {
            $idPengguna = $this->getUserId();
            $stok = Stok::where('_id', $id)->where('Id_User', $idPengguna)->first();
            if (!$stok) {
                return response()->json(['success' => false, 'message' => 'Data tidak ditemukan.'], 404);
            }

            $validated = $request->validate([
                'Nama_Bahan'         => 'nullable|string|max:255',
                'Kategori_Bahan'     => 'nullable|string|max:100',
                'Jumlah_Bahan'       => 'nullable|numeric|min:0',
                'Satuan_Bahan'       => 'nullable|string|max:50',
                'Tipe_Bahan'         => 'nullable|in:segar,kemasan',
                'Tanggal_Beli'       => 'nullable|string',
                'Tanggal_Kadaluarsa' => 'nullable|string',
            ]);

            if ($request->has('Nama_Bahan'))     $stok->Nama_Bahan     = $validated['Nama_Bahan'];
            if ($request->has('Kategori_Bahan')) $stok->Kategori_Bahan = $validated['Kategori_Bahan'];
            if ($request->has('Jumlah_Bahan'))   $stok->Jumlah_Bahan   = (double) $validated['Jumlah_Bahan'];
            if ($request->has('Satuan_Bahan'))   $stok->Satuan_Bahan   = $validated['Satuan_Bahan'];
            if ($request->has('Tipe_Bahan'))     $stok->Tipe_Bahan     = $validated['Tipe_Bahan'];
            if ($request->has('Tanggal_Beli'))   $stok->Tanggal_Beli   = date('Y-m-d', strtotime($validated['Tanggal_Beli']));
            if ($request->has('Tanggal_Kadaluarsa')) $stok->Tanggal_Kadaluarsa = date('Y-m-d', strtotime($validated['Tanggal_Kadaluarsa']));

            $stok->save();
            return response()->json(['success' => true, 'message' => 'Data berhasil diperbarui.', 'data' => $this->formatStok($stok->fresh())], 200);
        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    public function hapus(string $id): JsonResponse
    {
        try {
            $idPengguna = $this->getUserId();
            $stok = Stok::where('_id', $id)->where('Id_User', $idPengguna)->first();
            if (!$stok) return response()->json(['success' => false, 'message' => 'Data tidak ditemukan.'], 404);
            $stok->delete();
            return response()->json(['success' => true, 'message' => 'Data berhasil dihapus.'], 200);
        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    private function formatStok(Stok $stok): array
    {
        return [
            '_id'                => $stok->_id,
            'Id_User'            => $stok->Id_User,
            'Nama_Bahan'         => $stok->Nama_Bahan,
            'Kategori_Bahan'     => $stok->Kategori_Bahan,
            'Jumlah_Bahan'       => (double) ($stok->Jumlah_Bahan ?? 0),
            'Satuan_Bahan'       => $stok->Satuan_Bahan,
            'Tipe_Bahan'         => $stok->Tipe_Bahan ?? 'segar',
            'Tanggal_Beli'       => $stok->Tanggal_Beli?->toDateString(),
            'Tanggal_Kadaluarsa' => $stok->Tanggal_Kadaluarsa?->toDateString(),
        ];
    }

    private function serverError(\Exception $e): JsonResponse
    {
        return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
    }
}