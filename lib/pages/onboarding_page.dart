import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class Tag {
  final String text;
  final IconData icon;

  const Tag(this.text, this.icon);
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 1;
  final int _totalSteps = 6;

  // State for steps
  final TextEditingController _nameController = TextEditingController();
  List<String> _favFoods = [];
  List<String> _allergies = [];
  String _budgetCycle = 'Mingguan';
  final TextEditingController _budgetController = TextEditingController();
  List<String> _missingTools = [];
  int _eatFrequency = 3;

  void _next() {
    if (_step < _totalSteps) {
      setState(() => _step++);
    } else {
      context.go('/app/home');
    }
  }

  void _back() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      context.go('/');
    }
  }

  void _toggleItem(String item, List<String> list, Function(List<String>) setList) {
    if (list.contains(item)) {
      setList(List.from(list)..remove(item));
    } else {
      setList(List.from(list)..add(item));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _back,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.slate50,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.chevron_left, size: 22, color: AppTheme.slate600),
                  ),
                ),
                Text(
                  'Langkah $_step dari $_totalSteps',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.slate800, fontSize: 14),
                ),
                const SizedBox(width: 38),
              ],
            ),
          ),

          // Progress bar
          Container(
            height: 6,
            color: AppTheme.slate100,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _step / _totalSteps,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: AppTheme.orange500,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.orange500.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStep(),
                ),
              ),
            ),
          ),

          // Next button
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _step == _totalSteps ? 'Selesai' : 'Lanjut',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1: return _StepIdentity(controller: _nameController);
      case 2: return _StepFoodPreferences(
        selected: _favFoods,
        onToggle: (item) => setState(() => _toggleItem(item, _favFoods, (v) => _favFoods = v)),
      );
      case 3: return _StepAllergies(
        selected: _allergies,
        onToggle: (item) => setState(() => _toggleItem(item, _allergies, (v) => _allergies = v)),
      );
      case 4: return _StepBudgetCycle(
        cycle: _budgetCycle,
        onCycleChanged: (v) => setState(() => _budgetCycle = v),
        budgetController: _budgetController,
      );
      case 5: return _StepKitchenTools(
        selected: _missingTools,
        onToggle: (item) => setState(() => _toggleItem(item, _missingTools, (v) => _missingTools = v)),
      );
      case 6: return _StepMealFrequency(
        freq: _eatFrequency,
        onChanged: (v) => setState(() => _eatFrequency = v),
      );
      default: return const SizedBox.shrink();
    }
  }
}

// Step 1: Identity
class _StepIdentity extends StatelessWidget {
  final TextEditingController controller;
  const _StepIdentity({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Kenalan Dulu Yuk!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate900, letterSpacing: -0.5)),
            SizedBox(width: 8),
            Icon(Icons.waving_hand, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Isi namamu agar CookCase+ bisa menyapamu dengan akrab.', style: TextStyle(fontSize: 14, color: AppTheme.slate500, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 24),
        const Text('Nama Panggilan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.slate700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Misal: Budi',
            hintStyle: const TextStyle(color: AppTheme.slate300, fontWeight: FontWeight.w500),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.slate200, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.slate200, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.orange500, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppTheme.slate800),
        ),
      ],
    );
  }
}

// Step 2: Food Preferences
class _StepFoodPreferences extends StatelessWidget {
  final List<String> selected;
  final Function(String) onToggle;
  const _StepFoodPreferences({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    const tags = [Tag('Pedas', FontAwesomeIcons.pepperHot as IconData), Tag('Manis', FontAwesomeIcons.candyCane as IconData), Tag('Gurih', FontAwesomeIcons.utensils as IconData), Tag('Asin', FontAwesomeIcons.mortarPestle as IconData), Tag('Ayam', FontAwesomeIcons.drumstickBite as IconData), Tag('Sapi', FontAwesomeIcons.cow as IconData), Tag('Seafood', FontAwesomeIcons.fish as IconData), Tag('Sayuran', FontAwesomeIcons.carrot as IconData)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Makanan Favoritmu?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate900, letterSpacing: -0.5)),
            SizedBox(width: 8),
            Icon(Icons.sentiment_satisfied, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Pilih beberapa rasa dan bahan makanan yang kamu sukai.', style: TextStyle(fontSize: 14, color: AppTheme.slate500, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags.map((tag) {
            final isSelected = selected.contains(tag.text);
            return GestureDetector(
              onTap: () => onToggle(tag.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.orange100 : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isSelected ? AppTheme.orange500 : AppTheme.slate200,
                    width: 2,
                  ),
                  boxShadow: isSelected ? [BoxShadow(color: AppTheme.orange500.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(tag.icon as FaIconData?, size: 14, color: isSelected ? AppTheme.orange700 : AppTheme.slate600),
                    const SizedBox(width: 8),
                    Text(tag.text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? AppTheme.orange700 : AppTheme.slate600)),
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

// Step 3: Allergies
class _StepAllergies extends StatelessWidget {
  final List<String> selected;
  final Function(String) onToggle;
  const _StepAllergies({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    const tags = [Tag('Kacang', FontAwesomeIcons.seedling as IconData), Tag('Susu', FontAwesomeIcons.glassWhiskey as IconData), Tag('Telur', FontAwesomeIcons.egg as IconData), Tag('Seafood', FontAwesomeIcons.fish as IconData), Tag('Gluten', FontAwesomeIcons.breadSlice as IconData), Tag('Kedelai', FontAwesomeIcons.seedling as IconData)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.red50, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFECDD3))),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppTheme.red500, size: 18),
              SizedBox(width: 6),
              Text('PENTING', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.red600, letterSpacing: 1)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ada Alergi Bahan Makanan?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate900, letterSpacing: -0.5)),
            SizedBox(width: 8),
            Icon(Icons.warning, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Bantu kami menghindari bahan yang berbahaya untukmu.', style: TextStyle(fontSize: 14, color: AppTheme.slate500, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags.map((tag) {
            final isSelected = selected.contains(tag.text);
            return GestureDetector(
              onTap: () => onToggle(tag.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.red50 : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: isSelected ? AppTheme.red500 : AppTheme.slate200, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(tag.icon as FaIconData?, size: 14, color: isSelected ? AppTheme.red600 : AppTheme.slate600),
                    const SizedBox(width: 8),
                    Text(tag.text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? AppTheme.red600 : AppTheme.slate600)),
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

// Step 4: Budget Cycle
class _StepBudgetCycle extends StatelessWidget {
  final String cycle;
  final Function(String) onCycleChanged;
  final TextEditingController budgetController;
  const _StepBudgetCycle({required this.cycle, required this.onCycleChanged, required this.budgetController});

  @override
  Widget build(BuildContext context) {
    const options = ['Harian', 'Mingguan', 'Bulanan'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Atur Budget Makan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate900, letterSpacing: -0.5)),
            SizedBox(width: 8),
            Icon(Icons.attach_money, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Pilih siklus pengaturan uang makanmu.', style: TextStyle(fontSize: 14, color: AppTheme.slate500, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.slate200, width: 2),
            // ignore: deprecated_member_use
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: options.map((opt) {
              final isSelected = cycle == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onCycleChanged(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.orange500 : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      // ignore: deprecated_member_use
                      boxShadow: isSelected ? [BoxShadow(color: AppTheme.orange500.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                    ),
                    child: Text(
                      opt,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isSelected ? Colors.white : AppTheme.slate500),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Budget $cycle', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.slate700)),
        const SizedBox(height: 8),
        TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: 'Rp  ',
            prefixStyle: const TextStyle(color: AppTheme.slate400, fontWeight: FontWeight.w700, fontSize: 17),
            hintText: '0',
            hintStyle: const TextStyle(color: AppTheme.slate300, fontWeight: FontWeight.w700),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.slate200, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.slate200, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.orange500, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.slate800),
        ),
      ],
    );
  }
}

// Step 5: Kitchen Tools
class _StepKitchenTools extends StatelessWidget {
  final List<String> selected;
  final Function(String) onToggle;
  const _StepKitchenTools({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    const tools = [
      Tag('Kompor', FontAwesomeIcons.fire as IconData),
      Tag('Oven', FontAwesomeIcons.fire as IconData),
      Tag('Microwave', FontAwesomeIcons.radiation as IconData),
      Tag('Blender', FontAwesomeIcons.blender as IconData),
      Tag('Rice Cooker', FontAwesomeIcons.bowlRice as IconData),
      Tag('Kulkas', FontAwesomeIcons.snowflake as IconData),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Alat Masak yang TIDAK Kamu Miliki?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate900, letterSpacing: -0.5)),
            SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.utensils, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14, color: AppTheme.slate500, fontWeight: FontWeight.w500, height: 1.5),
            children: [
              TextSpan(text: 'Centang alat yang '),
              TextSpan(text: 'tidak ada', style: TextStyle(fontWeight: FontWeight.w900, decoration: TextDecoration.underline, color: AppTheme.slate700)),
              TextSpan(text: ' di dapur atau kosmu.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: tools.map((tool) {
            final isSelected = selected.contains(tool.text);
            return GestureDetector(
              onTap: () => onToggle(tool.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.slate100 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppTheme.slate300 : AppTheme.slate200, width: 2),
                  // ignore: deprecated_member_use
                  boxShadow: isSelected ? null : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(tool.icon as FaIconData?, size: 28, color: isSelected ? AppTheme.slate500 : AppTheme.slate700),
                    const SizedBox(height: 8),
                    Text(
                      tool.text,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isSelected ? AppTheme.slate500 : AppTheme.slate700,
                        decoration: isSelected ? TextDecoration.lineThrough : null,
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

// Step 6: Meal Frequency
class _StepMealFrequency extends StatelessWidget {
  final int freq;
  final Function(int) onChanged;
  const _StepMealFrequency({required this.freq, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Seberapa Sering Kamu Makan?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate900, letterSpacing: -0.5)),
            SizedBox(width: 8),
            Icon(Icons.restaurant, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Termasuk sarapan, makan siang, dan makan malam.', style: TextStyle(fontSize: 14, color: AppTheme.slate500, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.slate100, width: 2),
            // ignore: deprecated_member_use
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Text(
                '$freq',
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: AppTheme.orange500, letterSpacing: -2),
              ),
              const Text('kali sehari', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.slate600, letterSpacing: 0.5)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.slate100,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CounterButton(
                      label: '−',
                      color: Colors.white,
                      textColor: AppTheme.slate700,
                      onTap: () { if (freq > 1) onChanged(freq - 1); },
                    ),
                    const SizedBox(width: 36),
                    _CounterButton(
                      label: '+',
                      color: AppTheme.orange500,
                      textColor: Colors.white,
                      onTap: () { if (freq < 6) onChanged(freq + 1); },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _CounterButton({required this.label, required this.color, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          // ignore: deprecated_member_use
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))],
          border: Border.all(color: AppTheme.slate200),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor)),
        ),
      ),
    );
  }
}