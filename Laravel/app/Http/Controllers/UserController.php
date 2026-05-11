<?php

namespace App\Http\Controllers;

use App\Models\User; // <--- Sudah diganti jadi User
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index()
    {
        // Mengambil data dari collection yang digunakan User (MongoDB)
        $users = User::all(); // <--- Sudah diganti jadi User
        
        return view('manajemen_users', compact('users'));
    }

    public function destroy($id)
    {
        // Cari user berdasarkan ID di model User lalu hapus
        $user = User::findOrFail($id); // <--- Sudah diganti jadi User
        $user->delete();

        return back()->with('status', 'User berhasil dihapus secara permanen!');
    }
}