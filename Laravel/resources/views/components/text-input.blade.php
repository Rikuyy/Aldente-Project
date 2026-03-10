@props(['disabled' => false])

<input {{ $disabled ? 'disabled' : '' }} {!! $attributes->merge(['class' => 'border-gray-200 focus:border-[#E91E63] focus:ring-[#E91E63] rounded-xl shadow-sm w-full py-3 px-4 transition duration-150']) !!}>