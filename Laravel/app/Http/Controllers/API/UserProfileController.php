<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class UserProfileController extends Controller
{
    // ============================================================
    // 1. GET /api/users/onboarding
    // Ambil data user untuk halaman onboarding / profil
    // ============================================================
    public function getOnboardingUser(): JsonResponse
    {
        try {
            // ----------------------------------------------------------
            // [MODE TES] Ambil user tes langsung dari DB
            // ----------------------------------------------------------
            $user = User::where('username', 'rian_hidayat')->first();
            
            // ----------------------------------------------------------
            // [MODE PRODUCTION] Uncomment baris ini jika Auth sudah siap
            // ----------------------------------------------------------
            // $user = Auth::user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan.',
                ], 404);
            }

            return response()->json([
                'success' => true,
                'message' => 'Data user berhasil diambil.',
                'data'    => $this->formatUser($user),
            ], 200);

        } catch (\Exception $e) {
            return $this->serverError($e);
        }
    }

    // ============================================================
    // 2. PUT /api/users/onboarding/{id}
    // Menyimpan hasil onboarding / update profil dari Flutter
    // ============================================================
    public function saveOnboarding(Request $request, string $id): JsonResponse
    {
        try {
            // --- Validasi gabungan semua field (Bahasa Indonesia) ---
            $validated = $request->validate([
                'nama'               => ['sometimes', 'string', 'max:255'],
                'kategori_favorit'   => ['sometimes', 'array'],
                'kategori_favorit.*' => ['string'],
                'alergi'             => ['sometimes', 'array'],
                'alergi.*'           => ['string'],
                'budget_bulanan'     => ['sometimes', 'numeric', 'min:0'],
                'siklus_anggaran'    => ['sometimes', 'string', 'in:Harian,Mingguan,Bulanan'], 
                'alat_tidak_ada'     => ['sometimes', 'array'],                                
                'alat_tidak_ada.*'   => ['string'],
                'jumlah_makan'       => ['sometimes', 'integer', 'min:1', 'max:6'],
            ], [
                'nama.string'            => 'Nama harus berupa teks.',
                'kategori_favorit.array' => 'Kategori favorit harus berupa array.',
                'alergi.array'           => 'Alergi harus berupa array.',
                'budget_bulanan.numeric' => 'Budget bulanan harus berupa angka.',
                'budget_bulanan.min'     => 'Budget bulanan tidak boleh negatif.',
                'siklus_anggaran.in'     => 'Siklus anggaran harus bernilai Harian, Mingguan, atau Bulanan.',
                'alat_tidak_ada.array'   => 'Alat tidak ada harus berupa array.',
                'jumlah_makan.integer'   => 'Jumlah makan harus berupa bilangan bulat.',
                'jumlah_makan.min'       => 'Jumlah makan minimal 1.',
                'jumlah_makan.max'       => 'Jumlah makan maksimal 6.',
            ]);

            // ----------------------------------------------------------
            // [MODE TES] Cari user by ID dari URL param
            // ----------------------------------------------------------
            $user = User::find($id);
            
            // ----------------------------------------------------------
            // [MODE PRODUCTION] Uncomment blok ini di production
            // ----------------------------------------------------------
            // $user      = Auth::user();
            // $authCheck = $user && (string) $user->_id === $id;
            // if (!$authCheck) {
            //     return response()->json([
            //         'success' => false,
            //         'message' => 'Akses ditolak.',
            //     ], 403);
            // }

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan.',
                ], 404);
            }

            // ----------------------------------------------------------
            // Proses pemindahan & mapping data ke database ($fields)
            // ----------------------------------------------------------
            $fields = [];

            if (array_key_exists('nama', $validated)) {
                $fields['nama'] = $validated['nama'];
            }

            if (array_key_exists('kategori_favorit', $validated)) {
                $fields['kategori_favorit'] = array_values(
                    array_filter((array) $validated['kategori_favorit'], 'is_string')
                );
            }

            if (array_key_exists('alergi', $validated)) {
                $fields['alergi'] = array_values(
                    array_filter((array) $validated['alergi'], 'is_string')
                );
            }

            if (array_key_exists('budget_bulanan', $validated)) {
                $fields['budget_bulanan'] = (float) $validated['budget_bulanan'];
            }

            // Mengambil kodingan budget_cycle dari Profile ke siklus_anggaran
            if (array_key_exists('siklus_anggaran', $validated)) {
                $fields['siklus_anggaran'] = $validated['siklus_anggaran'];
            }

            // Mengambil kodingan missing_tools dari Profile ke alat_tidak_ada
            if (array_key_exists('alat_tidak_ada', $validated)) {
                $fields['alat_tidak_ada'] = array_values(
                    array_filter((array) $validated['alat_tidak_ada'], 'is_string')
                );
            }

            if (array_key_exists('jumlah_makan', $validated)) {
                $fields['jumlah_makan'] = (int) $validated['jumlah_makan'];
            }

            $fields['updated_at'] = now();

            // Eksekusi update data ke MongoDB / SQL
            User::where('_id', $id)->update($fields);
            
            // Ambil data terbaru setelah diperbarui untuk dikembalikan ke Flutter
            $user = User::find($id);

            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil diperbarui.',
                'data'    => $this->formatUser($user),
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
    // Helper: format data user ke Bahasa Indonesia untuk Response JSON
    // ============================================================
    private function formatUser(User $user): array
    {
        return [
            '_id'              => $user->_id,
            'username'         => $user->username,
            'nama'             => $user->nama             ?? $user->username, 
            'email'            => $user->email,
            'kategori_favorit' => $user->kategori_favorit ?? [],
            'alergi'           => $user->alergi           ?? [],
            'budget_bulanan'   => $user->budget_bulanan   ?? null,
            'siklus_anggaran'  => $user->siklus_anggaran  ?? 'Bulanan', // Default value jika kosong
            'alat_tidak_ada'   => $user->alat_tidak_ada   ?? [],        // Berupa array kosong [] jika kosong
            'jumlah_makan'     => $user->jumlah_makan     ?? null,
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