import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Resep {
  final String id;
  final String title;
  final String ingredients;
  final String steps;
  final String category;
  Resep({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.category,
  });
}

class _TodoItem {
  final String id;
  final String title;
  final int sesi;
  final String resepId;
  final String category;
  bool isDone;
  _TodoItem({
    required this.id,
    required this.title,
    required this.sesi,
    required this.resepId,
    required this.category,
    this.isDone = false,
  });
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final Map<String, Resep> mockResepMap = {
    'resep1': Resep(
      id: 'resep1',
      title: 'Nasi Goreng Sosis',
      ingredients:
          'Nasi, sosis, telur, kecap manis, bawang merah, bawang putih',
      steps:
          '1. Tumis bawang. 2. Masukkan sosis. 3. Tambahkan nasi dan telur. 4. Bumbui. 5. Sajikan.',
      category: 'Makan Siang',
    ),
    'resep2': Resep(
      id: 'resep2',
      title: 'Soto Ayam',
      ingredients: 'Ayam, tauge, kol, soun, daun bawang, seledri, bumbu soto',
      steps:
          '1. Rebus ayam dengan bumbu. 2. Suwir ayam. 3. Sajikan dengan pelengkap.',
      category: 'Makan Siang',
    ),
    'resep3': Resep(
      id: 'resep3',
      title: 'Bubur Ayam',
      ingredients: 'Beras, ayam, cakwe, kacang, seledri',
      steps: '1. Masak bubur. 2. Buat kuah ayam. 3. Sajikan.',
      category: 'Sarapan',
    ),
    'resep4': Resep(
      id: 'resep4',
      title: 'Pisang Goreng',
      ingredients: 'Pisang kepok, tepung terigu, tepung beras, gula, vanili',
      steps: '1. Campur adonan. 2. Celup pisang. 3. Goreng hingga keemasan.',
      category: 'Cemilan',
    ),
  };

  List<_TodoItem> _todos = [];
  String _filter = 'Semua';

  // State form inline - hanya untuk kontrol visibilitas
  Set<String> _openBeli = {};
  Set<String> _openMasak = {};

  List<_TodoItem> get _filtered {
    if (_filter == 'Selesai') return _todos.where((t) => t.isDone).toList();
    if (_filter == 'Aktif') return _todos.where((t) => !t.isDone).toList();
    return _todos;
  }

  int get _doneCount => _todos.where((t) => t.isDone).length;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    final list = mockResepMap.values.toList();
    for (int i = 0; i < list.length; i++) {
      _todos.add(_TodoItem(
        id: 'todo_$i',
        title: list[i].title,
        sesi: i + 1,
        resepId: list[i].id,
        category: list[i].category,
      ));
    }
    setState(() {});
  }

  void _showDetailResep(Resep resep) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(resep.title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bahan:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary)),
              const SizedBox(height: 4),
              Text(resep.ingredients,
                  style: TextStyle(color: context.colors.textSecondary)),
              const SizedBox(height: 12),
              Text('Langkah:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary)),
              const SizedBox(height: 4),
              Text(resep.steps,
                  style: TextStyle(color: context.colors.textSecondary)),
              const SizedBox(height: 8),
              Text('Kategori: ${resep.category}',
                  style:
                      TextStyle(fontSize: 12, color: context.colors.textHint)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: Text('Tutup', style: TextStyle(color: AppTheme.orange600)),
          ),
        ],
      ),
    );
  }

  void _simpanJadwal(String resepId, int sesi) {
    // Simulasi penyimpanan ke jadwal_makan
    print('Simpan ke jadwal_makan: resepId=$resepId, sesi=$sesi');
  }

  @override
  Widget build(BuildContext context) {
    // Hitung sapaan berdasarkan waktu
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.white,
            elevation: 0,
            toolbarHeight: 56,
            automaticallyImplyLeading: false,
            title: Text('To-Do List',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: context.colors.textPrimary,
                    letterSpacing: -0.5)),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: context.colors.border, height: 1)),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header sapaan (dipindah ke atas, menggantikan Rencana Memasak)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.orange50, AppTheme.orange100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.restaurant_menu,
                          size: 32, color: AppTheme.orange600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(greeting,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.orange600)),
                            Text('Yuk selesaikan daftar masak hari ini',
                                style: TextStyle(
                                    fontSize: 13, color: AppTheme.orange700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.colors.border),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$_doneCount dari ${_todos.length} selesai',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary)),
                          Text(
                              '${_todos.isEmpty ? 0 : (_doneCount / _todos.length * 100).round()}%',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.orange600)),
                        ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                        value: _todos.isEmpty ? 0 : _doneCount / _todos.length,
                        minHeight: 8,
                        backgroundColor: context.colors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.orange500),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: ['Semua', 'Aktif', 'Selesai'].map((f) {
                    final isSel = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f),
                        selected: isSel,
                        onSelected: (_) => setState(() => _filter = f),
                        selectedColor: AppTheme.orange500,
                        backgroundColor: AppTheme.white,
                        checkmarkColor: AppTheme.white,
                        labelStyle: TextStyle(
                            color: isSel
                                ? AppTheme.white
                                : context.colors.textSecondary),
                        side: BorderSide(color: context.colors.border),
                      ),
                    );
                  }).toList()),
                ),
                const SizedBox(height: 16),
                // Daftar todo item
                ..._filtered.map((todo) => _buildTodoItem(todo)).toList(),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(_TodoItem todo) {
    final resep = mockResepMap[todo.resepId]!;
    return Column(
      children: [
        // Card todo utama
        Dismissible(
          key: Key(todo.id),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
                color: AppTheme.red50, borderRadius: BorderRadius.circular(18)),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.delete_outline_rounded, color: AppTheme.red500),
          ),
          onDismissed: (_) =>
              setState(() => _todos.removeWhere((t) => t.id == todo.id)),
          child: GestureDetector(
            onTap: () => _showDetailResep(resep),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: todo.isDone ? context.colors.surface : AppTheme.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: todo.isDone
                        ? context.colors.border
                        : context.colors.border),
                boxShadow: todo.isDone
                    ? null
                    : [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        todo.isDone = !todo.isDone;
                        // Tutup form apapun yang terbuka untuk todo ini ketika status berubah
                        _openBeli.remove(todo.id);
                        _openMasak.remove(todo.id);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: todo.isDone ? AppTheme.green500 : AppTheme.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: todo.isDone
                                ? AppTheme.green500
                                : context.colors.textHint,
                            width: 2),
                      ),
                      child: todo.isDone
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: AppTheme.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppTheme.orange50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: AppTheme.orange200)),
                              child: Text('Sesi ${todo.sesi}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.orange600)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                todo.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: todo.isDone
                                      ? context.colors.textHint
                                      : context.colors.textPrimary,
                                  decoration: todo.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: context.colors.border,
                                  borderRadius: BorderRadius.circular(50)),
                              child: Text(todo.category,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.surface)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Dua tombol: Beli dan Masak
                  Row(
                    children: [
                      _actionButton(
                        'Beli',
                        todo.isDone
                            ? null
                            : () => setState(() {
                                  if (_openMasak.contains(todo.id))
                                    _openMasak.remove(todo.id);
                                  if (_openBeli.contains(todo.id)) {
                                    _openBeli.remove(todo.id);
                                  } else {
                                    _openBeli.add(todo.id);
                                  }
                                }),
                        enabled: !todo.isDone,
                      ),
                      const SizedBox(width: 6),
                      _actionButton(
                        'Masak',
                        todo.isDone
                            ? null
                            : () => setState(() {
                                  if (_openBeli.contains(todo.id))
                                    _openBeli.remove(todo.id);
                                  if (_openMasak.contains(todo.id)) {
                                    _openMasak.remove(todo.id);
                                  } else {
                                    _openMasak.add(todo.id);
                                  }
                                }),
                        enabled: !todo.isDone,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Form inline beli (stateful, tidak kehilangan fokus)
        if (_openBeli.contains(todo.id) && !todo.isDone)
          _BeliFormInline(
            todo: todo,
            resep: resep,
            onSaved: () {
              setState(() {
                todo.isDone = true;
                _openBeli.remove(todo.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data beli tersimpan')));
              _simpanJadwal(todo.resepId, todo.sesi);
            },
          ),
        // Form inline masak (stateful, tidak kehilangan fokus)
        if (_openMasak.contains(todo.id) && !todo.isDone)
          _MasakFormInline(
            todo: todo,
            resep: resep,
            onSaved: () {
              setState(() {
                todo.isDone = true;
                _openMasak.remove(todo.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data masak tersimpan')));
              _simpanJadwal(todo.resepId, todo.sesi);
            },
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _actionButton(String label, VoidCallback? onPressed,
      {required bool enabled}) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? AppTheme.orange500 : Colors.grey.shade400,
        foregroundColor: AppTheme.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ==================== FORM BELI STATEFUL (tidak kehilangan fokus) ====================
class _BeliFormInline extends StatefulWidget {
  final _TodoItem todo;
  final Resep resep;
  final VoidCallback onSaved;

  const _BeliFormInline({
    required this.todo,
    required this.resep,
    required this.onSaved,
  });

  @override
  State<_BeliFormInline> createState() => _BeliFormInlineState();
}

class _BeliFormInlineState extends State<_BeliFormInline> {
  // Data beli: list of (nama, nominal)
  late List<MapEntry<String, String>> _items;
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _namaControllers = [];
  final List<TextEditingController> _nominalControllers = [];

  @override
  void initState() {
    super.initState();
    _items = [MapEntry('', '')];
    _initControllers();
  }

  void _initControllers() {
    for (var i = 0; i < _items.length; i++) {
      _namaControllers.add(TextEditingController(text: _items[i].key));
      _nominalControllers.add(TextEditingController(text: _items[i].value));
    }
  }

  @override
  void dispose() {
    for (var c in _namaControllers) {
      c.dispose();
    }
    for (var c in _nominalControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    if (_items.length >= 3) return;
    setState(() {
      _items.add(MapEntry('', ''));
      _namaControllers.add(TextEditingController());
      _nominalControllers.add(TextEditingController());
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) return;
    setState(() {
      _namaControllers[index].dispose();
      _nominalControllers[index].dispose();
      _items.removeAt(index);
      _namaControllers.removeAt(index);
      _nominalControllers.removeAt(index);
    });
  }

  void _updateItem(int index) {
    setState(() {
      _items[index] = MapEntry(
        _namaControllers[index].text,
        _nominalControllers[index].text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.orange200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daftar Pembelian',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.colors.textPrimary)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (ctx, idx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _namaControllers[idx],
                            decoration: const InputDecoration(
                              hintText: 'Nama pembelian',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                            onChanged: (_) => _updateItem(idx),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Tidak boleh kosong'
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _nominalControllers[idx],
                            decoration: const InputDecoration(
                              hintText: 'Nominal',
                              border: OutlineInputBorder(),
                              prefixText: 'Rp ',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _updateItem(idx),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Tidak boleh kosong'
                                    : null,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: AppTheme.red500, size: 20),
                          onPressed: () => _removeItem(idx),
                        ),
                        if (idx == _items.length - 1 && _items.length < 3)
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: AppTheme.orange500, size: 20),
                            onPressed: _addItem,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => widget.onSaved(), // batal tutup form
                  child: Text('Batal',
                      style: TextStyle(color: context.colors.textSecondary)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Simpan data (bisa ditambahkan ke database)
                      print('Data beli: $_items');
                      widget.onSaved();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange600),
                  child: const Text('Simpan',
                      style: TextStyle(color: AppTheme.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== FORM MASAK STATEFUL ====================
class _MasakFormInline extends StatefulWidget {
  final _TodoItem todo;
  final Resep resep;
  final VoidCallback onSaved;

  const _MasakFormInline({
    required this.todo,
    required this.resep,
    required this.onSaved,
  });

  @override
  State<_MasakFormInline> createState() => _MasakFormInlineState();
}

class _MasakFormInlineState extends State<_MasakFormInline> {
  late bool _auto;
  late final TextEditingController _namaController;
  late final TextEditingController _nominalController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _auto = false;
    _namaController = TextEditingController();
    _nominalController = TextEditingController();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.orange200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data Memasak',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.colors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _auto,
                  onChanged: (val) {
                    setState(() {
                      _auto = val ?? false;
                      if (_auto) {
                        _namaController.text = widget.resep.title;
                      } else {
                        _namaController.clear();
                      }
                    });
                  },
                  activeColor: AppTheme.orange500,
                ),
                Text('Gunakan nama resep otomatis',
                    style: TextStyle(color: context.colors.textPrimary)),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                  labelText: 'Nama Masakan', border: OutlineInputBorder()),
              enabled: !_auto,
              validator: (value) {
                if (_auto) return null;
                return (value == null || value.trim().isEmpty)
                    ? 'Isi nama masakan'
                    : null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nominalController,
              decoration: const InputDecoration(
                labelText: 'Nominal',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Isi nominal'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onSaved, // batal tutup form
                  child: Text('Batal',
                      style: TextStyle(color: context.colors.textSecondary)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print(
                          'Simpan data masak: nama=${_namaController.text}, nominal=${_nominalController.text}');
                      widget.onSaved();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange600),
                  child: const Text('Simpan',
                      style: TextStyle(color: AppTheme.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
