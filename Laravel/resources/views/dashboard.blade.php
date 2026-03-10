<x-app-layout>
    <x-slot name="header">
        <span class="font-extrabold text-3xl text-gray-900">
            {{ __('Analytics') }}
        </span>
    </x-slot>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        
        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-100 flex items-center gap-5 hover:shadow-md transition">
            <div class="w-16 h-16 rounded-2xl bg-pink-100 text-[#E91E63] flex items-center justify-center text-3xl shadow-inner">
                💰
            </div>
            <div>
                <p class="text-sm font-bold text-gray-400 uppercase tracking-wider">Total Revenue</p>
                <p class="text-2xl font-extrabold text-gray-800">$872,335</p>
            </div>
        </div>

        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-100 flex items-center gap-5 hover:shadow-md transition">
            <div class="w-16 h-16 rounded-2xl bg-pink-100 text-[#E91E63] flex items-center justify-center text-3xl shadow-inner">
                📦
            </div>
            <div>
                <p class="text-sm font-bold text-gray-400 uppercase tracking-wider">Total Orders</p>
                <p class="text-2xl font-extrabold text-gray-800">63,876</p>
            </div>
        </div>

        <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-100 flex items-center gap-5 hover:shadow-md transition">
            <div class="w-16 h-16 rounded-2xl bg-pink-100 text-[#E91E63] flex items-center justify-center text-3xl shadow-inner">
                👥
            </div>
            <div>
                <p class="text-sm font-bold text-gray-400 uppercase tracking-wider">Customers</p>
                <p class="text-2xl font-extrabold text-gray-800">1,245</p>
            </div>
        </div>

    </div>

    <div class="bg-white rounded-3xl shadow-sm border border-gray-100 p-8">
        <div class="flex justify-between items-center mb-6">
            <h3 class="text-xl font-extrabold text-gray-800">Most Favorites Items</h3>
            <button class="px-5 py-2 bg-gray-100 text-gray-600 rounded-full text-sm font-bold hover:bg-[#E91E63] hover:text-white transition">
                View All
            </button>
        </div>
        
        <div class="space-y-4">
            
            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-2xl hover:bg-pink-50 transition cursor-pointer">
                <div class="flex items-center gap-4">
                    <div class="w-14 h-14 bg-white rounded-xl shadow-sm flex items-center justify-center text-2xl border border-gray-100">
                        🍕
                    </div>
                    <div>
                        <h4 class="font-bold text-gray-800 text-lg">Medium Spicy Pizza</h4>
                        <p class="text-sm text-gray-400 font-semibold">❤️ 256k Liked</p>
                    </div>
                </div>
                <div class="text-right">
                    <p class="font-extrabold text-gray-800 text-lg">45%</p>
                    <p class="text-xs font-bold text-gray-400 uppercase">Interest</p>
                </div>
            </div>

            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-2xl hover:bg-pink-50 transition cursor-pointer">
                <div class="flex items-center gap-4">
                    <div class="w-14 h-14 bg-white rounded-xl shadow-sm flex items-center justify-center text-2xl border border-gray-100">
                        🍉
                    </div>
                    <div>
                        <h4 class="font-bold text-gray-800 text-lg">Watermelon Juice with Ice</h4>
                        <p class="text-sm text-gray-400 font-semibold">❤️ 189k Liked</p>
                    </div>
                </div>
                <div class="text-right">
                    <p class="font-extrabold text-gray-800 text-lg">26%</p>
                    <p class="text-xs font-bold text-gray-400 uppercase">Interest</p>
                </div>
            </div>

        </div>
    </div>
</x-app-layout>