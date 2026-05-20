<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;

class EvaluasiController extends Controller
{
    public function evaluate()
    {
        try {
            // Path ke script Python
            $pythonScript = base_path('app/Python/evaluasi_model.py');
            
            // Deteksi OS untuk menentukan command Python
            $pythonCmd = PHP_OS_FAMILY === 'Windows' ? 'python' : 'python3';
            
            // Setup process
            $process = new Process([
                $pythonCmd,
                $pythonScript
            ]);
            
            // Set working directory ke folder script
            $process->setWorkingDirectory(dirname($pythonScript));
            
            // Set environment variables untuk encoding
            $process->setEnv([
                'PYTHONIOENCODING' => 'utf-8',
                'PYTHONUTF8' => '1',
                'LC_ALL' => 'C.UTF-8',
                'LANG' => 'C.UTF-8',
            ]);
            
            // Set timeout 5 menit
            $process->setTimeout(300);
            
            // Jalankan process
            $process->run();
            
            // Ambil output dan error
            $output = $process->getOutput();
            $errorOutput = $process->getErrorOutput();
            
            // Log error untuk debugging
            if (!empty($errorOutput)) {
                \Log::warning('Python Error Output: ' . $errorOutput);
            }
            
            // Jika process gagal
            if (!$process->isSuccessful()) {
                throw new ProcessFailedException($process);
            }
            
            // Bersihkan output (ambil JSON saja)
            $output = trim($output);
            
            // Coba decode JSON
            $result = json_decode($output, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                \Log::error('JSON Decode Error: ' . json_last_error_msg());
                \Log::error('Raw Output: ' . substr($output, 0, 1000));
                
                return response()->json([
                    'status' => 'error',
                    'message' => 'Gagal parsing hasil evaluasi. Error: ' . json_last_error_msg()
                ], 500);
            }
            
            return response()->json($result);
            
        } catch (ProcessFailedException $e) {
            \Log::error('Process Failed: ' . $e->getMessage());
            \Log::error('Error Output: ' . $process->getErrorOutput());
            
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menjalankan evaluasi: ' . $e->getMessage()
            ], 500);
        } catch (\Exception $e) {
            \Log::error('Exception: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}