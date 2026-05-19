<x-app-layout>
    <div class="py-10">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            @if (session('success'))
                <div class="mb-6 px-4 py-3 bg-green-500/10 border border-green-500/30 text-green-400 rounded-xl flex items-center gap-3">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                    {{ session('success') }}
                </div>
            @endif

            @if ($errors->any())
                <div class="mb-6 px-4 py-3 bg-red-500/10 border border-red-500/30 text-red-400 rounded-xl flex flex-col gap-1">
                    @foreach ($errors->all() as $error)
                        <span class="text-sm">• {{ $error }}</span>
                    @endforeach
                </div>
            @endif

            <div class="flex flex-col md:flex-row justify-between items-start md:items-end mb-6 gap-4">
                <div>
                    <h2 class="text-2xl font-bold text-white tracking-wide">
                        Manajemen Database User
                    </h2>
                    <p class="text-sm text-neutral-400 mt-1">
                        Kelola daftar anak kos lengkap dengan nama, email, dan tanggal bergabung.
                    </p>
                </div>

                <div class="flex items-center gap-4 w-full md:w-auto">
                    <div class="relative w-full md:w-64">
                        <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                            <svg class="w-4 h-4 text-neutral-500" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 20 20">
                                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"/>
                            </svg>
                        </div>
                        <input type="text" class="bg-[#18181A] border border-neutral-800 text-neutral-200 text-sm rounded-lg focus:ring-[#FF723A] focus:border-[#FF723A] block w-full pl-10 p-2.5 placeholder-neutral-500 transition-colors" placeholder="Cari nama user...">
                    </div>

                    <button type="button" onclick="openCreateModal()" class="flex items-center gap-2 px-5 py-2.5 bg-[#FF723A] text-white text-sm rounded-lg font-bold hover:bg-orange-500 transition-all whitespace-nowrap shadow-[0_0_15px_rgba(255,114,58,0.2)] hover:shadow-[0_0_20px_rgba(255,114,58,0.4)]">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M12 4v16m8-8H4"></path></svg>
                        Tambah Anak Kos
                    </button>
                </div>
            </div>

            <div class="bg-[#1E1E1E] border border-neutral-800 rounded-2xl overflow-hidden shadow-lg relative z-10">
                <div class="overflow-x-auto">
                    <table class="w-full text-sm text-left text-neutral-400">
                        <thead class="text-xs text-neutral-400 border-b border-neutral-800 bg-[#1E1E1E]">
                            <tr>
                                <th scope="col" class="px-6 py-5 font-medium tracking-wider">Nama Lengkap</th>
                                <th scope="col" class="px-6 py-5 font-medium tracking-wider">Email</th>
                                <th scope="col" class="px-6 py-5 font-medium tracking-wider">Tanggal Daftar</th>
                                <th scope="col" class="px-6 py-5 font-medium tracking-wider text-right">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-neutral-800">
                            @forelse ($users as $user)
                            <tr class="bg-[#1E1E1E] hover:bg-neutral-800/40 transition-colors duration-200">
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="font-semibold text-neutral-200">{{ $user->name }}</div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    {{ $user->email }}
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    {{ $user->created_at->format('d M Y') }}
                                </td>
                                
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <div class="flex justify-end items-center gap-2">
                                        
                                        <a href="#" class="p-2 bg-[#27272A] hover:bg-[#3F3F46] rounded-lg border border-neutral-700/50 text-neutral-400 hover:text-white transition-colors" title="Lihat Detail">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                                        </a>
                                        
                                        <button type="button" 
                                                data-id="{{ $user->id }}" 
                                                data-name="{{ $user->name }}" 
                                                data-email="{{ $user->email }}"
                                                onclick="openEditModal(this.dataset.id, this.dataset.name, this.dataset.email)" 
                                                class="p-2 bg-[#27272A] hover:bg-[#3F3F46] rounded-lg border border-neutral-700/50 text-neutral-400 hover:text-white transition-colors" 
                                                title="Edit Data">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path></svg>
                                        </button>
                                        
                                        <form action="{{ route('users.destroy', $user->id) }}" method="POST" onsubmit="return confirm('Yakin mau menghapus user ini?');" class="m-0 p-0 flex">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="p-2 bg-[#27272A] hover:bg-red-500/20 hover:border-red-500/50 rounded-lg border border-neutral-700/50 text-neutral-400 hover:text-red-500 transition-colors" title="Hapus Data">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                            </button>
                                        </form>
                                        
                                    </div>
                                </td>
                                
                            </tr>
                            @empty
                            <tr>
                                <td colspan="4" class="px-6 py-12 text-center text-neutral-500">
                                    Belum ada data anak kos yang terdaftar.
                                </td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
                
                @if ($users->hasPages())
                <div class="px-6 py-4 border-t border-neutral-800 bg-[#1E1E1E]">
                    {{ $users->links() }}
                </div>
                @endif
            </div>

        </div>
    </div>

    <div id="createModal" class="fixed inset-0 z-50 hidden" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="fixed inset-0 bg-black/60 backdrop-blur-sm transition-opacity"></div>
        <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
            <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
                <div class="relative transform overflow-hidden rounded-2xl bg-[#1E1E1E] border border-neutral-800 text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-lg">
                    
                    <button type="button" onclick="closeCreateModal()" class="absolute top-4 right-4 text-neutral-400 hover:text-white transition-colors">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                    </button>

                    <div class="px-8 py-6">
                        <h3 class="text-xl font-bold text-white mb-6">Tambah Anak Kos Baru</h3>
                        
                        <form method="POST" action="{{ route('users.store') }}" class="space-y-4">
                            @csrf
                            
                            <div>
                                <label for="name" class="block text-sm font-medium text-neutral-400 mb-1.5">Nama Lengkap</label>
                                <input type="text" id="name" name="name" required placeholder="Masukkan nama..." class="bg-[#18181A] border border-neutral-800 text-neutral-200 text-sm rounded-lg focus:ring-[#FF723A] focus:border-[#FF723A] block w-full p-2.5 transition-colors">
                            </div>

                            <div>
                                <label for="email" class="block text-sm font-medium text-neutral-400 mb-1.5">Alamat Email</label>
                                <input type="email" id="email" name="email" required placeholder="email@contoh.com" class="bg-[#18181A] border border-neutral-800 text-neutral-200 text-sm rounded-lg focus:ring-[#FF723A] focus:border-[#FF723A] block w-full p-2.5 transition-colors">
                            </div>

                            <div>
                                <label for="password" class="block text-sm font-medium text-neutral-400 mb-1.5">Password</label>
                                <input type="password" id="password" name="password" required placeholder="Minimal 8 karakter..." class="bg-[#18181A] border border-neutral-800 text-neutral-200 text-sm rounded-lg focus:ring-[#FF723A] focus:border-[#FF723A] block w-full p-2.5 transition-colors">
                            </div>

                            <div>
                                <label for="password_confirmation" class="block text-sm font-medium text-neutral-400 mb-1.5">Konfirmasi Password</label>
                                <input type="password" id="password_confirmation" name="password_confirmation" required placeholder="Ketik ulang password..." class="bg-[#18181A] border border-neutral-800 text-neutral-200 text-sm rounded-lg focus:ring-[#FF723A] focus:border-[#FF723A] block w-full p-2.5 transition-colors">
                            </div>

                            <div class="flex items-center justify-end gap-3 pt-4 mt-2 border-t border-neutral-800/50">
                                <button type="button" onclick="closeCreateModal()" class="px-5 py-2.5 text-sm font-medium text-neutral-400 hover:text-white transition-colors">
                                    Batal
                                </button>
                                <button type="submit" class="px-5 py-2.5 bg-[#FF723A] text-white text-sm rounded-lg font-bold hover:bg-orange-500 transition-all shadow-[0_0_15px_rgba(255,114,58,0.2)]">
                                    Simpan Data
                                </button>
                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <div id="editModal" class="fixed inset-0 z-50 hidden" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="fixed inset-0 bg-black/60 backdrop-blur-sm transition-opacity"></div>
        <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
            <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
                <div class="relative transform overflow-hidden rounded-2xl bg-[#1E1E1E] border border-neutral-800 text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-lg">
                    
                    <button type="button" onclick="closeEditModal()" class="absolute top-4 right-4 text-neutral-400 hover:text-white transition-colors">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                    </button>

                    <div class="px-8 py-6">
                        <h3 class="text-xl font-bold text-white mb-6" id="modal-title">Edit Data Anak Kos</h3>
                        
                        <form id="editForm" method="POST" action="" class="space-y-4">
                            @csrf
                            @method('PUT')
                            
                            <div>
                                <label for="edit_name" class="block text-sm font-medium text-neutral-400 mb-1.5">Nama Lengkap</label>
                                <input type="text" id="edit_name" name="name" required class="bg-[#18181A] border border-neutral-800 text-neutral-200 text-sm rounded-lg focus:ring-[#FF723A] focus:border-[#FF723A] block w-full p-2.5 transition-colors">
                            </div>

                            <div>
                                <label for="edit_email" class="block text-sm font-medium text-neutral-400 mb-1.5">Alamat Email</label>
                                <input type="email" id="edit_email" name="email" required class="bg-[#18181A] border border-neutral-800 text-neutral-200 text-sm rounded-lg focus:ring-[#FF723A] focus:border-[#FF723A] block w-full p-2.5 transition-colors">
                            </div>

                            <div class="pt-4 border-t border-neutral-800/50">
                                <label for="edit_password" class="block text-sm font-medium text-neutral-400 mb-1.5">Password Baru <span class="text-neutral-500 text-xs font-normal">(Isi jika ingin diganti)</span></label>
                                <input type="password" id="edit_password" name="password" placeholder="Kosongkan jika tidak ada perubahan..." class="bg-[#18181A] border border-neutral-800 text-neutral-200 text-sm rounded-lg focus:ring-[#FF723A] focus:border-[#FF723A] block w-full p-2.5 transition-colors placeholder-neutral-600">
                            </div>

                            <div class="flex items-center justify-end gap-3 pt-4 mt-2">
                                <button type="button" onclick="closeEditModal()" class="px-5 py-2.5 text-sm font-medium text-neutral-400 hover:text-white transition-colors">
                                    Batal
                                </button>
                                <button type="submit" class="px-5 py-2.5 bg-[#FF723A] text-white text-sm rounded-lg font-bold hover:bg-orange-500 transition-all shadow-[0_0_15px_rgba(255,114,58,0.2)]">
                                    Update Data
                                </button>
                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <script>
        // --- MODAL TAMBAH DATA ---
        function openCreateModal() {
            document.getElementById('createModal').classList.remove('hidden');
        }

        function closeCreateModal() {
            document.getElementById('createModal').classList.add('hidden');
        }

        // --- MODAL EDIT DATA ---
        function openEditModal(id, name, email) {
            const baseUrl = "{{ url('users') }}";
            document.getElementById('editForm').action = `${baseUrl}/${id}`;
            
            document.getElementById('edit_name').value = name;
            document.getElementById('edit_email').value = email;
            document.getElementById('edit_password').value = ''; 
            
            document.getElementById('editModal').classList.remove('hidden');
        }

        function closeEditModal() {
            document.getElementById('editModal').classList.add('hidden');
        }
    </script>
</x-app-layout>