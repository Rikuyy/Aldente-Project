import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  String _name = 'Budi';
  List<String> _favFoods = ['Pedas 🌶️', 'Ayam 🍗', 'Gurih 🥘'];
  List<String> _allergies = ['Kacang 🥜'];
  String _budgetCycle = 'Mingguan';
  List<String> _missingTools = ['Oven 🎛️', 'Blender 🌪️'];
  int _eatFrequency = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        title: const Text('Profil DNA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.slate800, letterSpacing: -0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppTheme.slate500),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() => _isEditing = !_isEditing),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _isEditing ? const Color(0xFF22C55E) : AppTheme.orange50,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isEditing ? Icons.save_rounded : Icons.edit_rounded,
                      size: 14,
                      color: _isEditing ? Colors.white : AppTheme.orange600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isEditing ? 'Simpan' : 'Edit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isEditing ? Colors.white : AppTheme.orange600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.orange100,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: Text(
                  _name.isNotEmpty ? _name[0].toUpperCase() : 'B',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.orange600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(_name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate800, letterSpacing: -0.5)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.slate100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: AppTheme.orange500),
                      SizedBox(width: 8),
                      Text('Makanan Kesukaan', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.slate800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _favFoods.map((food) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.orange50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.orange200),
                        ),
                        child: Text(food, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.orange600)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.slate100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: AppTheme.blue500),
                      SizedBox(width: 8),
                      Text('Siklus Pengaturan Uang', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.slate800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.blue50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.blue100),
                    ),
                    child: Text(_budgetCycle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.blue500)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.slate100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(color: AppTheme.purple100, borderRadius: BorderRadius.circular(50)),
                        child: Center(child: Text('${_eatFrequency}x', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.purple600))),
                      ),
                      const SizedBox(width: 8),
                      const Text('Frekuensi Makan Sehari', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.slate800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppTheme.slate50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.slate100)),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.slate600),
                        children: [
                          const TextSpan(text: 'Makan '),
                          TextSpan(text: '$_eatFrequency kali', style: const TextStyle(color: AppTheme.purple600)),
                          const TextSpan(text: ' sehari.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
