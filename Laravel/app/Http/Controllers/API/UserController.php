<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;

class UserController extends Controller
{
    public function updateProfile(Request $request, $id)
    {
        $user = User::findOrFail($id);
        
        // Update data yang dikirim dari Postman
        $user->update([
            'money_cycle' => $request->money_cycle,
            'monthly_budget' => $request->monthly_budget
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Profil Budi berhasil diubah menjadi ' . $request->money_cycle,
            'data' => $user
        ]);
    }
}
