<?php

namespace App\Http\Controllers;

use App\Models\UserFlutter; // <--- Pastikan pakai model ini
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index()
    {
        // Mengambil data dari collection yang digunakan UserFlutter (MongoDB)
        $users = UserFlutter::all(); 
        
        return view('manajemen_users', compact('users'));
    }

    public function destroy($id)
    {
        // Cari user berdasarkan ID di model UserFlutter lalu hapus
        $user = UserFlutter::findOrFail($id);
        $user->delete();

        return back()->with('status', 'User Flutter berhasil dihapus secara permanen!');
    }
}