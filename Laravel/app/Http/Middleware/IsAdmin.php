<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Auth;

class IsAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        // Cek apakah dia udah login DAN role-nya adalah 'admin'
        if (Auth::check() && Auth::user()->role === 'admin') {
            return $next($request); // Boleh lewat
        }

        // Kalau bukan admin, tendang ke halaman home/dashboard
        abort(403, 'Maaf, Anda tidak memiliki akses ke halaman ini.');
    }
}