<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Providers\RouteServiceProvider;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class ConfirmablePasswordController extends Controller
{
    /**
     * Show the confirm password view.
     */
    public function show(): View
    {
        return view('auth.confirm-password');
    }

    /**
     * Confirm the user's password.
     */
   public function store(Request $request): RedirectResponse
{
    // Ganti 'email' menjadi 'Email' sesuai field di model Admin
    if (! Auth::guard('web')->validate([
        'Email' => $request->user()->Email, // Pakai 'Email' kapital
        'password' => $request->password,   // Tetap 'password' karena Laravel otomatis lari ke getAuthPassword()
    ])) {
        throw ValidationException::withMessages([
            'password' => __('auth.password'),
        ]);
    }

    $request->session()->put('auth.password_confirmed_at', time());

    return redirect()->intended(RouteServiceProvider::HOME);
}
}
