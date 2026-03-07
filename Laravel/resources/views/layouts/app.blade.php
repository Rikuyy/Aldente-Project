<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="csrf-token" content="{{ csrf_token() }}" />
    <title>@yield('title', config('app.name'))</title>

    {{-- Ganti bagian ini dengan asset bundler kamu (Vite / Mix) --}}
    @yield('styles')
</head>
<body>
    {{-- Flash Messages --}}
    @if (session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif

    @if (session('error'))
        <div class="alert alert-error">
            {{ session('error') }}
        </div>
    @endif

    {{-- Konten Halaman --}}
    @yield('content')

    @yield('scripts')
</body>
</html>