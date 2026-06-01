<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Gemini\Laravel\Facades\Gemini;
use Gemini\Data\Content;
use Gemini\Enums\Role;
use Illuminate\Support\Facades\Log;

class GuestController extends Controller
{
    public function send(Request $request)
    {
        $request->validate([
            'message' => 'required|string|max:1000',
            'history' => 'nullable|array',
        ]);

        $userMessage  = $request->input('message', '');
        $historyInput = $request->input('history', []);

        // --- SYSTEM PROMPT GUEST ---
        // Fokus pada obrolan memasak & hemat, tanpa fitur rekomendasi berbasis bahan
        $systemPrompt = <<<PROMPT
Kamu adalah ChefBot, asisten memasak hemat dari aplikasi CookCash untuk pengguna tamu (guest).
Kamu ramah, singkat, dan selalu berbahasa Indonesia casual (boleh pakai "sih", "dong", "nih").

KONTEKS:
- Pengguna ini belum login (mode tamu), jadi kamu tidak tahu budget atau stok bahan mereka.
- Kamu TIDAK memiliki fitur rekomendasi resep berbasis bahan untuk guest. Jika user meminta rekomendasi resep berdasarkan bahan, sarankan mereka untuk login agar mendapat fitur lengkap.
- Tetap bantu user dengan tips memasak hemat, ide menu umum, atau informasi masakan secara umum.

ATURAN WAJIB:
1. Respons kamu HANYA boleh berupa JSON murni. DILARANG ada teks atau karakter apapun di luar JSON.
2. DILARANG menggunakan markdown, code block, atau tag ```json```.
3. Selalu gunakan format berikut:
   {"intent":"chat","reply":"balasan casual bahasa Indonesia maks 3-4 kalimat"}
4. Jika user meminta rekomendasi berdasarkan bahan/stok (contoh: "ada ayam nih mau masak apa?"),
   arahkan mereka login dengan ramah. Contoh reply: "Wah seru! Buat rekomendasi resep dari bahanmu, kamu perlu login dulu dong. Di sana ChefBot bisa kasih saran yang lebih pas buat kamu! 😊"
5. Jangan pernah menjawab dengan kalimat biasa di luar JSON.
PROMPT;

        // --- BANGUN HISTORY ---
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

            // Bersihkan jika Gemini tetap membungkus dengan markdown
            $cleanedText = trim($rawText);
            $cleanedText = preg_replace('/^```json\s*/i', '', $cleanedText);
            $cleanedText = preg_replace('/^```\s*/i', '', $cleanedText);
            $cleanedText = preg_replace('/\s*```$/i', '', $cleanedText);
            $cleanedText = trim($cleanedText);

            $parsed = json_decode($cleanedText, true);

            if (json_last_error() !== JSON_ERROR_NONE || !isset($parsed['intent'])) {
                Log::warning('ChefBot Guest: Respons Gemini bukan JSON valid.', [
                    'raw'     => $rawText,
                    'cleaned' => $cleanedText,
                ]);
                // Fallback: kembalikan raw text daripada error ke user
                return response()->json([
                    'success' => true,
                    'intent'  => 'chat',
                    'reply'   => $rawText,
                ]);
            }

        } catch (\Throwable $e) {
            Log::error('ChefBot Guest: Gagal menghubungi Gemini API.', [
                'error'   => $e->getMessage(),
                'message' => $userMessage,
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat menghubungi layanan AI.',
            ], 500);
        }

        // --- RESPONSE ---
        // Guest mode hanya mengenal intent 'chat'
        return response()->json([
            'success' => true,
            'intent'  => 'chat',
            'reply'   => $parsed['reply'] ?? 'Maaf, aku tidak bisa menjawab itu sekarang.',
        ]);
    }
}