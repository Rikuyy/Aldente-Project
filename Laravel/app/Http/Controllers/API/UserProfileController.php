<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Resep;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class UserProfileController extends Controller
{
    public function getOnboardingUser(): JsonResponse
    {
        try {
            $user = Auth::user();
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
    public function saveOnboarding(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'Kategori_Favorit'   => ['required', 'array', 'min:1'],
                'Kategori_Favorit.*' => ['string'],
                'Alergi'             => ['required', 'array'],
                'Alergi.*'           => ['string'],
                'Budget_Bulanan'     => ['required', 'integer', 'min:1'],
                'Jumlah_Makan'       => ['required', 'integer', 'min:2', 'max:4'],
            ], [
                'Kategori_Favorit.required' => 'Pilih minimal 1 kategori makanan favorit.',
                'Kategori_Favorit.min'      => 'Pilih minimal 1 kategori makanan favorit.',
                'Budget_Bulanan.required'   => 'Budget bulanan wajib diisi.',
                'Budget_Bulanan.min'        => 'Budget bulanan harus lebih dari 0.',
                'Jumlah_Makan.required'     => 'Frekuensi makan wajib dipilih.',
                'Jumlah_Makan.min'          => 'Frekuensi makan minimal 2 kali.',
                'Jumlah_Makan.max'          => 'Frekuensi makan maksimal 4 kali.',
            ]);

            $user = Auth::user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan atau belum login.',
                ], 401); // 401 Unauthorized lebih tepat dibanding 404
            }

            $user->update([
                'Kategori_Favorit' => array_values(
                    array_filter((array) $validated['Kategori_Favorit'], 'is_string')
                ),
                'Alergi'           => array_values(
                    array_filter((array) $validated['Alergi'], 'is_string')
                ),
                'Budget_Bulanan'   => (int) $validated['Budget_Bulanan'],
                'Jumlah_Makan'     => (int) $validated['Jumlah_Makan'],
                'updated_at'       => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil disimpan.',
                'data'    => $this->formatUser($user->refresh()), // Refresh data terbaru
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

    private function formatUser(User $user): array
    {
        return [
            '_id'              => $user->_id,
            'username'         => $user->Username,
            'email'            => $user->Email,
            'kategori_favorit' => $user->Kategori_Favorit ?? [],
            'alergi'           => $user->Alergi           ?? [],
            'budget_bulanan'   => $user->Budget_Bulanan   ?? null,
            'jumlah_makan'     => $user->Jumlah_Makan     ?? null,
        ];
    }

    private function serverError(\Exception $e): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan server.',
            'error'   => $e->getMessage(),
        ], 500);
    }
}