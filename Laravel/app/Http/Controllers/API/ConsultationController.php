<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Gemini\Laravel\Facades\Gemini;
use Gemini\Data\Content;
use Gemini\Enums\Role;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;

class ConsultationController extends Controller
{
    public function send(Request $request)
    {
        $request->validate([
            'message' => 'required|string|max:1000',
            'history' => 'nullable|array',
            'context' => 'nullable|array',
        ]);

        $userMessage  = $request->input('message', '');
        $userContext  = $request->input('context', []);
        $historyInput = $request->input('history', []);

        // --- KONTEKS USER ---
        $user = auth()->user();
        if ($user) {
            $nama        = $user->Username;
            $sisaBudget  = $user->Saldo_Budget ?? 0;
            $totalBudget = $user->Budget_Bulanan ?? 0;
            // Alergi: ambil dari field user, pastikan array
            $alergiUser  = is_array($user->Alergi) ? $user->Alergi : json_decode($user->Alergi ?? '[]', true) ?? [];
        } else {
            $nama        = "Cookmate";
            $sisaBudget  = $userContext['sisaBudget']  ?? 0;
            $totalBudget = $userContext['totalBudget'] ?? 0;
            $alergiUser  = $userContext['alergi'] ?? [];
        }

        $persen     = $totalBudget > 0 ? round(($sisaBudget / $totalBudget) * 100) : 0;
        $statusUser = $user ? 'Terautentikasi' : 'Guest/Tamu';
        $alergiStr  = !empty($alergiUser) ? implode(', ', $alergiUser) : 'tidak ada';

        // --- SYSTEM PROMPT ---
        $systemPrompt = <<<PROMPT
Kamu adalah ChefBot, asisten memasak hemat dari aplikasi CookCash.
Kamu ramah, singkat, dan selalu berbahasa Indonesia casual (boleh pakai "sih", "dong", "nih").

KONTEKS USER SAAT INI:
- Status: {$statusUser}
- Nama: {$nama}
- Sisa Budget: Rp {$sisaBudget} dari Rp {$totalBudget} ({$persen}%)
- Alergi: {$alergiStr}

ATURAN WAJIB — KAMU HARUS SELALU MENGIKUTI INI:
1. Respons kamu HANYA boleh berupa JSON murni. DILARANG ada teks, kalimat, atau karakter apapun di luar JSON.
2. DILARANG menggunakan markdown, code block, atau tag ```json```.
3. Tentukan intent dari pesan pengguna lalu pilih SALAH SATU format berikut:

FORMAT A — untuk obrolan biasa, sapaan, pertanyaan umum, atau tips hemat:
{"intent":"chat","reply":"balasan casual bahasa Indonesia maks 3-4 kalimat"}

FORMAT B — jika user menyebut bahan makanan ATAU nama masakan (contoh: "ada ayam", "mau masak rendang", "punya tahu dan tempe"):
{"intent":"recommendation","Title_Cleaned":"nama masakan atau kosong","Ingredients_Cleaned":["bahan1","bahan2"],"Category":"kategori atau kosong"}

4. "aku mau ayam geprek" → WAJIB pakai FORMAT B karena menyebut nama masakan.
5. Jangan pernah menjawab dengan kalimat biasa. Selalu JSON.
PROMPT;

        // --- BANGUN HISTORY ---
        // Flutter bisa kirim key 'content', 'text', atau 'message' — handle semua kemungkinan
        $history = [];
        foreach ($historyInput as $item) {
            $role = ($item['role'] === 'user') ? Role::USER : Role::MODEL;
            $text = $item['content'] ?? $item['text'] ?? $item['message'] ?? '';
            if ($text !== '') {
                $history[] = Content::parse($text, $role);
            }
        }

        // --- KIRIM KE GEMINI ---
        try {
            $chat = Gemini::generativeModel(model: 'models/gemini-2.5-flash')
                ->withSystemInstruction(Content::parse($systemPrompt, Role::USER))
                ->startChat(history: $history);

            $geminiResponse = $chat->sendMessage($userMessage);
            $rawText        = $geminiResponse->text();
            $cleanedText = trim($rawText);
            $cleanedText = preg_replace('/^```json\s*/i', '', $cleanedText);
            $cleanedText = preg_replace('/^```\s*/i', '', $cleanedText);
            $cleanedText = preg_replace('/\s*```$/i', '', $cleanedText);
            $cleanedText = trim($cleanedText);

            $parsed = json_decode($cleanedText, true);

            if (json_last_error() !== JSON_ERROR_NONE || !isset($parsed['intent'])) {
                Log::warning('ChefBot: Respons Gemini bukan JSON valid.', [
                    'raw'     => $rawText,
                    'cleaned' => $cleanedText,
                ]);
                // Fallback: kembalikan raw text sebagai chat biasa daripada error
                return response()->json([
                    'success' => true,
                    'intent'  => 'chat',
                    'reply'   => $rawText,
                ]);
            }

        } catch (\Throwable $e) {
            Log::error('ChefBot: Gagal menghubungi Gemini API.', [
                'error'   => $e->getMessage(),
                'message' => $userMessage,
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat menghubungi layanan AI.',
            ], 500);
        }

        // --- ROUTING INTENT ---

        if ($parsed['intent'] === 'chat') {
            return response()->json([
                'success' => true,
                'intent'  => 'chat',
                'reply'   => $parsed['reply'] ?? 'Maaf, saya tidak memiliki jawaban saat ini.',
            ]);
        }

        if ($parsed['intent'] === 'recommendation') {
            try {
                $flaskPayload = [
                    'Title_Cleaned'       => $parsed['Title_Cleaned']       ?? '',
                    'Ingredients_Cleaned' => $parsed['Ingredients_Cleaned'] ?? [],
                    'Category'            => $parsed['Category']            ?? '',
                    'allergies'           => $alergiUser,
                ];

                $flaskUrl      = rtrim(env('FLASK_API_URL'), '/') . '/api';
                $flaskResponse = Http::timeout(10)->post($flaskUrl, $flaskPayload);

                if ($flaskResponse->successful()) {
                    $flaskData        = $flaskResponse->json();
                    $resepRekomendasi = $flaskData['recommendations'] ?? [];

                    return response()->json([
                        'success'         => true,
                        'intent'          => 'recommendation',
                        'reply'           => 'Ini beberapa resep yang cocok dengan bahanmu!',
                        'recipes'         => $resepRekomendasi,
                        'allergy_warning' => $flaskData['allergy_warning'] ?? false,
                        'is_guest'        => !$user,
                    ]);
                }

                Log::error('ChefBot: Flask mengembalikan error.', [
                    'status' => $flaskResponse->status(),
                    'body'   => $flaskResponse->body(),
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Layanan rekomendasi sedang tidak tersedia.',
                ], 502);

            } catch (\Throwable $e) {
                Log::error('ChefBot: Gagal menghubungi Flask API.', [
                    'error' => $e->getMessage(),
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Terjadi kesalahan saat menghubungi layanan rekomendasi.',
                ], 500);
            }
        }

        Log::warning('ChefBot: Intent tidak dikenal.', ['parsed' => $parsed]);
        return response()->json([
            'success' => false,
            'message' => 'Intent tidak dikenali oleh sistem.',
        ], 422);
    }
}