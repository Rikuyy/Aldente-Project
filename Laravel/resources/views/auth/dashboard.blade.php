@extends('layouts.app')

@section('title', 'Dashboard')

@section('content')

<div class="dashboard-container">
    <h1>Dashboard</h1>
    <p>Halo, <strong>{{ Auth::user()->name }}</strong>! Kamu berhasil login.</p>

    <form method="POST" action="{{ route('logout') }}">
        @csrf
        <button type="submit">Logout</button>
    </form>
</div>

@endsection
