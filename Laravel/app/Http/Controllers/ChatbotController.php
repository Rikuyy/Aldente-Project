<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Symfony\Component\Process\Process;
use Illuminate\Support\Facades\Log;

class ChatbotController extends Controller
{
    /**
     * Mendapatkan path absolut ke script Python
     * Prioritas: folder API eksternal -> app/Python -> root Laravel
     */
    protected function getPythonScriptPath($scriptName)
    {
        // 1. Folder API di luar Laravel (sesuai struktur Anda)
        $externalPath = 'C:/laragon/www/Projeksmt4/API/' . $scriptName;
        if (file_exists($externalPath)) {
            return $externalPath;
        }
        // 2. Folder app/Python di dalam Laravel (alternatif)
        $internalPath = base_path('app/Python/' . $scriptName);
        if (file_exists($internalPath)) {
            return $internalPath;
        }
        // 3. Root Laravel (opsi lama)
        return base_path($scriptName);
    }

    /**
     * Endpoint untuk mendapatkan rekomendasi resep berdasarkan query dan alergi user
     */
    public function rekomendasi(Request $request)
    {
        $query = $request->input('query');
        $user = auth()->user();
        $alergi = $user->riwayat_alergi ?? '';

        $pythonExe = env('PYTHON_EXE', 'python');
        $scriptPath = $this->getPythonScriptPath('rekomendasi.py');

        if (!file_exists($scriptPath)) {
            Log::error('Script rekomendasi.py tidak ditemukan di: ' . $scriptPath);
            return response()->json([
                'status' => 'error',
                'message' => 'Script rekomendasi.py tidak ditemukan'
            ], 500);
        }

        // 🔧 KRUSIAL: set working directory ke folder script
        $process = new Process([$pythonExe, $scriptPath, $query, $alergi]);
        $process->setWorkingDirectory(dirname($scriptPath));

        $process->setEnv([
            'PYTHONIOENCODING' => 'utf-8',
            'PYTHONUTF8' => '1',
            'SYSTEMROOT' => getenv('SYSTEMROOT') ?: 'C:\\Windows',
            'PATH' => getenv('PATH')
        ]);

        $process->run();

        if (!$process->isSuccessful()) {
            Log::error('Rekomendasi AI gagal: ' . $process->getErrorOutput());
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

    /**
     * Endpoint untuk memperbarui model AI (melatih ulang dengan data terbaru dari MongoDB)
     */
    public function updateModel()
    {
        $pythonExe = env('PYTHON_EXE', 'python');
        $scriptPath = $this->getPythonScriptPath('update_model.py');

        if (!file_exists($scriptPath)) {
            Log::error('Script update_model.py tidak ditemukan di: ' . $scriptPath);
            return response()->json([
                'status' => 'error',
                'message' => 'Script update_model.py tidak ditemukan'
            ], 500);
        }

        // 🔧 set working directory
        $process = new Process([$pythonExe, $scriptPath]);
        $process->setWorkingDirectory(dirname($scriptPath));

        $process->setEnv([
            'PYTHONIOENCODING' => 'utf-8',
            'PYTHONUTF8' => '1',
            'SYSTEMROOT' => getenv('SYSTEMROOT') ?: 'C:\\Windows',
            'PATH' => getenv('PATH')
        ]);

        $process->setTimeout(180); // 3 menit
        $process->run();

        if (!$process->isSuccessful()) {
            Log::error('Update model gagal: ' . $process->getErrorOutput());
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

    /**
     * Endpoint untuk mengevaluasi model (Precision@K, Recall@K)
     */
    public function evaluasi()
    {
        $pythonExe = env('PYTHON_EXE', 'python');
        $scriptPath = $this->getPythonScriptPath('evaluasi_model.py');

        if (!file_exists($scriptPath)) {
            Log::error('Script evaluasi_model.py tidak ditemukan di: ' . $scriptPath);
            return response()->json([
                'status' => 'error',
                'message' => 'Script evaluasi_model.py tidak ditemukan'
            ], 500);
        }

        // 🔧 set working directory
        $process = new Process([$pythonExe, $scriptPath]);
        $process->setWorkingDirectory(dirname($scriptPath));

        $process->setEnv([
            'PYTHONIOENCODING' => 'utf-8',
            'PYTHONUTF8' => '1',
            'SYSTEMROOT' => getenv('SYSTEMROOT') ?: 'C:\\Windows',
            'PATH' => getenv('PATH')
        ]);

        $process->run();

        if (!$process->isSuccessful()) {
            Log::error('Evaluasi model gagal: ' . $process->getErrorOutput());
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