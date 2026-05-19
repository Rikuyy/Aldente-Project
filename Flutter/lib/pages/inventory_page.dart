import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class _InventoryItem {
  String name;
  String unit;
  double qty;
  final String category;
  final IconData icon;  // ← was: String emoji

  _InventoryItem({required this.name, required this.unit, required this.qty, required this.category, required this.icon});
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<_InventoryItem> _items = [
_InventoryItem(name: 'Telur Ayam',    unit: 'butir',   qty: 6,   category: 'Protein',         icon: Icons.egg_rounded),
_InventoryItem(name: 'Dada Ayam',     unit: 'gram',    qty: 250, category: 'Protein',         icon: Icons.lunch_dining_rounded),
_InventoryItem(name: 'Sosis',         unit: 'pcs',     qty: 3,   category: 'Protein',         icon: Icons.kebab_dining_rounded),
_InventoryItem(name: 'Bawang Merah',  unit: 'gram',    qty: 100, category: 'Sayur & Buah',    icon: Icons.grass_rounded),
_InventoryItem(name: 'Tomat',         unit: 'pcs',     qty: 2,   category: 'Sayur & Buah',    icon: Icons.spa_rounded),
_InventoryItem(name: 'Beras',         unit: 'kg',      qty: 2,   category: 'Karbohidrat',     icon: Icons.rice_bowl_rounded),
_InventoryItem(name: 'Mie Instan',    unit: 'bungkus', qty: 4,   category: 'Karbohidrat',     icon: Icons.ramen_dining_rounded),
_InventoryItem(name: 'Kecap Manis',   unit: 'botol',   qty: 1,   category: 'Bumbu & Lainnya', icon: Icons.water_drop_rounded),
_InventoryItem(name: 'Minyak Goreng', unit: 'liter',   qty: 1,   category: 'Bumbu & Lainnya', icon: Icons.opacity_rounded),
_InventoryItem(name: 'Garam',         unit: 'gram',    qty: 200, category: 'Bumbu & Lainnya', icon: Icons.scatter_plot_rounded),
  ];

  final List<Map<String, dynamic>> _history = [
    {'type': 'in',  'item': 'Telur Ayam',    'qty': 6,   'unit': 'butir',   'note': 'Beli di warung',         'time': '08.30', 'date': 'Hari ini'},
    {'type': 'out', 'item': 'Telur Ayam',    'qty': 1,   'unit': 'butir',   'note': 'Nasi goreng sarapan',    'time': '09.15', 'date': 'Hari ini'},
    {'type': 'out', 'item': 'Mie Instan',    'qty': 1,   'unit': 'bungkus', 'note': 'Mie nyemek makan siang', 'time': '12.00', 'date': 'Hari ini'},
    {'type': 'in',  'item': 'Beras',         'qty': 2,   'unit': 'kg',      'note': 'Belanja bulanan',        'time': '09.00', 'date': 'Kemarin'},
    {'type': 'in',  'item': 'Minyak Goreng', 'qty': 1,   'unit': 'liter',   'note': 'Beli di minimarket',     'time': '10.00', 'date': 'Kemarin'},
    {'type': 'out', 'item': 'Dada Ayam',     'qty': 100, 'unit': 'gram',    'note': 'Ayam goreng makan malam','time': '18.30', 'date': 'Kemarin'},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Map<String, List<_InventoryItem>> get _groupedItems {
    final q = _searchQuery.toLowerCase();
    final filtered = q.isEmpty ? _items : _items.where((i) => i.name.toLowerCase().contains(q)).toList();
    final map = <String, List<_InventoryItem>>{};
    for (final item in filtered) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  void _showInputSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StockInputSheet(
        items: _items,
        isInput: true,
        onSubmit: (itemName, qty, note) {
          setState(() {
            final idx = _items.indexWhere((i) => i.name == itemName);
            if (idx >= 0) {
              _items[idx].qty += qty;
              _history.insert(0, {'type': 'in', 'item': itemName, 'qty': qty, 'unit': _items[idx].unit, 'note': note, 'time': _nowTime(), 'date': 'Hari ini'});
            }
          });
        },
      ),
    );
  }

  void _showOutputSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StockInputSheet(
        items: _items,
        isInput: false,
        onSubmit: (itemName, qty, note) {
          setState(() {
            final idx = _items.indexWhere((i) => i.name == itemName);
            if (idx >= 0) {
              _items[idx].qty = (_items[idx].qty - qty).clamp(0, double.infinity);
              _history.insert(0, {'type': 'out', 'item': itemName, 'qty': qty, 'unit': _items[idx].unit, 'note': note, 'time': _nowTime(), 'date': 'Hari ini'});
            }
          });
        },
      ),
    );
  }

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: context.colors.cardBackground,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 56,
            title: Text('Stok Bahan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
            actions: [
              GestureDetector(
                onTap: () => _showInputSheet(context),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.green50, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppTheme.green500)),
                  child: const Row(children: [Icon(Icons.add_rounded, size: 14, color: AppTheme.green600), SizedBox(width: 4), Text('Masuk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.green600))]),
                ),
              ),
              GestureDetector(
                onTap: () => _showOutputSheet(context),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.red50, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppTheme.red100)),
                  child: const Row(children: [Icon(Icons.remove_rounded, size: 14, color: AppTheme.red500), SizedBox(width: 4), Text('Keluar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.red500))]),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(95.5),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(color: context.colors.border, borderRadius: BorderRadius.circular(14), border: Border.all(color: context.colors.border)),
                    child: Row(children: [
                      Icon(Icons.search_rounded, color: context.colors.textHint, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(hintText: 'Cari bahan...', hintStyle: TextStyle(color: context.colors.textHint, fontSize: 14), border: InputBorder.none, isDense: true),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      )),
                      if (_searchQuery.isNotEmpty) GestureDetector(onTap: () => setState(() { _searchCtrl.clear(); _searchQuery = ''; }), child: Icon(Icons.close_rounded, size: 16, color: context.colors.textHint)),
                    ]),
                  ),
                ),
                TabBar(
                  controller: _tabCtrl,
                  indicatorColor: AppTheme.orange600,
                  indicatorWeight: 2.5,
                  labelColor: AppTheme.orange600,
                  unselectedLabelColor: context.colors.textHint,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: const [Tab(text: 'Stok'), Tab(text: 'Masuk'), Tab(text: 'Keluar')],
                ),
              ]),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _StockTab(grouped: _groupedItems, onDelete: (item) => setState(() => _items.remove(item))),
            _HistoryTab(history: _history.where((h) => h['type'] == 'in').toList()),
            _HistoryTab(history: _history.where((h) => h['type'] == 'out').toList()),
          ],
        ),
      ),
    );
  }
}

class _StockTab extends StatelessWidget {
  final Map<String, List<_InventoryItem>> grouped;
  final Function(_InventoryItem) onDelete;
  const _StockTab({required this.grouped, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (grouped.isEmpty) {
      return Center(child: Text('Tidak ada bahan ditemukan.', style: TextStyle(color: context.colors.textHint, fontWeight: FontWeight.w500)));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(children: [
              Text(entry.key, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.surface, letterSpacing: 0.4)),
              const SizedBox(width: 8),
              Expanded(child: Divider(color: context.colors.border, height: 1)),
            ]),
          ),
          Container(
            decoration: BoxDecoration(color: context.colors.cardBackground, borderRadius: BorderRadius.circular(18), border: Border.all(color: context.colors.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))]),
            child: Column(children: entry.value.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isLow = item.qty <= 2;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Container(width: 38, height: 38, decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(10)), child: Center(child: Icon(item.icon, size: 20, color: context.colors.surface))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: context.colors.textPrimary)),
                      const SizedBox(height: 2),
                      Row(children: [
                        Text('${item.qty % 1 == 0 ? item.qty.toInt() : item.qty} ${item.unit}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isLow ? AppTheme.red500 : context.colors.surface)),
                        if (isLow) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.red50, borderRadius: BorderRadius.circular(50)), child: const Text('Stok menipis', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.red500)))],
                      ]),
                    ])),
                    GestureDetector(
                      onTap: () => onDelete(item),
                      child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.delete_outline_rounded, size: 16, color: context.colors.textHint)),
                    ),
                  ]),
                ),
                if (i < entry.value.length - 1) Divider(height: 1, color: context.colors.border, indent: 66),
              ]);
            }).toList()),
          ),
          const SizedBox(height: 14),
        ],
      )).toList(),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _HistoryTab({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.history_rounded, size: 48, color: context.colors.textHint),
        const SizedBox(height: 12),
        Text('Belum ada riwayat', style: TextStyle(color: context.colors.textHint, fontWeight: FontWeight.w600)),
      ]));
    }

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final h in history) { grouped.putIfAbsent(h['date'] as String, () => []).add(h); }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(children: [
              Text(entry.key, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.surface, letterSpacing: 0.4)),
              const SizedBox(width: 8),
              Expanded(child: Divider(color: context.colors.border, height: 1)),
            ]),
          ),
          Container(
            decoration: BoxDecoration(color: context.colors.cardBackground, borderRadius: BorderRadius.circular(18), border: Border.all(color: context.colors.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))]),
            child: Column(children: entry.value.asMap().entries.map((e) {
              final i = e.key;
              final h = e.value;
              final isIn = h['type'] == 'in';
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: isIn ? AppTheme.green50 : AppTheme.red50, borderRadius: BorderRadius.circular(10)),
                      child: Icon(isIn ? Icons.add_rounded : Icons.remove_rounded, color: isIn ? AppTheme.green600 : AppTheme.red500, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(h['item'] as String, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.colors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(h['note'] as String, style: TextStyle(fontSize: 11, color: context.colors.textHint, fontWeight: FontWeight.w500)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(
                       '${isIn ? '+' : '-'}${h['qty']} ${h['unit']}',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isIn ? AppTheme.green600 : AppTheme.red500),
                      ),
                      const SizedBox(height: 2),
                      Text(h['time'] as String, style: TextStyle(fontSize: 10, color: context.colors.textHint)),
                    ]),
                  ]),
                ),
                if (i < entry.value.length - 1) Divider(height: 1, color: context.colors.border, indent: 66),
              ]);
            }).toList()),
          ),
          const SizedBox(height: 14),
        ],
      )).toList(),
    );
  }
}

class _StockInputSheet extends StatefulWidget {
  final List<_InventoryItem> items;
  final bool isInput;
  final Function(String itemName, double qty, String note) onSubmit;
  const _StockInputSheet({required this.items, required this.isInput, required this.onSubmit});

  @override
  State<_StockInputSheet> createState() => _StockInputSheetState();
}

class _StockInputSheetState extends State<_StockInputSheet> {
  String? _selectedItem;
  final _qtyCtrl  = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _isNewItem = false;
  final _newItemCtrl = TextEditingController();
  final _newUnitCtrl = TextEditingController();

  String get _unit {
    if (_isNewItem) return _newUnitCtrl.text;
    final idx = widget.items.indexWhere((i) => i.name == _selectedItem);
    return idx >= 0 ? widget.items[idx].unit : '';
  }

  bool get _canSubmit => (_selectedItem != null || (_isNewItem && _newItemCtrl.text.isNotEmpty)) && _qtyCtrl.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final color = widget.isInput ? AppTheme.green600 : AppTheme.red500;
    final bgColor = widget.isInput ? AppTheme.green50 : AppTheme.red50;
    final label = widget.isInput ? 'Stok Masuk' : 'Stok Keluar';

    return Container(
      decoration: BoxDecoration(color: context.colors.cardBackground, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: context.colors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(widget.isInput ? Icons.add_rounded : Icons.remove_rounded, color: color, size: 20)),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.colors.textPrimary)),
          ]),
          const SizedBox(height: 20),
          if (!_isNewItem) ...[
            Text('Pilih Bahan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.surface, letterSpacing: 0.3)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: context.colors.border)),
              child: DropdownButton<String>(
                value: _selectedItem,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: Text('Pilih bahan makanan', style: TextStyle(color: context.colors.textHint, fontWeight: FontWeight.w500)),
                items: widget.items.map((item) => DropdownMenuItem(value: item.name, child: Row(children: [Icon(item.icon, size: 20, color: context.colors.surface), const SizedBox(width: 8), Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))]))).toList(),
                onChanged: (v) => setState(() { _selectedItem = v; _isNewItem = false; }),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() { _isNewItem = true; _selectedItem = null; }),
              child: const Row(children: [Icon(Icons.add_circle_outline_rounded, size: 16, color: AppTheme.orange600), SizedBox(width: 6), Text('Tambah bahan baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.orange600))]),
            ),
          ] else ...[
            Text('Nama Bahan Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.surface, letterSpacing: 0.3)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _inputField(controller: _newItemCtrl, hint: 'Nama bahan')),
              const SizedBox(width: 8),
              SizedBox(width: 90, child: _inputField(controller: _newUnitCtrl, hint: 'Satuan')),
            ]),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() { _isNewItem = false; _newItemCtrl.clear(); _newUnitCtrl.clear(); }),
              child: const Text('Pilih dari daftar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.orange600)),
            ),
          ],
          const SizedBox(height: 16),
          Text('Jumlah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.surface, letterSpacing: 0.3)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _inputField(controller: _qtyCtrl, hint: '0', inputType: TextInputType.number, formatter: FilteringTextInputFormatter.allow(RegExp(r'[\d.]')))),
            if (_unit.isNotEmpty) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: context.colors.border)),
                child: Text(_unit, style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.textSecondary)),
              ),
            ],
          ]),
          const SizedBox(height: 16),
          Text('Keterangan (opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.surface, letterSpacing: 0.3)),
          const SizedBox(height: 8),
          _inputField(controller: _noteCtrl, hint: widget.isInput ? 'Contoh: Beli di warung Bu Sari' : 'Contoh: Dipakai masak nasi goreng'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit ? () {
                final itemName = _isNewItem ? _newItemCtrl.text.trim() : _selectedItem!;
                final qty = double.tryParse(_qtyCtrl.text) ?? 0;
                final note = _noteCtrl.text.trim().isEmpty ? (widget.isInput ? 'Stok ditambahkan' : 'Stok digunakan') : _noteCtrl.text.trim();
                widget.onSubmit(itemName, qty, note);
                Navigator.pop(context);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: context.colors.border,
                foregroundColor: context.colors.cardBackground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('${widget.isInput ? 'Tambah' : 'Kurangi'} Stok', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({required TextEditingController controller, required String hint, TextInputType? inputType, TextInputFormatter? formatter}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: formatter != null ? [formatter] : null,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.colors.textHint, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: context.colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.colors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.colors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.orange500, width: 2)),
      ),
    );
  }
}

class IngredientRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final String change;
  const IngredientRow({super.key, required this.name, required this.subtitle, required this.change});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: AppTheme.orange500, borderRadius: BorderRadius.circular(6)),
            child: Icon(Icons.check, color: context.colors.cardBackground, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.colors.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: context.colors.surface, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(change, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.red500)),
        ],
      ),
    );
  }
}
