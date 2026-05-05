import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class Tag {
  final String text;
  final FaIconData icon;

  const Tag(this.text, this.icon);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  String _name = 'Budi';
  List<Tag> _favFoods = [const Tag('Pedas', FontAwesomeIcons.pepperHot), const Tag('Ayam', FontAwesomeIcons.drumstickBite), const Tag('Gurih', FontAwesomeIcons.utensils)];
  List<Tag> _allergies = [const Tag('Kacang', FontAwesomeIcons.seedling)];
  String _budgetCycle = 'Mingguan';
  List<Tag> _missingTools = [const Tag('Oven', FontAwesomeIcons.fire), const Tag('Blender', FontAwesomeIcons.blender)];
  int _eatFrequency = 3;

  final _allFavFoods = [const Tag('Pedas', FontAwesomeIcons.pepperHot), const Tag('Manis', FontAwesomeIcons.candyCane), const Tag('Gurih', FontAwesomeIcons.utensils), const Tag('Asin', FontAwesomeIcons.mortarPestle), const Tag('Ayam', FontAwesomeIcons.drumstickBite), const Tag('Sapi', FontAwesomeIcons.cow), const Tag('Seafood', FontAwesomeIcons.fish), const Tag('Sayuran', FontAwesomeIcons.carrot)];
  final _allAllergies = [const Tag('Kacang', FontAwesomeIcons.seedling), const Tag('Susu', FontAwesomeIcons.whiskeyGlass), const Tag('Telur', FontAwesomeIcons.egg), const Tag('Seafood', FontAwesomeIcons.fish), const Tag('Gluten', FontAwesomeIcons.breadSlice), const Tag('Kedelai', FontAwesomeIcons.seedling)];
  final _allTools = [const Tag('Kompor', FontAwesomeIcons.fire), const Tag('Oven', FontAwesomeIcons.fire), const Tag('Microwave', FontAwesomeIcons.radiation), const Tag('Blender', FontAwesomeIcons.blender), const Tag('Rice Cooker', FontAwesomeIcons.bowlRice), const Tag('Kulkas', FontAwesomeIcons.snowflake)];

  void _toggleItem(Tag item, List<Tag> list, Function(List<Tag>) setter) {
    setState(() {
      if (list.any((t) => t.text == item.text)) {
        setter(List.from(list)..removeWhere((t) => t.text == item.text));
      } else {
        setter(List.from(list)..add(item));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 60,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28, color: AppTheme.slate500),
              onPressed: () => context.pop(),
            ),
            title: const Text('Profil DNA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.slate800, letterSpacing: -0.5)),
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
            bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: AppTheme.slate100, height: 1)),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Avatar
                Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.orange100,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 30.6), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Center(
                        child: Text(
                          _name.isNotEmpty ? _name[0].toUpperCase() : 'B',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.orange600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isEditing)
                      SizedBox(
                        width: 180,
                        child: TextField(
                          onChanged: (v) => setState(() => _name = v),
                          controller: TextEditingController(text: _name),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.slate200, width: 2)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.orange500, width: 2)),
                            filled: true, fillColor: Colors.white,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.slate800),
                        ),
                      )
                    else
                      Text(_name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate800, letterSpacing: -0.5)),
                  ],
                ),

                const SizedBox(height: 24),

                // Food Preferences + Allergies
                _ProfileSection(
                  children: [
                    _TagGroup(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppTheme.orange500,
                      title: 'Makanan Kesukaan',
                      tags: _favFoods,
                      allTags: _allFavFoods,
                      selectedColor: AppTheme.orange50,
                      selectedTextColor: AppTheme.orange600,
                      selectedBorderColor: AppTheme.orange200,
                      isEditing: _isEditing,
                      onToggle: (item) => _toggleItem(item, _favFoods, (v) => _favFoods = v),
                      emptyText: 'Belum ada makanan kesukaan.',
                    ),
                    const Divider(color: AppTheme.slate100, height: 32),
                    _TagGroup(
                      icon: Icons.error_outline_rounded,
                      iconColor: AppTheme.red500,
                      title: 'Alergi Bahan Makanan',
                      tags: _allergies,
                      allTags: _allAllergies,
                      selectedColor: AppTheme.red50,
                      selectedTextColor: AppTheme.red600,
                      selectedBorderColor: AppTheme.red200,
                      isEditing: _isEditing,
                      onToggle: (item) => _toggleItem(item, _allergies, (v) => _allergies = v),
                      emptyText: 'Aman! Tidak ada alergi.',
                      emptyIsGood: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Budget + Tools + Frequency
                _ProfileSection(
                  children: [
                    // Budget cycle
                    const Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: AppTheme.blue500, size: 20),
                        SizedBox(width: 8),
                        Text('Siklus Pengaturan Uang', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.slate800)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isEditing)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.slate50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.slate100),
                        ),
                        child: Row(
                          children: ['Harian', 'Mingguan', 'Bulanan'].map((opt) {
                            final isSelected = _budgetCycle == opt;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _budgetCycle = opt),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 15.3), blurRadius: 4)] : null,
                                  ),
                                  child: Text(opt, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? AppTheme.blue500 : AppTheme.slate500)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.blue50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.blue100),
                        ),
                        child: Text(_budgetCycle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.blue500)),
                      ),

                    const Divider(color: AppTheme.slate100, height: 32),

                    // Missing tools
                    _TagGroup(
                      icon: Icons.no_meals_rounded,
                      iconColor: AppTheme.slate500,
                      title: 'Alat Masak Tidak Dimiliki',
                      tags: _missingTools,
                      allTags: _allTools,
                      selectedColor: AppTheme.slate800,
                      selectedTextColor: Colors.white,
                      selectedBorderColor: AppTheme.slate700,
                      isEditing: _isEditing,
                      onToggle: (item) => _toggleItem(item, _missingTools, (v) => _missingTools = v),
                      emptyText: 'Dapur lengkap!',
                      emptyIsGood: true,
                      strikethrough: true,
                    ),

                    const Divider(color: AppTheme.slate100, height: 32),

                    // Eat frequency
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
                    if (_isEditing)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.purple50, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.purple100)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () { if (_eatFrequency > 1) setState(() => _eatFrequency--); },
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.purple100)),
                                child: const Center(child: Text('-', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.slate700))),
                              ),
                            ),
                            SizedBox(
                              width: 48,
                              child: Center(child: Text('$_eatFrequency', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.purple600))),
                            ),
                            GestureDetector(
                              onTap: () { if (_eatFrequency < 6) setState(() => _eatFrequency++); },
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.purple100)),
                                child: const Center(child: Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.slate700))),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
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

                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.red600,
                      side: const BorderSide(color: AppTheme.red100),
                      backgroundColor: AppTheme.red50,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Keluar dari CookCase+', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final List<Widget> children;
  const _ProfileSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.slate100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 10.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _TagGroup extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Tag> tags;
  final List<Tag> allTags;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color selectedBorderColor;
  final bool isEditing;
  final Function(Tag) onToggle;
  final String emptyText;
  final bool emptyIsGood;
  final bool strikethrough;

  const _TagGroup({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.tags,
    required this.allTags,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.selectedBorderColor,
    required this.isEditing,
    required this.onToggle,
    required this.emptyText,
    this.emptyIsGood = false,
    this.strikethrough = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayTags = isEditing ? allTags : tags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.slate800)),
          ],
        ),
        const SizedBox(height: 10),
        if (displayTags.isEmpty && !isEditing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: emptyIsGood ? AppTheme.green50 : null,
              borderRadius: BorderRadius.circular(50),
              border: emptyIsGood ? Border.all(color: const Color(0xFFBBF7D0)) : null,
            ),
            child: Text(emptyText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: emptyIsGood ? AppTheme.green600 : AppTheme.slate400)),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayTags.map((tag) {
              final isSelected = tags.any((t) => t.text == tag.text);
              return GestureDetector(
                onTap: isEditing ? () => onToggle(tag) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: isSelected ? selectedBorderColor : AppTheme.slate100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(tag.icon, size: 12, color: isSelected ? selectedTextColor : AppTheme.slate500),
                      const SizedBox(width: 6),
                      Text(
                        tag.text,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? selectedTextColor : AppTheme.slate500,
                          decoration: (strikethrough && isSelected) ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}