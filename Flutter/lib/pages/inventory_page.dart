import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  bool _showPopup = false;
  final _searchController = TextEditingController();

  final categories = [
    {'name': 'Protein', 'icon': Icons.lunch_dining, 'items': ['Telur Ayam (6 btr)', 'Dada Ayam (250g)', 'Sosis (3 pcs)']},
    {'name': 'Sayur & Buah', 'icon': Icons.eco, 'items': ['Bawang Merah (100g)', 'Tomat (2 pcs)']},
    {'name': 'Karbohidrat', 'icon': Icons.rice_bowl, 'items': ['Beras (2 kg)', 'Mie Instan (4 bks)']},
    {'name': 'Bumbu & Lainnya', 'icon': Icons.soup_kitchen, 'items': ['Kecap Manis', 'Saus Sambal', 'Garam', 'Minyak Goreng (1L)']},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.slate50,
          body: CustomScrollView(
            slivers: [
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
                      left: 24, right: 24, bottom: 12,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.slate100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.slate200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppTheme.slate400, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Cari bahan makanan...',
                                hintStyle: TextStyle(color: AppTheme.slate400, fontWeight: FontWeight.w500),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Stok Bahan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.slate800, letterSpacing: -0.5)),
                    GestureDetector(
                      onTap: () => setState(() => _showPopup = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.orange50,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: AppTheme.orange600, size: 16),
                            SizedBox(width: 4),
                            Text('Masak Selesai?', style: TextStyle(color: AppTheme.orange600, fontWeight: FontWeight.w700, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: AppTheme.slate100, height: 1)),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    categories.map((cat) {
                      final items = cat['items'] as List<String>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(cat['icon'] as IconData, size: 20, color: AppTheme.slate600),
                                const SizedBox(width: 8),
                                Text(
                                  (cat['name'] as String).toUpperCase(),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.slate800, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...items.map((item) => _InventoryChip(label: item)),
                                _AddChip(),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: AppTheme.orange600,
            elevation: 4,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
          ),
        ),

        // Cooking Done Popup
        if (_showPopup) _CookingDonePopup(onClose: () => setState(() => _showPopup = false)),
      ],
    );
  }
}

class _InventoryChip extends StatelessWidget {
  final String label;
  const _InventoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.slate200),
        // ignore: deprecated_member_use
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.slate700)),
          const SizedBox(width: 6),
          const Icon(Icons.close, size: 14, color: AppTheme.slate300),
        ],
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.slate100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.slate200, style: BorderStyle.solid),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 14, color: AppTheme.slate500),
          SizedBox(width: 4),
          Text('Tambah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.slate500)),
        ],
      ),
    );
  }
}

class _CookingDonePopup extends StatelessWidget {
  final VoidCallback onClose;
  const _CookingDonePopup({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            // ignore: deprecated_member_use
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppTheme.orange500,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 48),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Selamat Makan!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                            SizedBox(width: 8),
                            Icon(Icons.restaurant, color: Colors.white, size: 20),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('Apakah kamu menggunakan bahan ini untuk masak "Nasi Goreng Telur"?', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const _IngredientRow(name: 'Telur Ayam', subtitle: 'Sisa: 5 butir', change: '-1 btr'),
                        const SizedBox(height: 10),
                        const _IngredientRow(name: 'Bawang Merah', subtitle: 'Sisa: 80g', change: '-20g'),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onClose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.orange600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text('Ya, Kurangi Stok', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onClose,
                          child: const Text('Batal', style: TextStyle(color: AppTheme.slate400, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ],
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

class _IngredientRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final String change;
  const _IngredientRow({required this.name, required this.subtitle, required this.change});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.slate50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.slate100),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: AppTheme.orange500, borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.slate800)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.slate500, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(change, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.red500)),
        ],
      ),
    );
  }
}