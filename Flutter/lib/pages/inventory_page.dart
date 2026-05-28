import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/stok_model.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<StokModel> _stocks = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<String> _dismissedWarnings = {};
  String? _filterType;
  String _sortBy = 'nama';

  @override
  void initState() {
    super.initState();
    _loadDismissedWarnings();
    _fetchStocks().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyFilterFromExtra();
      });
    });
  }

  void _applyFilterFromExtra() {
    final extra = GoRouterState.of(context).extra;
    String? filter;
    if (extra is String) {
      filter = extra;
    } else if (extra is Map) {
      filter = extra['filter'] as String?;
    }
    if (filter != null && (filter == 'segar' || filter == 'kemasan')) {
      if (_filterType != filter) {
        setState(() {
          _filterType = filter;
          _searchQuery = '';
          _searchCtrl.clear();
        });
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDismissedWarnings() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('dismissed_warnings') ?? [];
    setState(() {
      _dismissedWarnings = saved.toSet();
    });
  }

  Future<void> _saveDismissedWarnings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'dismissed_warnings', _dismissedWarnings.toList());
  }

  void _dismissWarning(String key) {
    setState(() {
      _dismissedWarnings.add(key);
    });
    _saveDismissedWarnings();
  }

  Future<void> _fetchStocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final response = await ApiService.get('/inventory');
    if (response['success'] == true) {
      final List<dynamic> data = response['data'];
      List<StokModel> allStocks = [];
      for (var group in data) {
        final bahanList = group['bahan'] as List;
        for (var item in bahanList) {
          allStocks.add(StokModel.fromJson(item));
        }
      }
      setState(() {
        _stocks = allStocks;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response['message'] ?? 'Gagal mengambil data';
        _isLoading = false;
      });
    }
  }

  List<StokModel> get _filteredAndSortedStocks {
    List<StokModel> filtered = _stocks;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((s) =>
              s.namaBahan.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_filterType != null) {
      filtered = filtered.where((s) => s.tipeBahan == _filterType).toList();
    }
    switch (_sortBy) {
      case 'nama':
        filtered.sort((a, b) => a.namaBahan.compareTo(b.namaBahan));
        break;
      case 'jumlah':
        filtered.sort((a, b) => a.jumlahBahan.compareTo(b.jumlahBahan));
        break;
      case 'kadaluarsa':
        filtered.sort((a, b) {
          final aDate = a.tanggalKadaluarsa ?? DateTime(3000);
          final bDate = b.tanggalKadaluarsa ?? DateTime(3000);
          return aDate.compareTo(bDate);
        });
        break;
    }
    return filtered;
  }

  List<_WarningItem> get _activeWarnings {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<_WarningItem> warnings = [];
    for (var stock in _stocks) {
      final key = 'warning_${stock.id}';
      if (_dismissedWarnings.contains(key)) continue;

      if (stock.tipeBahan == 'segar' && stock.tanggalBeli != null) {
        final beliDate = DateTime(stock.tanggalBeli!.year,
            stock.tanggalBeli!.month, stock.tanggalBeli!.day);
        final days = today.difference(beliDate).inDays;
        if (days >= 7) {
          warnings.add(_WarningItem(
            stock: stock,
            message: 'Sudah $days hari sejak beli',
            detail: 'Dibeli: ${_formatDate(stock.tanggalBeli!)} · Segera olah!',
            type: WarningType.warning,
            dismissKey: key,
          ));
        }
      } else if (stock.tipeBahan == 'kemasan' &&
          stock.tanggalKadaluarsa != null) {
        final expiredDate = DateTime(stock.tanggalKadaluarsa!.year,
            stock.tanggalKadaluarsa!.month, stock.tanggalKadaluarsa!.day);
        final daysLeft = expiredDate.difference(today).inDays;
        if (daysLeft < 0) {
          warnings.add(_WarningItem(
            stock: stock,
            message: 'Sudah kadaluarsa!',
            detail: 'Kadaluarsa: ${_formatDate(stock.tanggalKadaluarsa!)}',
            type: WarningType.error,
            dismissKey: key,
          ));
        } else if (daysLeft <= 7) {
          warnings.add(_WarningItem(
            stock: stock,
            message: 'Akan kadaluarsa dalam $daysLeft hari',
            detail: 'Kadaluarsa: ${_formatDate(stock.tanggalKadaluarsa!)}',
            type: WarningType.warning,
            dismissKey: key,
          ));
        }
      }
    }
    return warnings;
  }

  void _showForm({StokModel? existingStock, String? defaultTipe}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StockFormSheet(
        existingStock: existingStock,
        initialTipe: defaultTipe,
        onSubmit: () => _fetchStocks(),
      ),
    );
  }

  Future<void> _adjustStock(StokModel stock, double delta) async {
    final newJumlah = stock.jumlahBahan + delta;
    if (newJumlah < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok tidak boleh kurang dari 0')),
      );
      return;
    }
    if (delta < 0 && newJumlah == 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Konfirmasi Stok Habis'),
          content: Text('${stock.namaBahan} telah habis. Hapus dari daftar?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus',
                    style: TextStyle(color: AppTheme.red500))),
          ],
        ),
      );
      if (confirmed == true) {
        await _deleteStock(stock, showConfirm: false, showSnackbar: true);
      }
      return;
    }
    final response = await ApiService.put(
        '/inventory/${stock.id}', {'Jumlah_Bahan': newJumlah});
    if (response['success'] == true) {
      await _fetchStocks();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stok ${stock.namaBahan} diperbarui')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${response['message']}')));
    }
  }

  Future<void> _deleteStock(StokModel stock,
      {bool showConfirm = true, bool showSnackbar = true}) async {
    if (showConfirm) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus Bahan'),
          content:
              Text('Yakin ingin menghapus ${stock.namaBahan} dari daftar?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus',
                    style: TextStyle(color: AppTheme.red500))),
          ],
        ),
      );
      if (confirm != true) return;
    }
    final response = await ApiService.delete('/inventory/${stock.id}');
    if (response['success'] == true) {
      await _fetchStocks();
      if (showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${stock.namaBahan} dihapus')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus: ${response['message']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Stok Bahan',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.3)),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => _showSearchDialog()),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'nama', child: Text('Urutkan Nama')),
              const PopupMenuItem(
                  value: 'jumlah', child: Text('Urutkan Jumlah Stok')),
              const PopupMenuItem(
                  value: 'kadaluarsa',
                  child: Text('Urutkan Kadaluarsa Terdekat')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_activeWarnings.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Column(
                  children: _activeWarnings
                      .map((w) => _WarningTile(
                          warning: w,
                          onDismiss: () => _dismissWarning(w.dismissKey)))
                      .toList()),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                        'Semua',
                        _filterType == null,
                        () => setState(() {
                              _filterType = null;
                              _searchQuery = '';
                              _searchCtrl.clear();
                            })),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        'Segar',
                        _filterType == 'segar',
                        () => setState(() {
                              _filterType = 'segar';
                              _searchQuery = '';
                              _searchCtrl.clear();
                            })),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        'Kemasan',
                        _filterType == 'kemasan',
                        () => setState(() {
                              _filterType = 'kemasan';
                              _searchQuery = '';
                              _searchCtrl.clear();
                            })),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.sort, size: 14, color: colors.textHint),
                const SizedBox(width: 4),
                Text(
                    'Urutan: ${_sortBy == 'nama' ? 'Nama' : (_sortBy == 'jumlah' ? 'Stok' : 'Kadaluarsa')}',
                    style: TextStyle(fontSize: 12, color: colors.textHint)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : _filteredAndSortedStocks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_rounded,
                                    size: 64, color: colors.textHint),
                                const SizedBox(height: 16),
                                Text('Tidak ada bahan',
                                    style: TextStyle(color: colors.textHint)),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                    onPressed: () =>
                                        _showForm(defaultTipe: _filterType),
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('Tambah bahan')),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchStocks,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredAndSortedStocks.length,
                              itemBuilder: (ctx, i) => _StockCard(
                                stock: _filteredAndSortedStocks[i],
                                onIncrease: () => _adjustStock(
                                    _filteredAndSortedStocks[i], 1),
                                onDecrease: () => _adjustStock(
                                    _filteredAndSortedStocks[i], -1),
                                onEdit: () => _showForm(
                                    existingStock: _filteredAndSortedStocks[i]),
                                onDelete: () =>
                                    _deleteStock(_filteredAndSortedStocks[i]),
                              ),
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(defaultTipe: _filterType),
          backgroundColor: AppTheme.orange600,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded)),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.orange500,
      checkmarkColor: selected ? Colors.white : Colors.transparent,
      side: BorderSide(
          color: selected ? AppTheme.orange500 : AppTheme.orange300,
          width: 1.2),
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.orange700,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  void _showSearchDialog() {
    final localController = TextEditingController(text: _searchQuery);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cari Bahan'),
        content: TextField(
          controller: localController,
          autofocus: true,
          decoration: InputDecoration(
              hintText: 'Masukkan nama bahan...',
              border: OutlineInputBorder(),
              suffixIcon: localController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        localController.clear();
                        setState(() {});
                      })
                  : null),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = localController.text.trim();
                });
                Navigator.pop(ctx);
              },
              child: const Text('Cari')),
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

enum WarningType { warning, error }

class _WarningItem {
  final StokModel stock;
  final String message;
  final String detail;
  final WarningType type;
  final String dismissKey;
  _WarningItem(
      {required this.stock,
      required this.message,
      required this.detail,
      required this.type,
      required this.dismissKey});
}

class _WarningTile extends StatelessWidget {
  final _WarningItem warning;
  final VoidCallback onDismiss;
  const _WarningTile({required this.warning, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final isError = warning.type == WarningType.error;
    final borderColor = isError ? AppTheme.red600 : AppTheme.orange400;
    final iconAndTextColor = isError ? AppTheme.red700 : AppTheme.orange700;
    final bgColor = AppTheme.orange400;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1))
          ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.warning_rounded, color: iconAndTextColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('WARNING: ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: iconAndTextColor,
                              letterSpacing: 0.5)),
                      Expanded(
                          child: Text(warning.stock.namaBahan.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Colors.white),
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(warning.message,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(warning.detail,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child:
                      const Icon(Icons.close, size: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final StokModel stock;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _StockCard(
      {required this.stock,
      required this.onIncrease,
      required this.onDecrease,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLow =
        stock.jumlahBahan <= 2 && !['kg', 'liter'].contains(stock.satuanBahan);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 5,
                    height: 50,
                    decoration: BoxDecoration(
                        color: _getCategoryColor(stock.kategoriBahan),
                        borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stock.namaBahan,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(spacing: 8, runSpacing: 4, children: [
                        _chipWithoutIcon(stock.kategoriBahan, colors),
                        _chipWithIcon(
                            Icons.label_rounded,
                            stock.tipeBahan == 'kemasan' ? 'Kemasan' : 'Segar',
                            colors),
                        if (stock.tanggalKadaluarsa != null)
                          _chipWithIcon(Icons.calendar_today_rounded,
                              _formatDate(stock.tanggalKadaluarsa!), colors),
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        '${stock.jumlahBahan % 1 == 0 ? stock.jumlahBahan.toInt() : stock.jumlahBahan.toStringAsFixed(1)} ${stock.satuanBahan}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color:
                                isLow ? AppTheme.red500 : colors.textPrimary)),
                    if (stock.tanggalBeli != null)
                      Text('Beli: ${_formatDate(stock.tanggalBeli!)}',
                          style:
                              TextStyle(fontSize: 10, color: colors.textHint)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(
                    icon: Icons.remove_rounded,
                    bg: AppTheme.red50,
                    fg: AppTheme.red600,
                    onTap: onDecrease),
                const SizedBox(width: 8),
                _actionButton(
                    icon: Icons.add_rounded,
                    bg: AppTheme.green50,
                    fg: AppTheme.green600,
                    onTap: onIncrease),
                const SizedBox(width: 8),
                _actionButton(
                    icon: Icons.edit_rounded,
                    bg: colors.surface,
                    fg: colors.textSecondary,
                    onTap: onEdit),
                const SizedBox(width: 4),
                _actionButton(
                    icon: Icons.delete_outline_rounded,
                    bg: colors.surface,
                    fg: AppTheme.red500,
                    onTap: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipWithoutIcon(String label, AppColors colors) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: colors.chipBackground,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: colors.border.withOpacity(0.3), width: 0.5)),
      child:
          Text(label, style: TextStyle(fontSize: 11, color: colors.chipText)));
  Widget _chipWithIcon(IconData icon, String label, AppColors colors) =>
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: colors.chipBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: colors.border.withOpacity(0.3), width: 0.5)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 12, color: colors.chipText),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: colors.chipText))
          ]));
  Widget _actionButton(
          {required IconData icon,
          required Color bg,
          required Color fg,
          required VoidCallback onTap}) =>
      IconButton(
          icon: Icon(icon, size: 20),
          onPressed: onTap,
          style: IconButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))));
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Protein':
        return AppTheme.orange600;
      case 'Sayur & Buah':
        return AppTheme.green600;
      case 'Karbohidrat':
        return AppTheme.blue500;
      case 'Bumbu & Lainnya':
        return AppTheme.purple600;
      case 'Jajanan':
        return AppTheme.red500;
      case 'Minuman':
        return AppTheme.blue500;
      default:
        return AppTheme.slate500;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _StockFormSheet extends StatefulWidget {
  final StokModel? existingStock;
  final String? initialTipe;
  final VoidCallback onSubmit;
  const _StockFormSheet(
      {this.existingStock, this.initialTipe, required this.onSubmit});

  @override
  State<_StockFormSheet> createState() => _StockFormSheetState();
}

class _StockFormSheetState extends State<_StockFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  late String _satuan;
  String _kategori = 'Protein';
  late String _tipe;
  bool _isEditing = false;
  String? _editId;
  bool _isSubmitting = false;
  DateTime? _tanggalBeli;
  DateTime? _tanggalKadaluarsa;
  bool _isKategoriLain = false;
  final _kategoriLainCtrl = TextEditingController();
  bool _isSatuanLain = false;
  final _satuanLainCtrl = TextEditingController();
  final List<String> _kategoriList = [
    'Protein',
    'Sayur & Buah',
    'Karbohidrat',
    'Bumbu & Lainnya',
    'Jajanan',
    'Minuman',
    'Lainnya'
  ];
  final List<String> _satuanList = [
    'kg',
    'gram',
    'liter',
    'pcs',
    'bungkus',
    'botol',
    'cup',
    'gelas',
    'sachet',
    'lembar',
    'porsi',
    'mangkok',
    'sendok',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingStock != null) {
      _isEditing = true;
      _editId = widget.existingStock!.id;
      _namaCtrl.text = widget.existingStock!.namaBahan;
      _jumlahCtrl.text = widget.existingStock!.jumlahBahan.toString();
      _satuan = widget.existingStock!.satuanBahan;
      _kategori = widget.existingStock!.kategoriBahan;
      _tipe = widget.existingStock!.tipeBahan;
      _tanggalBeli = widget.existingStock!.tanggalBeli;
      _tanggalKadaluarsa = widget.existingStock!.tanggalKadaluarsa;
      if (!_kategoriList.contains(_kategori)) {
        _isKategoriLain = true;
        _kategoriLainCtrl.text = _kategori;
      }
      if (!_satuanList.contains(_satuan)) {
        _isSatuanLain = true;
        _satuanLainCtrl.text = _satuan;
      }
    } else {
      _tanggalBeli = DateTime.now();
      _satuan = _satuanList.first;
      _tipe = widget.initialTipe ?? 'segar';
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _jumlahCtrl.dispose();
    _kategoriLainCtrl.dispose();
    _satuanLainCtrl.dispose();
    super.dispose();
  }

  String _getFinalKategori() => _isKategoriLain
      ? (_kategoriLainCtrl.text.trim().isEmpty
          ? 'Lainnya'
          : _kategoriLainCtrl.text.trim())
      : _kategori;
  String _getFinalSatuan() => _isSatuanLain
      ? (_satuanLainCtrl.text.trim().isEmpty
          ? 'Lainnya'
          : _satuanLainCtrl.text.trim())
      : _satuan;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipe == 'kemasan' && _tanggalKadaluarsa == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tanggal kadaluarsa wajib untuk bahan kemasan')));
      return;
    }
    final kategoriFinal = _getFinalKategori();
    final satuanFinal = _getFinalSatuan();
    if (_isKategoriLain && kategoriFinal.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Isi kategori Lainnya')));
      return;
    }
    if (_isSatuanLain && satuanFinal.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Isi satuan Lainnya')));
      return;
    }
    setState(() => _isSubmitting = true);
    final body = {
      'Nama_Bahan': _namaCtrl.text.trim(),
      'Kategori_Bahan': kategoriFinal,
      'Jumlah_Bahan': double.parse(_jumlahCtrl.text),
      'Satuan_Bahan': satuanFinal,
      'Tipe_Bahan': _tipe,
      'Tanggal_Beli': _tanggalBeli?.toIso8601String(),
      if (_tanggalKadaluarsa != null)
        'Tanggal_Kadaluarsa': _tanggalKadaluarsa!.toIso8601String(),
    };
    final response = _isEditing
        ? await ApiService.put('/inventory/$_editId', body)
        : await ApiService.post('/inventory', body);
    setState(() => _isSubmitting = false);
    if (response['success'] == true) {
      widget.onSubmit();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(_isEditing ? 'Bahan diperbarui' : 'Bahan ditambahkan')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${response['message']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(_isEditing ? 'Edit Bahan' : 'Tambah Bahan Baru',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              TextFormField(
                  controller: _namaCtrl,
                  decoration: InputDecoration(
                      labelText: 'Nama Bahan',
                      hintText: 'Contoh: Dada Ayam, Beras, Kecap',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14))),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama bahan wajib' : null),
              const SizedBox(height: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Kategori',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (!_isKategoriLain)
                  DropdownButtonFormField<String>(
                    value: _kategori,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14))),
                    items: _kategoriList
                        .map((cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        if (value == 'Lainnya') {
                          _isKategoriLain = true;
                          _kategoriLainCtrl.clear();
                        } else {
                          _kategori = value!;
                        }
                      });
                    },
                  ),
                if (_isKategoriLain)
                  Row(children: [
                    Expanded(
                        child: TextFormField(
                            controller: _kategoriLainCtrl,
                            decoration: InputDecoration(
                                labelText: 'Kategori Lainnya',
                                hintText: 'Masukkan kategori custom',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14))),
                            autofocus: true,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Harus diisi' : null)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _isKategoriLain = false;
                            _kategoriLainCtrl.clear();
                            _kategori = _kategoriList.first;
                          });
                        })
                  ]),
              ]),
              const SizedBox(height: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Tipe Bahan',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'segar',
                        label: Text('Segar'),
                        icon: Icon(Icons.eco_rounded)),
                    ButtonSegment(
                        value: 'kemasan',
                        label: Text('Kemasan'),
                        icon: Icon(Icons.inventory_rounded))
                  ],
                  selected: {_tipe},
                  onSelectionChanged: (set) =>
                      setState(() => _tipe = set.first),
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? AppTheme.orange500
                              : colors.surface),
                      foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? Colors.white
                              : colors.textPrimary)),
                ),
              ]),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    flex: 1,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jumlah',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          TextFormField(
                              controller: _jumlahCtrl,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14))),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d.]'))
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Jumlah wajib';
                                if (double.tryParse(v) == null)
                                  return 'Angka tidak valid';
                                return null;
                              })
                        ])),
                const SizedBox(width: 12),
                Expanded(
                    flex: 1,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Satuan',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          if (!_isSatuanLain)
                            DropdownButtonFormField<String>(
                                value: _satuan,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14))),
                                items: _satuanList
                                    .map((unit) => DropdownMenuItem(
                                        value: unit, child: Text(unit)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == 'Lainnya') {
                                      _isSatuanLain = true;
                                      _satuanLainCtrl.clear();
                                    } else {
                                      _satuan = value!;
                                    }
                                  });
                                },
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Satuan wajib'
                                    : null),
                          if (_isSatuanLain)
                            Row(children: [
                              Expanded(
                                  child: TextFormField(
                                      controller: _satuanLainCtrl,
                                      decoration: InputDecoration(
                                          labelText: 'Satuan Lainnya',
                                          hintText: 'Masukkan satuan custom',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14))),
                                      autofocus: true,
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Harus diisi'
                                          : null)),
                              IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _isSatuanLain = false;
                                      _satuanLainCtrl.clear();
                                      _satuan = _satuanList.first;
                                    });
                                  })
                            ])
                        ])),
              ]),
              const SizedBox(height: 16),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: const Text('Tanggal Beli'),
                  subtitle: Text(_tanggalBeli != null
                      ? _formatDate(_tanggalBeli!)
                      : 'Pilih tanggal'),
                  trailing: IconButton(
                      icon: const Icon(Icons.date_range_rounded),
                      onPressed: () async {
                        final picked = await showDatePicker(
                            context: context,
                            initialDate: _tanggalBeli ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now());
                        if (picked != null)
                          setState(() => _tanggalBeli = picked);
                      })),
              if (_tipe == 'kemasan')
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.warning_rounded,
                        color: AppTheme.red500),
                    title: const Text('Tanggal Kadaluarsa',
                        style: TextStyle(color: AppTheme.red500)),
                    subtitle: Text(_tanggalKadaluarsa != null
                        ? _formatDate(_tanggalKadaluarsa!)
                        : 'Pilih tanggal (wajib)'),
                    trailing: IconButton(
                        icon: const Icon(Icons.date_range_rounded),
                        onPressed: () async {
                          final picked = await showDatePicker(
                              context: context,
                              initialDate: _tanggalKadaluarsa ??
                                  DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 2)));
                          if (picked != null)
                            setState(() => _tanggalKadaluarsa = picked);
                        })),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.orange600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(_isEditing
                              ? 'Simpan Perubahan'
                              : 'Tambah Stok'))),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
