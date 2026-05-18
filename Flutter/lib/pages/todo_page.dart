import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _TodoItem {
  final String id;
  String title;
  String subtitle;
  bool isDone;
  final String category;

  _TodoItem({required this.id, required this.title, required this.subtitle, this.isDone = false, required this.category});
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<_TodoItem> _todos = [
    _TodoItem(id: '1', title: 'Rencana Makan Malam', subtitle: 'Nasi Goreng Sosis (Budget sisa: Rp 15.000)', category: 'Makan'),
    _TodoItem(id: '2', title: 'Beli Telur di Warung', subtitle: 'Stok menipis, sisa 1 butir', category: 'Belanja'),
    _TodoItem(id: '3', title: 'Makan Siang', subtitle: 'Soto Ayam (Rp 12.000)', isDone: true, category: 'Makan'),
    _TodoItem(id: '4', title: 'Belanja Beras', subtitle: 'Stok habis besok', category: 'Belanja'),
    _TodoItem(id: '5', title: 'Cek Tanggal Kedaluwarsa', subtitle: 'Sosis & susu di kulkas', category: 'Stok'),
  ];

  String _filter = 'Semua';
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();

  List<_TodoItem> get _filtered {
    if (_filter == 'Selesai')  return _todos.where((t) => t.isDone).toList();
    if (_filter == 'Aktif')    return _todos.where((t) => !t.isDone).toList();
    return _todos;
  }

  int get _doneCount => _todos.where((t) => t.isDone).length;

  void _showAddSheet() {
    _titleCtrl.clear(); _subtitleCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppTheme.slate200, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('To-Do Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.slate800)),
              const SizedBox(height: 20),
              const Text('Tugas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.slate500)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Contoh: Beli telur di warung',
                  hintStyle: const TextStyle(color: AppTheme.slate300, fontWeight: FontWeight.w500),
                  filled: true, fillColor: AppTheme.slate50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.slate200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.slate200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.orange500, width: 2)),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Keterangan (opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.slate500)),
              const SizedBox(height: 8),
              TextField(
                controller: _subtitleCtrl,
                decoration: InputDecoration(
                  hintText: 'Detail tambahan...',
                  hintStyle: const TextStyle(color: AppTheme.slate300, fontWeight: FontWeight.w500),
                  filled: true, fillColor: AppTheme.slate50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.slate200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.slate200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.orange500, width: 2)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = _titleCtrl.text.trim();
                    if (title.isNotEmpty) {
                      setState(() {
                        _todos.insert(0, _TodoItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          subtitle: _subtitleCtrl.text.trim(),
                          category: 'Lainnya',
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.orange600, foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.white,
            elevation: 0,
            toolbarHeight: 56,
            automaticallyImplyLeading: false,
            title: const Text('To-Do List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.slate800, letterSpacing: -0.5)),
            actions: [
              GestureDetector(
                onTap: _showAddSheet,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.orange50, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppTheme.orange200)),
                  child: const Row(children: [Icon(Icons.add_rounded, size: 14, color: AppTheme.orange600), SizedBox(width: 4), Text('Tambah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.orange600))]),
                ),
              ),
            ],
            bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: AppTheme.slate100, height: 1)),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // Progress bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.slate100),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 6, offset: const Offset(0, 2))]),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('$_doneCount dari ${_todos.length} selesai', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.slate700)),
                    Text('${_todos.isEmpty ? 0 : (_doneCount / _todos.length * 100).round()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.orange600)),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: LinearProgressIndicator(
                      value: _todos.isEmpty ? 0 : _doneCount / _todos.length,
                      minHeight: 8,
                      backgroundColor: AppTheme.slate100,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.orange500),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: ['Semua', 'Aktif', 'Selesai'].map((f) {
                  final isSel = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? AppTheme.orange500 : AppTheme.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: isSel ? AppTheme.orange500 : AppTheme.slate200),
                      ),
                      child: Text(f, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSel ? AppTheme.white : AppTheme.slate600)),
                    ),
                  );
                }).toList()),
              ),

              const SizedBox(height: 16),

              if (filtered.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppTheme.slate300),
                    const SizedBox(height: 12),
                    Text(_filter == 'Selesai' ? 'Belum ada yang selesai' : 'Tidak ada tugas aktif', style: const TextStyle(color: AppTheme.slate400, fontWeight: FontWeight.w600)),
                  ]),
                ))
              else
                ...filtered.map((todo) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: Key(todo.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(color: AppTheme.red50, borderRadius: BorderRadius.circular(18)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline_rounded, color: AppTheme.red500),
                    ),
                    onDismissed: (_) => setState(() => _todos.removeWhere((t) => t.id == todo.id)),
                    child: GestureDetector(
                      onTap: () => setState(() => todo.isDone = !todo.isDone),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: todo.isDone ? AppTheme.slate50 : AppTheme.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: todo.isDone ? AppTheme.slate200 : AppTheme.slate100),
                          boxShadow: todo.isDone ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: todo.isDone ? AppTheme.green500 : AppTheme.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: todo.isDone ? AppTheme.green500 : AppTheme.slate300, width: 2),
                            ),
                            child: todo.isDone ? const Icon(Icons.check_rounded, size: 14, color: AppTheme.white) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(todo.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: todo.isDone ? AppTheme.slate400 : AppTheme.slate800, decoration: todo.isDone ? TextDecoration.lineThrough : null, letterSpacing: -0.2)),
                            if (todo.subtitle.isNotEmpty) ...[const SizedBox(height: 3), Text(todo.subtitle, style: TextStyle(fontSize: 12, color: todo.isDone ? AppTheme.slate300 : AppTheme.slate500, fontWeight: FontWeight.w500))],
                          ])),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppTheme.slate100, borderRadius: BorderRadius.circular(50)),
                            child: Text(todo.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.slate500)),
                          ),
                        ]),
                      ),
                    ),
                  ),
                )),

              const SizedBox(height: 30),
            ])),
          ),
        ],
      ),
    );
  }
}