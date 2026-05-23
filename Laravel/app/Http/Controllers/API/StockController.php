<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Stok;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class StockController extends Controller
{
    // ============================================================
    // 1. GET /api/stok
    // Ambil semua stok bahan milik user, dikelompokkan per kategori
    // ============================================================
    public function index(): JsonResponse
    {
        try {
            // ----------------------------------------------------------
            // [MODE TES] Ambil user tes langsung dari DB
            // ----------------------------------------------------------
            $idPengguna = Auth::id();

            $stok = Stok::where('id_pengguna', $idPengguna)->get();

            $dikelompokkan = $stok->groupBy('kategori_bahan')->map(function ($items, $kategori) {
                return [
                    'kategori' => $kategori,
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

    // ============================================================
    // 2. POST /api/stok
    // Tambah bahan baru atau catat stok masuk
    // ============================================================
    public function simpan(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'nama_bahan'     => ['required', 'string', 'max:255'],
                'satuan'         => ['required', 'string', 'max:50'],
                'jumlah'         => ['required', 'numeric', 'min:0'],
                'kategori_bahan' => ['required', 'string', 'max:100'],
                'keterangan'     => ['nullable', 'string', 'max:255'],
            ], [
                'nama_bahan.required'     => 'Nama bahan wajib diisi.',
                'satuan.required'         => 'Satuan wajib diisi.',
                'jumlah.required'         => 'Jumlah wajib diisi.',
                'jumlah.numeric'          => 'Jumlah harus berupa angka.',
                'jumlah.min'              => 'Jumlah tidak boleh negatif.',
                'kategori_bahan.required' => 'Kategori bahan wajib diisi.',
            ]);

            $validated['id_pengguna']  = Auth::id();
            $validated['keterangan']   = $validated['keterangan'] ?? 'Stok ditambahkan';
            $validated['tipe_riwayat'] = 'masuk';
            $validated['waktu']        = now();

            $stok = Stok::create($validated);

            return response()->json([
                'success' => true,
                'message' => 'Stok bahan berhasil ditambahkan.',
                'data'    => $this->formatStok($stok),
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak valid.',
                'errors'  => $e->errors(),
            ], 422);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // 3. PUT /api/stok/{id}
    // Perbarui data stok bahan (nama, jumlah, satuan, dll)
    // ============================================================
    public function perbarui(Request $request, string $id): JsonResponse
    {
        try {
            $validated = $request->validate([
                'nama_bahan'     => ['sometimes', 'string', 'max:255'],
                'satuan'         => ['sometimes', 'string', 'max:50'],
                'jumlah'         => ['sometimes', 'numeric', 'min:0'],
                'kategori_bahan' => ['sometimes', 'string', 'max:100'],
                'keterangan'     => ['nullable', 'string', 'max:255'],
            ], [
                'jumlah.numeric' => 'Jumlah harus berupa angka.',
                'jumlah.min'     => 'Jumlah tidak boleh negatif.',
            ]);

            $stok = Stok::where('_id', $id)
                        ->where('id_pengguna', Auth::id())
                        ->first();

            if (!$stok) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data stok tidak ditemukan.',
                ], 404);
            }

            $validated['updated_at'] = now();
            $stok->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Data stok berhasil diperbarui.',
                'data'    => $this->formatStok($stok->fresh()),
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak valid.',
                'errors'  => $e->errors(),
            ], 422);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // 4. DELETE /api/stok/{id}
    // Hapus data stok bahan milik user
    // ============================================================
    public function hapus(string $id): JsonResponse
    {
        try {
            $stok = Stok::where('_id', $id)
                        ->where('id_pengguna', Auth::id())
                        ->first();

            if (!$stok) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data stok tidak ditemukan.',
                ], 404);
            }

            $stok->delete();

            return response()->json([
                'success' => true,
                'message' => 'Data stok berhasil dihapus.',
            ], 200);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // 5. GET /api/stok/cari?q=...
    // Cari bahan berdasarkan nama
    // ============================================================
    public function cari(Request $request): JsonResponse
    {
        try {
            $kataCari = $request->query('q', '');

            $hasil = Stok::where('id_pengguna', Auth::id())
                         ->where('nama_bahan', 'LIKE', "%{$kataCari}%")
                         ->get()
                         ->map(fn($item) => $this->formatStok($item));

            return response()->json([
                'success' => true,
                'message' => 'Hasil pencarian bahan.',
                'data'    => $hasil,
            ], 200);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // 6. POST /api/stok/masak-selesai
    // Kurangi stok otomatis setelah selesai memasak
    // Body: { "bahan": [{ "id": "...", "jumlah": 2 }, ...] }
    // ============================================================
    public function masakSelesai(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'bahan'          => ['required', 'array'],
                'bahan.*.id'     => ['required', 'string'],
                'bahan.*.jumlah' => ['required', 'numeric', 'min:0'],
            ], [
                'bahan.required'          => 'Daftar bahan wajib diisi.',
                'bahan.array'             => 'Format bahan tidak valid.',
                'bahan.*.id.required'     => 'ID bahan wajib diisi.',
                'bahan.*.jumlah.required' => 'Jumlah penggunaan bahan wajib diisi.',
                'bahan.*.jumlah.min'      => 'Jumlah tidak boleh negatif.',
            ]);

            $tidakDitemukan = [];

            foreach ($request->bahan as $item) {
                $stok = Stok::where('_id', $item['id'])
                            ->where('id_pengguna', Auth::id())
                            ->first();

                if ($stok) {
                    $stok->jumlah = max($stok->jumlah - $item['jumlah'], 0);
                    $stok->updated_at = now();
                    $stok->save();
                } else {
                    $tidakDitemukan[] = $item['id'];
                }
            }

            return response()->json([
                'success'         => true,
                'message'         => 'Stok berhasil diperbarui setelah memasak.',
                'tidak_ditemukan' => $tidakDitemukan,
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak valid.',
                'errors'  => $e->errors(),
            ], 422);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // Helper: format data stok ke response JSON
    // ============================================================
    private function formatStok(Stok $stok): array
    {
        return [
            '_id'            => $stok->_id,
            'nama_bahan'     => $stok->nama_bahan,
            'satuan'         => $stok->satuan,
            'jumlah'         => $stok->jumlah,
            'kategori_bahan' => $stok->kategori_bahan,
            'keterangan'     => $stok->keterangan     ?? null,
            'tipe_riwayat'   => $stok->tipe_riwayat   ?? null,
            'waktu'          => $stok->waktu           ?? null,
            'stok_menipis'   => ($stok->jumlah <= 2),
        ];
    }

    // ============================================================
    // Helper: response error 500 jika terjadi kendala server
    // ============================================================
    private function serverError(\Exception $e): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan server.',
            'error'   => $e->getMessage(),
        ], 500);
    }
}