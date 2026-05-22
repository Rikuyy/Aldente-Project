<?php

namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Gemini\Laravel\Facades\Gemini;
use Gemini\Data\Content;
use Gemini\Data\Part;
use Symfony\Component\Process\Process;
use Illuminate\Support\Facades\Log;

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
    $historyInput = $request->input('history', []);

    $user      = auth()->user();
    if ($user) {
            $nama = $user->Username;
            $alergi = $user->Alergi ?? 'Tidak ada';
            $sisaBudget = $user->wallets()->sum('amount');
            $totalBudget = $user->Budget_Bulanan ?? 0;
        } else { 
            $nama = "Cookmate";
            $alergi = "Tidak diketahui (Guest)";
            $sisaBudget = $request->input('context.sisaBudget', 0);
            $totalBudget = $request->input('context.totalBudget', 0);
        }

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

    $resepContext = '';
    if ($process->isSuccessful()) {
        $resepDitemukan = json_decode($process->getOutput(), true) ?? [];
    }
    if (!empty($resepDitemukan)) {
        $resepContext = "\n\nRESEP RELEVAN DARI DATABASE:\n";
        foreach ($resepDitemukan as $i => $resep) {
            $no = $i + 1;
            $resepContext .= "{$no}. Nama: " . ($resep['Title Cleaned'] ?? 'Tanpa Nama') . "\n";
            $resepContext .= "   Kategori: " . ($resep['Category'] ?? '-') . "\n";
            $resepContext .= "   Bahan: " . ($resep['Ingredients Cleaned'] ?? '-') . "\n";
            $resepContext .= "   Langkah: " . ($resep['Steps'] ?? '-') . "\n\n";
        }
        $resepContext .= "Gunakan resep di atas sebagai referensi utama jawabanmu.";
    }

        if (empty($resepContext)) {
            $resepContext = "\n\nTidak ada resep yang cocok di database. Jawab berdasarkan pengetahuan umum masakan hemat.";
        }
        $persen = $totalBudget > 0 ? round(($sisaBudget / $totalBudget) * 100) : 0;

        $systemPrompt = <<<PROMPT
Kamu adalah ChefBot, asisten memasak hemat dari aplikasi CookCash.
Kamu ramah, singkat, dan selalu berbahasa Indonesia casual (boleh pakai "sih", "dong", "nih").

KONTEKS USER SAAT INI:
- Status:  ($user ? 'Terautentikasi' : 'Guest/Tamu')
- Nama: {$nama}
- Sisa Budget: Rp {$sisaBudget} dari Rp {$totalBudget} ({$persen}%)

ATURAN:
1. Prioritaskan resep dari database yang sudah disediakan.
2. Jika perlu beli bahan, sarankan apa yang kurang dari stok yang ada.
3. Jika budget < 30%, sarankan masak dari stok, jangan beli.
4. Jawab maksimal 3-4 kalimat kecuali diminta resep lengkap.
{$resepContext}
PROMPT;

        
        $history = [];
        foreach ($historyInput as $item) {
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
                'is_guest' => !$user
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