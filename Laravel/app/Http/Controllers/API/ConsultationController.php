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
            $sisaBudget  = $user->Saldo_Budget;
            $totalBudget = $user->Budget_Bulanan ?? 0;
        } else {
            $nama        = "Cookmate";
            $sisaBudget  = $userContext['sisaBudget']  ?? 0;
            $totalBudget = $userContext['totalBudget'] ?? 0;
        }

        $persen     = $totalBudget > 0 ? round(($sisaBudget / $totalBudget) * 100) : 0;
        $statusUser = $user ? 'Terautentikasi' : 'Guest/Tamu';

        // --- SYSTEM PROMPT ---
        if (!$user) {
            // Guest mode: Format C — Gemini langsung balas dengan tips masakan, tanpa Flask
            $systemPrompt = <<<PROMPT
Kamu adalah ChefBot, asisten memasak dari aplikasi CookCash.
Kamu ramah, singkat, dan selalu berbahasa Indonesia casual (boleh pakai "sih", "dong", "nih").

KONTEKS USER SAAT INI:
- Status: Tamu (belum login)
- Nama: {$nama}

ATURAN WAJIB — KAMU HARUS SELALU MENGIKUTI INI:
1. Respons kamu HANYA boleh berupa JSON murni. DILARANG ada teks atau karakter apapun di luar JSON.
2. DILARANG menggunakan markdown, code block, atau tag ```json```.
3. Untuk SEMUA jenis pesan (obrolan, sapaan, pertanyaan masakan, sebut bahan, sebut nama masakan), SELALU gunakan FORMAT C berikut:

FORMAT C — satu-satunya format untuk guest:
{"intent":"guest_chat","reply":"balasan casual 2-3 kalimat, boleh menyebut resep atau bahan secara ringkas","cooking_tips":["tips masakan pendek 1","tips masakan pendek 2","tips masakan pendek 3"]}

ATURAN FORMAT C:
- "reply": jawab pertanyaan user secara langsung dan helpful. Jika user tanya resep atau bahan, berikan gambaran singkat cara masak atau bahan yang dibutuhkan.
- "cooking_tips": selalu isi 3 tips singkat yang RELEVAN dengan topik yang dibicarakan user (bukan tips generik). Jika user tanya ayam geprek, tips harus soal ayam geprek. Jika obrolan umum, tips soal hemat belanja / memasak sehari-hari.
- Jangan pernah gunakan Format A atau Format B. Selalu Format C.
PROMPT;
        } else {
            // Authenticated user: Format A (chat) + Format B (recommendation via Flask)
            $systemPrompt = <<<PROMPT
Kamu adalah ChefBot, asisten memasak hemat dari aplikasi CookCash.
Kamu ramah, singkat, dan selalu berbahasa Indonesia casual (boleh pakai "sih", "dong", "nih").

KONTEKS USER SAAT INI:
- Status: {$statusUser}
- Nama: {$nama}
- Sisa Budget: Rp {$sisaBudget} dari Rp {$totalBudget} ({$persen}%)

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
6. WAJIB panggil user dengan nama mereka di dalam "reply". 
   Nama user adalah: {$nama}. 
   DILARANG menyebut "Cookmate" atau nama lain selain nama user
PROMPT;
        }
        $history = [];
        foreach ($historyInput as $item) {
            $role = ($item['role'] === 'user') ? Role::USER : Role::MODEL;
            $text = $item['content'] ?? $item['text'] ?? $item['message'] ?? '';
            if ($text !== '') {
                $history[] = Content::parse($text, $role);
            }
        }

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
                ];

                $flaskUrl      = rtrim(env('FLASK_API_URL'), '/') . '/api';
                $flaskResponse = Http::timeout(10)->post($flaskUrl, $flaskPayload);

                if ($flaskResponse->successful()) {
                    $flaskData        = $flaskResponse->json();
                    $resepRekomendasi = $flaskData['recommendations'] ?? [];

                    return response()->json([
                        'success'  => true,
                        'intent'   => 'recommendation',
                        'reply'    => 'Ini beberapa resep yang cocok dengan bahanmu!',
                        'recipes'  => $resepRekomendasi,
                        'is_guest' => !$user,
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

        if ($parsed['intent'] === 'guest_chat') {
            return response()->json([
                'success'      => true,
                'intent'       => 'guest_chat',
                'reply'        => $parsed['reply']        ?? 'Maaf, aku tidak punya jawaban nih.',
                'cooking_tips' => $parsed['cooking_tips'] ?? [],
            ]);
        }

        
        return response()->json([
            'success' => false,
            'message' => 'Intent tidak dikenali oleh sistem.',
        ], 422);
    }
}