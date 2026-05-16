<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Gemini\Laravel\Facades\Gemini;
use Gemini\Data\Content;
use Gemini\Data\Part;

class ConsultationController extends Controller
{
    public function send(Request $request)
    {
        $request->validate([
            'message'  => 'required|string|max:1000',
            'history'  => 'nullable|array',  
            'context'  => 'nullable|array',  
        ]);

        $userContext = $request->input('context', [
            'nama'         => 'Pengguna',
            'stokBahan'    => [],
            'sisaBudget'   => 0,
            'totalBudget'  => 150000,
        ]);

        $stok   = implode(', ', $userContext['stokBahan'] ?? []);
        $sisa   = $userContext['sisaBudget']   ?? 0;
        $total  = $userContext['totalBudget']  ?? 150000;
        $persen = $total > 0 ? round(($sisa / $total) * 100) : 0;
        $nama   = $userContext['nama'] ?? 'Pengguna';

        $systemPrompt = <<<PROMPT
Kamu adalah ChefBot, asisten memasak hemat dari aplikasi Cookcah.
Kamu ramah, singkat, dan selalu berbahasa Indonesia casual (boleh pakai "sih", "dong", "nih").

KONTEKS USER SAAT INI:
- Nama: {$nama}
- Stok bahan di kulkas: {$stok}
- Sisa budget hari ini: Rp {$sisa} dari Rp {$total}
- Persentase budget tersisa: {$persen}%

ATURAN:
1. Prioritaskan resep dari bahan yang SUDAH ADA di stok.
2. Jika perlu beli bahan, estimasikan harganya dan cek apakah masuk budget.
3. Format resep: nama masakan → bahan → langkah singkat → estimasi biaya.
4. Jika budget < 30%, sarankan masak dari stok, jangan beli.
5. Jawab maksimal 3-4 kalimat kecuali diminta resep lengkap.
PROMPT;

        
        $history = [];
        foreach ($request->input('history', []) as $item) {
            $history[] = [
                'role'  => $item['role'],  
                'parts' => [['text' => $item['text']]],
            ];
        }

        try {
            $response = Gemini::generativeModel(model: 'models/gemini-2.5-flash')
                ->withSystemInstruction(new Content(parts: [new Part(text: $systemPrompt)]))
                ->startChat(history: $history)
                ->sendMessage($request->input('message'));

            return response()->json([
                'success' => true,
                'reply'   => $response->text(),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'reply'   => 'Waduh, ada gangguan koneksi nih. Coba lagi ya! 🙏',
                'error'   => $e->getMessage(),
            ], 500);
        }
    }
}