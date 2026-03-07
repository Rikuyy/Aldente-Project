@extends('layouts.app')

@section('title', 'Login')

@section('content')

<div class="auth-container">
    <h1>Masuk</h1>

    {{-- Error validasi global --}}
    @if ($errors->any())
        <div class="alert alert-error">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form method="POST" action="{{ route('login') }}" novalidate>
        @csrf

        {{-- Email --}}
        <div class="form-group">
            <label for="email">Email</label>
            <input
                type="email"
                id="email"
                name="email"
                value="{{ old('email') }}"
                autocomplete="email"
                autofocus
                class="{{ $errors->has('email') ? 'is-invalid' : '' }}"
                required
            />
            @error('email')
                <span class="invalid-feedback">{{ $message }}</span>
            @enderror
        </div>

        {{-- Password --}}
        <div class="form-group">
            <label for="password">Password</label>
            <input
                type="password"
                id="password"
                name="password"
                autocomplete="current-password"
                class="{{ $errors->has('password') ? 'is-invalid' : '' }}"
                required
            />
            @error('password')
                <span class="invalid-feedback">{{ $message }}</span>
            @enderror
        </div>

        {{-- Remember Me --}}
        <div class="form-group form-check">
            <input
                type="checkbox"
                id="remember"
                name="remember"
                {{ old('remember') ? 'checked' : '' }}
            />
            <label for="remember">Ingat saya</label>
        </div>

        {{-- Submit --}}
        <button type="submit">Masuk</button>

        {{-- Link ke Register --}}
        <p>Belum punya akun? <a href="{{ route('register') }}">Daftar sekarang</a></p>
    </form>
</div>

@endsection
