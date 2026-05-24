<?php
// UserProfileController.php (FULL)

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Log;

class UserProfileController extends Controller
{
    /**
     * Ambil profil user yang sedang login
     */
    public function index(): JsonResponse
    {
        try {
            $user = Auth::user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan atau belum login.',
                ], 401);
            }

            return response()->json([
                'success' => true,
                'message' => 'Data profil berhasil diambil.',
                'data'    => $this->formatUser($user),
            ], 200);
        } catch (\Exception $e) {
            Log::error('Profile index error: ' . $e->getMessage());
            return $this->serverError($e);
        }
    }

    /**
     * Verifikasi password sebelum mengubah email
     */
    public function verifyPassword(Request $request): JsonResponse
    {
        $request->validate([
            'password' => 'required|string'
        ]);

        $user = Auth::user();
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.'
            ], 401);
        }

        if (Hash::check($request->password, $user->Password)) {
            return response()->json([
                'success' => true,
                'message' => 'Password valid.'
            ]);
        } else {
            return response()->json([
                'success' => false,
                'message' => 'Password salah.'
            ], 401);
        }
    }

    /**
     * Update profil lengkap (username, email, kategori favorit, alergi, budget, frekuensi makan)
     */
    public function updateProfile(Request $request): JsonResponse
    {
        try {
            $user = Auth::user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthenticated.'
                ], 401);
            }

            $validated = $request->validate([
                'Username' => [
                    'nullable',
                    'string',
                    'min:3',
                    'max:255',
                    Rule::unique('users', 'Username')->ignore($user->_id, '_id')
                ],
                'Email' => [
                    'nullable',
                    'email',
                    Rule::unique('users', 'Email')->ignore($user->_id, '_id')
                ],
                'Kategori_Favorit' => ['nullable', 'array'],
                'Kategori_Favorit.*' => ['string'],
                'Alergi' => ['nullable', 'array'],
                'Alergi.*' => ['string'],
                'Budget_Bulanan' => ['nullable', 'integer', 'min:1'],
                'Jumlah_Makan' => ['nullable', 'integer', 'min:1', 'max:4'],
            ]);

            $updateData = [];

            if (array_key_exists('Username', $validated) && !empty($validated['Username'])) {
                $updateData['Username'] = $validated['Username'];
            }
            if (array_key_exists('Email', $validated) && !empty($validated['Email'])) {
                $updateData['Email'] = strtolower($validated['Email']);
            }
            if (array_key_exists('Kategori_Favorit', $validated)) {
                $updateData['Kategori_Favorit'] = array_values(array_filter($validated['Kategori_Favorit'], 'is_string'));
            }
            if (array_key_exists('Alergi', $validated)) {
                $updateData['Alergi'] = $validated['Alergi'] === null ? null : array_values(array_filter($validated['Alergi'], 'is_string'));
            }
            if (array_key_exists('Budget_Bulanan', $validated)) {
                $updateData['Budget_Bulanan'] = (int) $validated['Budget_Bulanan'];
            }
            if (array_key_exists('Jumlah_Makan', $validated)) {
                $updateData['Jumlah_Makan'] = (int) $validated['Jumlah_Makan'];
            }

            if (empty($updateData)) {
                return response()->json([
                    'success' => true,
                    'message' => 'Tidak ada perubahan data.',
                    'data' => $this->formatUser($user)
                ], 200);
            }

            $user->update($updateData);

            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil diperbarui.',
                'data' => $this->formatUser($user->refresh())
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Update profile error: ' . $e->getMessage());
            return $this->serverError($e);
        }
    }

    /**
     * MENYIMPAN ONBOARDING - DENGAN PERUBAHAN: Kategori min 2, Alergi boleh null
     */
    public function saveOnboarding(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'Kategori_Favorit' => ['required', 'array', 'min:2'],
                'Kategori_Favorit.*' => ['string'],
                'Alergi' => ['nullable', 'array'], // nullable, array
                'Alergi.*' => ['string'],
                'Budget_Bulanan' => ['required', 'integer', 'min:1'],
                'Jumlah_Makan' => ['required', 'integer', 'min:2', 'max:4'],
            ], [
                'Kategori_Favorit.required' => 'Pilih minimal 2 kategori makanan favorit.',
                'Kategori_Favorit.min' => 'Pilih minimal 2 kategori makanan favorit.',
                'Budget_Bulanan.required' => 'Budget bulanan wajib diisi.',
                'Budget_Bulanan.min' => 'Budget bulanan harus lebih dari 0.',
                'Jumlah_Makan.required' => 'Frekuensi makan wajib dipilih.',
                'Jumlah_Makan.min' => 'Frekuensi makan minimal 2 kali.',
                'Jumlah_Makan.max' => 'Frekuensi makan maksimal 4 kali.',
            ]);

            $user = Auth::user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan atau belum login.'
                ], 401);
            }

            // Simpan kategori
            $user->Kategori_Favorit = array_values(array_filter($validated['Kategori_Favorit'], 'is_string'));
            
            // Simpan alergi: null jika tidak ada alergi, else array
            if ($validated['Alergi'] === null) {
                $user->Alergi = null;
            } else {
                $user->Alergi = array_values(array_filter($validated['Alergi'], 'is_string'));
            }
            
            $user->Budget_Bulanan = (int) $validated['Budget_Bulanan'];
            $user->Jumlah_Makan = (int) $validated['Jumlah_Makan'];
            $user->updated_at = now();
            
            $saved = $user->save();
            
            if (!$saved) {
                Log::error('Gagal menyimpan onboarding untuk user: ' . $user->_id);
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal menyimpan data onboarding.'
                ], 500);
            }

            $user->refresh();

            Log::info('Onboarding berhasil disimpan untuk user: ' . $user->_id . ', Alergi: ' . json_encode($user->Alergi));

            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil disimpan.',
                'data' => $this->formatUser($user),
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak valid.',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Save onboarding error: ' . $e->getMessage());
            return $this->serverError($e);
        }
    }

    /**
     * (Opsional) Mendapatkan data user untuk keperluan onboarding awal
     */
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
                'data' => $this->formatUser($user),
            ], 200);
        } catch (\Exception $e) {
            Log::error('Get onboarding user error: ' . $e->getMessage());
            return $this->serverError($e);
        }
    }

    /**
     * Store data onboarding parsial (tidak dipakai di alur utama)
     */
    public function storeOnboardingUser(Request $request): JsonResponse
    {
        try {
            $user = Auth::user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Pengguna tidak terautentikasi.'
                ], 401);
            }

            $validated = $request->validate([
                'Kategori_Favorit' => ['nullable', 'array'],
                'Alergi' => ['nullable', 'array'],
                'Target_Kesehatan' => ['nullable', 'string', 'max:255'],
            ]);

            $user->Kategori_Favorit = $request->input('Kategori_Favorit', []);
            $user->Alergi = $request->input('Alergi', []);
            $user->Target_Kesehatan = $request->input('Target_Kesehatan', '');
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Data onboarding berhasil disimpan ke MongoDB!',
                'data' => [
                    'kategori_favorit' => $user->Kategori_Favorit,
                    'alergi' => $user->Alergi,
                    'target_kesehatan' => $user->Target_Kesehatan,
                ]
            ], 200);
        } catch (\Exception $e) {
            Log::error('Store onboarding user error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan internal server saat menyimpan onboarding.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Format data user untuk response JSON
     * status_onboarding dihitung berdasarkan kelengkapan data wajib
     */
    private function formatUser(User $user): array
    {
        return [
            '_id' => $user->_id,
            'username' => $user->Username,
            'email' => $user->Email,
            'kategori_favorit' => $user->Kategori_Favorit ?? [],
            'alergi' => $user->Alergi, // bisa null atau array
            'budget_bulanan' => $user->Budget_Bulanan ?? null,
            'jumlah_makan' => $user->Jumlah_Makan ?? null,
            'status_onboarding' => $this->isOnboardingComplete($user),
        ];
    }

    /**
     * Cek apakah data onboarding user sudah lengkap
     * Kategori minimal 2, Alergi boleh null, budget >0, jumlah makan 2-4
     */
    private function isOnboardingComplete(User $user): bool
    {
        // Kategori_Favorit harus array minimal 2
        $kategori = $user->Kategori_Favorit ?? [];
        if (!is_array($kategori) || count($kategori) < 2) {
            return false;
        }

        // Alergi boleh null, tidak perlu validasi ketat
        // Cukup pastikan field ada (bisa null atau array)

        // Budget_Bulanan harus > 0
        $budget = $user->Budget_Bulanan ?? 0;
        if ($budget <= 0) {
            return false;
        }

        // Jumlah_Makan harus antara 2-4
        $jumlahMakan = $user->Jumlah_Makan ?? 0;
        if ($jumlahMakan < 2 || $jumlahMakan > 4) {
            return false;
        }

        return true;
    }

    /**
     * Handle server error
     */
    private function serverError(\Exception $e): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => 'Terjadi kesalahan server.',
            'error' => $e->getMessage(),
        ], 500);
    }
}