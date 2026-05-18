import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../services/stock_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final StockService _service = StockService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMsg;
  List<dynamic> _categories = []; // data dari API (grouped by kategori)
  List<dynamic> _searchResults = []; // hasil search
  bool _isSearching = false;

  // Popup masak selesai
  bool _showPopup = false;

  @override
  void initState() {
    super.initState();
    _loadStok();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStok() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final result = await _service.getStok();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _categories = result['data'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMsg = result['message'];
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    final result = await _service.searchStok(query);
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _isSearching = true;
        _searchResults = result['data'] ?? [];
      });
    }
  }

  // Icon kategori
  FaIconData _iconKategori(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'protein':
        return FontAwesomeIcons.drumstickBite;
      case 'sayur & buah':
      case 'sayur':
      case 'buah':
        return FontAwesomeIcons.carrot;
      case 'karbohidrat':
        return FontAwesomeIcons.bowlRice;
      default:
        return FontAwesomeIcons.mortarPestle;
    }
  }

  // Dialog tambah stok
  void _showTambahDialog() {
    final namaCtrl = TextEditingController();
    final jumlahCtrl = TextEditingController();
    final satuanCtrl = TextEditingController();
    String kategori = 'Protein';
    DateTime tanggalBeli = DateTime.now();
    DateTime tanggalKadaluarsa = DateTime.now().add(const Duration(days: 7));

    final daftarKategori = [
      'Protein',
      'Sayur & Buah',
      'Karbohidrat',
      'Bumbu & Lainnya'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tambah Stok Bahan',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.slate800)),
              const SizedBox(height: 20),

              // Nama bahan
              TextField(
                controller: namaCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Bahan',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Kategori dropdown
              DropdownButtonFormField<String>(
                value: kategori,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: daftarKategori
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setModalState(() => kategori = v!),
              ),
              const SizedBox(height: 12),

              // Jumlah + satuan
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: jumlahCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: satuanCtrl,
                      decoration: InputDecoration(
                        labelText: 'Satuan (gr, pcs, kg...)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tanggal beli
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                    'Tanggal Beli: ${tanggalBeli.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.slate700)),
                trailing: const Icon(Icons.calendar_today,
                    size: 18, color: AppTheme.slate500),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: tanggalBeli,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setModalState(() => tanggalBeli = picked);
                },
              ),

              // Tanggal kadaluarsa
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                    'Kadaluarsa: ${tanggalKadaluarsa.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.slate700)),
                trailing: const Icon(Icons.calendar_today,
                    size: 18, color: AppTheme.slate500),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: tanggalKadaluarsa,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null)
                    setModalState(() => tanggalKadaluarsa = picked);
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (namaCtrl.text.isEmpty ||
                        jumlahCtrl.text.isEmpty ||
                        satuanCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lengkapi semua field!')),
                      );
                      return;
                    }

                    final result = await _service.tambahStok(
                      namaBahan: namaCtrl.text,
                      kategoriBahan: kategori,
                      jumlahBahan: double.tryParse(jumlahCtrl.text) ?? 0,
                      satuanBahan: satuanCtrl.text,
                      tanggalBeli: tanggalBeli.toIso8601String().split('T')[0],
                      tanggalKadaluarsa:
                          tanggalKadaluarsa.toIso8601String().split('T')[0],
                    );

                    if (!mounted) return;
                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );

                    if (result['success'] == true) _loadStok();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.orange600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.slate50,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMsg != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 48, color: AppTheme.slate300),
                          const SizedBox(height: 12),
                          Text(_errorMsg!,
                              style: const TextStyle(color: AppTheme.slate500)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                              onPressed: _loadStok,
                              child: const Text('Coba Lagi')),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStok,
                      child: CustomScrollView(
                        slivers: [
                          // ── AppBar ───────────────────────────
                          SliverAppBar(
                            pinned: true,
                            backgroundColor: Colors.white,
                            elevation: 0,
                            expandedHeight: 120,
                            toolbarHeight: 60,
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.pin,
                              background: Padding(
                                padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).padding.top + 60,
                                  left: 24,
                                  right: 24,
                                  bottom: 12,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.slate100,
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: AppTheme.slate200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search_rounded,
                                          color: AppTheme.slate400, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          decoration: const InputDecoration(
                                            hintText: 'Cari bahan makanan...',
                                            hintStyle: TextStyle(
                                                color: AppTheme.slate400,
                                                fontWeight: FontWeight.w500),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      if (_isSearching)
                                        GestureDetector(
                                          onTap: () {
                                            _searchController.clear();
                                            setState(() {
                                              _isSearching = false;
                                              _searchResults = [];
                                            });
                                          },
                                          child: const Icon(Icons.close,
                                              color: AppTheme.slate400,
                                              size: 18),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Stok Bahan',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.slate800,
                                        letterSpacing: -0.5)),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _showPopup = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.orange50,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check_circle_outline,
                                            color: AppTheme.orange600,
                                            size: 16),
                                        SizedBox(width: 4),
                                        Text('Masak Selesai?',
                                            style: TextStyle(
                                                color: AppTheme.orange600,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            bottom: PreferredSize(
                                preferredSize: const Size.fromHeight(1),
                                child: Container(
                                    color: AppTheme.slate100, height: 1)),
                          ),

                          // ── Content ──────────────────────────
                          SliverPadding(
                            padding: const EdgeInsets.all(20),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate(
                                _isSearching
                                    ? [_buildSearchResults()]
                                    : _categories
                                        .map((cat) => _buildKategori(cat))
                                        .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showTambahDialog,
            backgroundColor: AppTheme.orange600,
            elevation: 4,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
          ),
        ),

        // Popup masak selesai
        if (_showPopup)
          _CookingDonePopup(
            categories: _categories,
            service: _service,
            onClose: () => setState(() => _showPopup = false),
            onSelesai: () {
              setState(() => _showPopup = false);
              _loadStok(); // refresh stok setelah masak
            },
          ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('Bahan tidak ditemukan',
              style: TextStyle(
                  color: AppTheme.slate400, fontWeight: FontWeight.w500)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _searchResults
          .map((item) => _StokItem(
                item: item,
                onHapus: () async {
                  final result = await _service.hapusStok(item['_id']);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(result['message'])));
                  if (result['success'] == true) _loadStok();
                },
              ))
          .toList(),
    );
  }

  Widget _buildKategori(dynamic cat) {
    final items = cat['items'] as List<dynamic>;
    final kategori = cat['kategori'] as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(_iconKategori(kategori),
                  size: 16, color: AppTheme.slate600),
              const SizedBox(width: 8),
              Text(
                kategori.toUpperCase(),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate800,
                    letterSpacing: 0.5),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: AppTheme.slate100,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${items.length}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.slate500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...items.map((item) => _InventoryChip(
                    label:
                        '${item['Nama_Bahan']} (${item['Jumlah_Bahan'].toStringAsFixed(0)} ${item['Satuan_Bahan']})',
                    onHapus: () async {
                      final result = await _service.hapusStok(item['_id']);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'])));
                      if (result['success'] == true) _loadStok();
                    },
                  )),
              _AddChip(onTap: _showTambahDialog),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stok Item (untuk hasil search) ───────────────────────────
class _StokItem extends StatelessWidget {
  final dynamic item;
  final VoidCallback onHapus;
  const _StokItem({required this.item, required this.onHapus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['Nama_Bahan'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.slate800)),
                Text(
                    '${item['Jumlah_Bahan']} ${item['Satuan_Bahan']} · ${item['Kategori_Bahan']}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.slate500)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onHapus,
            child: const Icon(Icons.delete_outline_rounded,
                color: AppTheme.slate400, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── Inventory Chip ────────────────────────────────────────────
class _InventoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onHapus;
  const _InventoryChip({required this.label, required this.onHapus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 10.2),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slate700)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onHapus,
            child: const Icon(Icons.close, size: 14, color: AppTheme.slate300),
          ),
        ],
      ),
    );
  }
}

// ── Add Chip ──────────────────────────────────────────────────
class _AddChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.slate100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.slate200),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: AppTheme.slate500),
            SizedBox(width: 4),
            Text('Tambah',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slate500)),
          ],
        ),
      ),
    );
  }
}

// ── Cooking Done Popup ────────────────────────────────────────
class _CookingDonePopup extends StatefulWidget {
  final List<dynamic> categories;
  final StockService service;
  final VoidCallback onClose;
  final VoidCallback onSelesai;

  const _CookingDonePopup({
    required this.categories,
    required this.service,
    required this.onClose,
    required this.onSelesai,
  });

  @override
  State<_CookingDonePopup> createState() => _CookingDonePopupState();
}

class _CookingDonePopupState extends State<_CookingDonePopup> {
  // Map id stok -> jumlah yang akan dikurangi
  final Map<String, double> _selectedBahan = {};
  bool _isSubmitting = false;

  List<dynamic> get _allItems {
    final List<dynamic> all = [];
    for (final cat in widget.categories) {
      all.addAll(cat['items'] as List<dynamic>);
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.black.withValues(alpha: 153)),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(28)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header popup
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppTheme.orange500,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 48),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Selamat Makan!',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5)),
                            SizedBox(width: 8),
                            FaIcon(FontAwesomeIcons.utensils,
                                color: Colors.white, size: 20),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pilih bahan yang dipakai dan jumlah yang dikurangi',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // List bahan + input jumlah
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ..._allItems.map((item) {
                            final id = item['_id'].toString();
                            final isSelected = _selectedBahan.containsKey(id);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.orange50
                                    : AppTheme.slate50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: isSelected
                                        ? AppTheme.orange200
                                        : AppTheme.slate100),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedBahan.remove(id);
                                        } else {
                                          _selectedBahan[id] = 1;
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.orange500
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: isSelected
                                                ? AppTheme.orange500
                                                : AppTheme.slate300),
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check,
                                              color: Colors.white, size: 16)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item['Nama_Bahan'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: AppTheme.slate800)),
                                        Text(
                                            'Stok: ${item['Jumlah_Bahan']} ${item['Satuan_Bahan']}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.slate500)),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    SizedBox(
                                      width: 64,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 6),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          hintText: '0',
                                        ),
                                        onChanged: (v) {
                                          setState(() {
                                            _selectedBahan[id] =
                                                double.tryParse(v) ?? 0;
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 16),

                          // Tombol kurangi stok
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting || _selectedBahan.isEmpty
                                  ? null
                                  : () async {
                                      setState(() => _isSubmitting = true);

                                      final bahan = _selectedBahan.entries
                                          .map((e) =>
                                              {'id': e.key, 'jumlah': e.value})
                                          .toList();

                                      final result = await widget.service
                                          .masakSelesai(bahan);

                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(result['message'])),
                                      );

                                      if (result['success'] == true) {
                                        widget.onSelesai();
                                      } else {
                                        setState(() => _isSubmitting = false);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.orange600,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Ya, Kurangi Stok',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: widget.onClose,
                            child: const Text('Batal',
                                style: TextStyle(
                                    color: AppTheme.slate400,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
