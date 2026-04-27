<button {{ $attributes->merge(['type' => 'submit', 'class' => 'flex items-center justify-center w-full px-8 py-4 bg-[#FF723A] hover:bg-[#ff8c5a] text-white rounded-full text-lg font-bold tracking-wide transition-all duration-300 shadow-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-neutral-900 focus:ring-[#FF723A] active:scale-[0.98]']) }}>
    {{ $slot }}
</button>