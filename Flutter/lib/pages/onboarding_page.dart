import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 1;
  static const int _totalSteps = 4;

  final List<String> _favFoods = [];
  final List<String> _allergies = [];
  final _allergyCtrl = TextEditingController();
  bool _noAllergy = false;
  final _budgetCtrl = TextEditingController();
  int _mealFreq = 3;

  @override
  void initState() {
    super.initState();
    _budgetCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _allergyCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

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

  void _toggleFood(String item) {
    setState(() {
      _favFoods.contains(item) ? _favFoods.remove(item) : _favFoods.add(item);
    });
  }

  void _toggleAllergy(String item) {
    setState(() {
      if (_noAllergy) _noAllergy = false;
      _allergies.contains(item) ? _allergies.remove(item) : _allergies.add(item);
    });
  }

  void _addCustomAllergy() {
    final val = _allergyCtrl.text.trim();
    if (val.isNotEmpty && !_allergies.contains(val)) {
      setState(() { _allergies.add(val); _allergyCtrl.clear(); });
    }
  }

  bool get _canContinue {
    if (_step == 1) return _favFoods.isNotEmpty;
    if (_step == 2) return _noAllergy || _allergies.isNotEmpty;
    if (_step == 3) return _budgetCtrl.text.trim().isNotEmpty;
    return true;
  }

  static const _stepTitles = ['Selera Makan', 'Alergi', 'Budget Bulanan', 'Jadwal Makan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Column(
        children: [
          // ── Header ──
          Container(
            color: context.colors.cardBackground,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16, right: 16, bottom: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _back,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(50)),
                    child: Icon(Icons.chevron_left, size: 22, color: context.colors.textSecondary),
                  ),
                ),
                Column(children: [
                  Text('Langkah $_step dari $_totalSteps',
                    style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.textPrimary, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(_stepTitles[_step - 1],
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: context.colors.textSecondary)),
                ]),
                const SizedBox(width: 38),
              ],
            ),
          ),

          // ── Progress bar ──
          Stack(children: [
            Container(height: 5, color: context.colors.border),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              widthFactor: _step / _totalSteps,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.orange400, AppTheme.orange600]),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                  boxShadow: [BoxShadow(color: AppTheme.orange500.withValues(alpha: 0.4), blurRadius: 6)],
                ),
              ),
            ),
          ]),

          // ── Step content ──
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildStep(),
                ),
              ),
            ),
          ),

          // ── Bottom button ──
          Container(
            color: context.colors.cardBackground,
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 14,
              bottom: MediaQuery.of(context).padding.bottom + 14,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange600,
                  disabledBackgroundColor: context.colors.border,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_step == _totalSteps ? 'Mulai Masak! 🍳' : 'Lanjut',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  if (_step < _totalSteps) ...[const SizedBox(width: 6), const Icon(Icons.chevron_right, size: 20)],
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1: return _StepFoodPrefs(selected: _favFoods, onToggle: _toggleFood);
      case 2: return _StepAllergies(
        selected: _allergies, noAllergy: _noAllergy,
        controller: _allergyCtrl, onToggle: _toggleAllergy,
        onCustomAdd: _addCustomAllergy,
        onNoAllergy: () => setState(() { _noAllergy = !_noAllergy; if (_noAllergy) _allergies.clear(); }),
      );
      case 3: return _StepBudget(controller: _budgetCtrl);
      case 4: return _StepMealFreq(freq: _mealFreq, onChanged: (v) => setState(() => _mealFreq = v));
      default: return const SizedBox();
    }
  }
}

// ── Step 1: Food Preferences ───────────────────────────────────────────
class _StepFoodPrefs extends StatelessWidget {
  final List<String> selected;
  final Function(String) onToggle;
  const _StepFoodPrefs({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    const groups = [
      {'label': 'Rasa', 'tags': ['Pedas', 'Manis', 'Gurih', 'Asin', 'Asam', 'Umami']},
      {'label': 'Bahan Utama', 'tags': ['Ayam', 'Sapi', 'Ikan', 'Seafood', 'Sayuran', 'Tahu/Tempe', 'Telur']},
      {'label': 'Jenis Masakan', 'tags': ['Nasi', 'Mie', 'Sup/Soto', 'Gorengan', 'Bakar/Panggang']},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Makanan Favoritmu?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Pilih minimal 1. CookCash akan merekomendasikan menu sesuai seleramu.',
          style: TextStyle(fontSize: 13, color: context.colors.textSecondary, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 24),
        ...groups.map((g) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(g['label'] as String,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textHint, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: (g['tags'] as List<String>).map((tag) {
              final isSel = selected.contains(tag);
              return GestureDetector(
                onTap: () => onToggle(tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.orange500 : context.colors.cardBackground,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: isSel ? AppTheme.orange500 : context.colors.border, width: 1.5),
                    boxShadow: isSel ? [BoxShadow(color: AppTheme.orange500.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))] : null,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (isSel) ...[const Icon(Icons.check_rounded, size: 14, color: Colors.white), const SizedBox(width: 4)],
                    Text(tag, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSel ? Colors.white : context.colors.textSecondary)),
                  ]),
                ),
              );
            }).toList()),
            const SizedBox(height: 16),
          ],
        )),
      ],
    );
  }
}

// ── Step 2: Allergies ──────────────────────────────────────────────────
class _StepAllergies extends StatelessWidget {
  final List<String> selected;
  final bool noAllergy;
  final TextEditingController controller;
  final Function(String) onToggle;
  final VoidCallback onCustomAdd;
  final VoidCallback onNoAllergy;
  const _StepAllergies({required this.selected, required this.noAllergy, required this.controller, required this.onToggle, required this.onCustomAdd, required this.onNoAllergy});

  @override
  Widget build(BuildContext context) {
    const presets = ['Kacang', 'Susu', 'Telur', 'Seafood', 'Gluten', 'Kedelai', 'Wijen', 'Udang'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppTheme.red50, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.red200)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.red500, size: 14),
            SizedBox(width: 4),
            Text('PENTING', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.red600, letterSpacing: 0.5)),
          ]),
        ),
        const SizedBox(height: 12),
        Text('Ada Alergi Bahan Makanan?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Pilih dari daftar atau ketik sendiri. Kami tidak akan merekomendasikan bahan ini.',
          style: TextStyle(fontSize: 13, color: context.colors.textSecondary, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 20),

        // No allergy toggle
        GestureDetector(
          onTap: onNoAllergy,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: noAllergy ? AppTheme.green50 : context.colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: noAllergy ? AppTheme.green500 : context.colors.border, width: 2),
            ),
            child: Row(children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: noAllergy ? AppTheme.green500 : context.colors.cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: noAllergy ? AppTheme.green500 : context.colors.textHint, width: 2),
                ),
                child: noAllergy ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tidak Ada Alergi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: context.colors.textPrimary)),
                Text('Saya bisa makan semua bahan makanan', style: TextStyle(fontSize: 12, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
              ])),
            ]),
          ),
        ),

        const SizedBox(height: 16),

        if (!noAllergy) ...[
          Text('Pilih dari daftar:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textHint, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: presets.map((tag) {
            final isSel = selected.contains(tag);
            return GestureDetector(
              onTap: () => onToggle(tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSel ? AppTheme.red50 : context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: isSel ? AppTheme.red500 : context.colors.border, width: 1.5),
                ),
                child: Text(tag, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSel ? AppTheme.red600 : context.colors.textSecondary)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),

          Text('Atau ketik sendiri:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textHint, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onCustomAdd(),
                decoration: InputDecoration(
                  hintText: 'Contoh: Durian, Petai...',
                  hintStyle: TextStyle(color: context.colors.textHint, fontWeight: FontWeight.w500, fontSize: 14),
                  filled: true, fillColor: context.colors.cardBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.colors.border, width: 1.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.colors.border, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.orange500, width: 2)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onCustomAdd,
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: AppTheme.orange600, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ]),

          if (selected.any((s) => !presets.contains(s))) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8,
              children: selected.where((s) => !presets.contains(s)).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: AppTheme.red50, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppTheme.red200)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(tag, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.red600)),
                  const SizedBox(width: 6),
                  GestureDetector(onTap: () => onToggle(tag), child: const Icon(Icons.close, size: 14, color: AppTheme.red600)),
                ]),
              )).toList(),
            ),
          ],
        ],
      ],
    );
  }
}

// ── Step 3: Budget ─────────────────────────────────────────────────────
class _StepBudget extends StatelessWidget {
  final TextEditingController controller;
  const _StepBudget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Makan Bulanan 💰', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Berapa total budget makan kamu dalam sebulan? CookCash akan memantau pengeluaran agar kamu tidak defisit.',
          style: TextStyle(fontSize: 13, color: context.colors.textSecondary, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Budget Bulanan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.textSecondary, letterSpacing: 0.3)),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('Rp', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.colors.textHint)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: context.colors.border),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Divider(color: AppTheme.orange500.withValues(alpha: 0.4), thickness: 2),
          ]),
        ),
        const SizedBox(height: 16),
        Text('Pilih cepat:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textHint, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: ['300.000', '500.000', '750.000', '1.000.000'].map((v) {
          return GestureDetector(
            onTap: () => controller.text = v.replaceAll('.', ''),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: AppTheme.orange50, borderRadius: BorderRadius.circular(50), border: Border.all(color: AppTheme.orange200)),
              child: Text('Rp $v', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.orange700)),
            ),
          );
        }).toList()),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.blue50, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.blue100)),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.blue500, size: 16),
            SizedBox(width: 8),
            Expanded(child: Text('Budget ini dibagi otomatis per hari. Kamu bisa ubah kapanpun di Pengaturan.',
              style: TextStyle(fontSize: 12, color: AppTheme.blue700, fontWeight: FontWeight.w500, height: 1.5))),
          ]),
        ),
      ],
    );
  }
}

// ── Step 4: Meal Frequency ─────────────────────────────────────────────
class _StepMealFreq extends StatelessWidget {
  final int freq;
  final Function(int) onChanged;
  const _StepMealFreq({required this.freq, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      {'val': 2, 'label': '2 kali', 'desc': 'Siang & Malam', 'icon': '🍽️'},
      {'val': 3, 'label': '3 kali', 'desc': 'Sarapan, Siang & Malam', 'icon': '🍳🍱🌙'},
      {'val': 4, 'label': '4 kali', 'desc': '3 makan + 1 cemilan', 'icon': '🍳🍱🍪🌙'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jadwal Makan Sehari 🕐', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Berapa kali kamu biasanya makan dalam sehari? Ini membantu kami membagi budget dan rekomendasi menu.',
          style: TextStyle(fontSize: 13, color: context.colors.textSecondary, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 28),
        Column(children: options.map((opt) {
          final val = opt['val'] as int;
          final isSel = freq == val;
          return GestureDetector(
            onTap: () => onChanged(val),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSel ? AppTheme.orange50 : context.colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSel ? AppTheme.orange500 : context.colors.border, width: 2),
                boxShadow: isSel
                    ? [BoxShadow(color: AppTheme.orange500.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 3))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSel ? AppTheme.orange500 : context.colors.textHint, width: 2)),
                  child: isSel ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.orange500, shape: BoxShape.circle))) : null,
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(opt['label'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16,
                    color: isSel ? AppTheme.orange700 : context.colors.textPrimary, letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text(opt['desc'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                    color: isSel ? AppTheme.orange600 : context.colors.textSecondary)),
                ])),
                Text(opt['icon'] as String, style: const TextStyle(fontSize: 18)),
              ]),
            ),
          );
        }).toList()),
      ],
    );
  }
}