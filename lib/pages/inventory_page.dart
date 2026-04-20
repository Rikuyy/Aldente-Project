import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final categories = [
    {'name': 'Protein', 'icon': '🥩', 'items': ['Telur Ayam (6 btr)', 'Dada Ayam (250g)', 'Sosis (3 pcs)']},
    {'name': 'Sayur & Buah', 'icon': '🥦', 'items': ['Bawang Merah (100g)', 'Tomat (2 pcs)']},
    {'name': 'Karbohidrat', 'icon': '🍚', 'items': ['Beras (2 kg)', 'Mie Instan (4 bks)']},
    {'name': 'Bumbu & Lainnya', 'icon': '🧂', 'items': ['Kecap Manis', 'Saus Sambal', 'Garam', 'Minyak Goreng (1L)']},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        title: const Text('Stok Bahan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.slate800, letterSpacing: -0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categories.map((cat) {
            final items = cat['items'] as List<String>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(cat['icon'] as String, style: const TextStyle(fontSize: 20)),
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
                    children: items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.slate200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.slate700)),
                            const SizedBox(width: 6),
                            const Icon(Icons.close, size: 14, color: AppTheme.slate300),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.orange600,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}
