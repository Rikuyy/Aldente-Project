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
    
    $message     = $request->input('message');
    $userContext = $request->input('context', []);

    $user      = auth()->user();
    $alergi    = $user?->riwayat_alergi ?? '';

    $pythonExe  = env('PYTHON_EXE', 'python');
    $scriptPath = base_path('rekomendasi.py');

    $process = new Process(
        [$pythonExe, $scriptPath, $message, $alergi],
        null,
        [
            'SYSTEMROOT' => getenv('SYSTEMROOT') ?: 'C:\\Windows',
            'PATH'       => getenv('PATH'),
        ]
    );
    $process->run();

    $resepDitemukan = [];
    if ($process->isSuccessful()) {
        $resepDitemukan = json_decode($process->getOutput(), true) ?? [];
    }

    $resepContext = '';
    if (!empty($resepDitemukan)) {
        $resepContext = "\n\nRESEP RELEVAN DARI DATABASE:\n";
        foreach ($resepDitemukan as $i => $resep) {
            $no = $i + 1;
            $resepContext .= "{$no}. {$resep['nama']}\n";
            $resepContext .= "   Bahan: {$resep['bahan']}\n";
            $resepContext .= "   Langkah: {$resep['langkah']}\n";
            $resepContext .= "   Estimasi biaya: Rp {$resep['estimasi_biaya']}\n\n";
        }
        $resepContext .= "Gunakan resep di atas sebagai referensi utama jawabanmu.";
    } else {
        $resepContext = "\n\nTidak ada resep yang cocok di database. Jawab berdasarkan pengetahuanmu.";
    }

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
- Sisa budget hari ini: Rp {$sisa} dari Rp {$total} ({$persen}%)

ATURAN:
1. Prioritaskan resep dari database yang sudah disediakan.
2. Jika perlu beli bahan, sarankan apa yang kurang dari stok yang ada.
3. Jika budget < 30%, sarankan masak dari stok, jangan beli.
4. Jawab maksimal 3-4 kalimat kecuali diminta resep lengkap.
{$resepContext}
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
                ->sendMessage('message');

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