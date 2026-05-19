<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Symfony\Component\Process\Process;

class ChatbotController extends Controller
{
public function rekomendasi(Request $request)
{
    $query = $request->input('query');
    
    $user = auth()->user(); 
    $alergi = $user->riwayat_alergi; 

    $pythonExe = env('PYTHON_EXE', 'python');
    $scriptPath = base_path('rekomendasi.py');

    // Kirim query dan data alergi dari database ke Python
    $process = new Process([$pythonExe, $scriptPath, $query, $alergi], null, [
        'SYSTEMROOT' => getenv('SYSTEMROOT') ?: 'C:\\Windows',
        'PATH' => getenv('PATH')
    ]);
        $process->run();

        if (!$process->isSuccessful()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menjalankan AI',
                'debug' => $process->getErrorOutput()
            ], 500);
        }

        $result = json_decode($process->getOutput(), true);

        return response()->json([
            'status' => 'success',
            'results' => $result
        ]);
    }
    public function updateModel()
    {
        $pythonExe = env('PYTHON_EXE', 'python');
        $scriptPath = base_path('update_model.py');

        // PASTIKAN BARIS INI SAMA (Ada tambahan SYSTEMROOT)
        $process = new Process([$pythonExe, $scriptPath], null, [
            'SYSTEMROOT' => getenv('SYSTEMROOT') ?: 'C:\\Windows',
            'PATH' => getenv('PATH')
        ]);
        
        $process->setTimeout(180); // Waktu 3 menit buat AI belajar
        $process->run();

        if (!$process->isSuccessful()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal memperbarui model AI',
                'debug' => $process->getErrorOutput()
            ], 500);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'SUKSES! Model berhasil diperbarui dengan data terbaru.'
        ]);
    }

    public function evaluasi()
    {
        $pythonExe = env('PYTHON_EXE', 'python');
        $scriptPath = base_path('evaluasi_model.py');

        $process = new Process([$pythonExe, $scriptPath], null, [
            'SYSTEMROOT' => getenv('SYSTEMROOT') ?: 'C:\\Windows',
            'PATH' => getenv('PATH')
        ]);

        $process->run();

        if (!$process->isSuccessful()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menjalankan evaluasi model AI',
                'debug' => $process->getErrorOutput()
            ], 500);
        }

        $result = json_decode($process->getOutput(), true);

        return response()->json($result);
    }
}
