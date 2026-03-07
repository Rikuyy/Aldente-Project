@extends('layouts.app')

@section('title', 'Daftar')

@section('content')

<div class="auth-container">
    <h1>Buat Akun</h1>

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

    <form method="POST" action="{{ route('register') }}" novalidate>
        @csrf

        {{-- Nama --}}
        <div class="form-group">
            <label for="name">Nama Lengkap</label>
            <input
                type="text"
                id="name"
                name="name"
                value="{{ old('name') }}"
                autocomplete="name"
                autofocus
                class="{{ $errors->has('name') ? 'is-invalid' : '' }}"
                required
            />
            @error('name')
                <span class="invalid-feedback">{{ $message }}</span>
            @enderror
        </div>

        {{-- Email --}}
        <div class="form-group">
            <label for="email">Email</label>
            <input
                type="email"
                id="email"
                name="email"
                value="{{ old('email') }}"
                autocomplete="email"
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
                autocomplete="new-password"
                class="{{ $errors->has('password') ? 'is-invalid' : '' }}"
                required
            />
            <small>Minimal 8 karakter, mengandung huruf dan angka.</small>
            @error('password')
                <span class="invalid-feedback">{{ $message }}</span>
            @enderror
        </div>

        {{-- Konfirmasi Password --}}
        <div class="form-group">
            <label for="password_confirmation">Konfirmasi Password</label>
            <input
                type="password"
                id="password_confirmation"
                name="password_confirmation"
                autocomplete="new-password"
                required
            />
        </div>

        {{-- Submit --}}
        <button type="submit">Daftar</button>

        {{-- Link ke Login --}}
        <p>Sudah punya akun? <a href="{{ route('login') }}">Masuk di sini</a></p>
    </form>
</div>

@endsection
