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

  @override
  void initState() {
    super.initState();
    _budgetCtrl.addListener(() {
      setState(() {});
    });
  }
  int _mealFreq = 3;

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
      // JIKA DI LANGKAH PERTAMA LALU DITEKAN BACK, KEMBALI KE GUEST MODE
      context.go('/');
    }
  }

  void _toggleItem(
      String item, List<String> list, Function(List<String>) setList) {
    if (list.contains(item)) {
      setList(List.from(list)..remove(item));
    } else {
      setList(List.from(list)..add(item));
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

  @override
  void dispose() {
    _allergyCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Column(
        children: [
          Container(
            color: context.colors.cardBackground,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
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
                    child: const Icon(Icons.chevron_left,
                        size: 22, color: AppTheme.slate600),
                  ),
                ),
                Text(
                  'Langkah $_step dari $_totalSteps',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.slate800,
                      fontSize: 14),
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(50)), child: Icon(Icons.chevron_left, size: 22, color: context.colors.textSecondary)),
                ),
                Column(children: [
                  Text('Langkah $_step dari $_totalSteps', style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.textPrimary, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(['Selera Makan', 'Alergi', 'Budget Bulanan', 'Jadwal Makan'][_step - 1],
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: context.colors.surface)),
                ]),
                const SizedBox(width: 38),
              ],
            ),
          ),
          Stack(children: [
            Container(height: 5, color: context.colors.border),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              widthFactor: _step / _totalSteps,
              child: Container(height: 5, decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.orange400, AppTheme.orange600]),
                borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                boxShadow: [BoxShadow(color: AppTheme.orange500.withValues(alpha: 0.4), blurRadius: 6)],
              )),
            ),
          ]),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
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

          Container(
            color: context.colors.cardBackground,
            padding: EdgeInsets.only(left: 24, right: 24, top: 14, bottom: MediaQuery.of(context).padding.bottom + 14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _step == _totalSteps ? 'Selesai' : 'Lanjut',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                  disabledBackgroundColor: context.colors.border,
                  foregroundColor: context.colors.cardBackground,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_step == _totalSteps ? 'Mulai Masak! ??' : 'Lanjut', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
      case 1:
        return _StepIdentity(controller: _nameController);
      case 2:
        return _StepFoodPreferences(
          selected: _favFoods,
          onToggle: (item) => setState(
              () => _toggleItem(item, _favFoods, (v) => _favFoods = v)),
        );
      case 3:
        return _StepAllergies(
          selected: _allergies,
          onToggle: (item) => setState(
              () => _toggleItem(item, _allergies, (v) => _allergies = v)),
        );
      case 4:
        return _StepBudgetCycle(
          cycle: _budgetCycle,
          onCycleChanged: (v) => setState(() => _budgetCycle = v),
          budgetController: _budgetController,
        );
      case 5:
        return _StepKitchenTools(
          selected: _missingTools,
          onToggle: (item) => setState(
              () => _toggleItem(item, _missingTools, (v) => _missingTools = v)),
        );
      case 6:
        return _StepMealFrequency(
          freq: _eatFrequency,
          onChanged: (v) => setState(() => _eatFrequency = v),
        );
      default:
        return const SizedBox.shrink();
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
            Text('Kenalan Dulu Yuk!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.slate900,
                    letterSpacing: -0.5)),
            SizedBox(width: 8),
            Icon(Icons.waving_hand, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Isi namamu agar CookCase+ bisa menyapamu dengan akrab.',
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.slate500,
                fontWeight: FontWeight.w500,
                height: 1.5)),
        const SizedBox(height: 24),
        const Text('Nama Panggilan',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.slate700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Misal: Budi',
            hintStyle: const TextStyle(
                color: AppTheme.slate300, fontWeight: FontWeight.w500),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppTheme.slate200, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppTheme.slate200, width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppTheme.orange500, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.slate800),
        ),
      ],
    );
  }
}

// Step 2: Food Preferences
class _StepFoodPreferences extends StatelessWidget {
      case 1: return _StepFoodPrefs(selected: _favFoods, onToggle: _toggleFood);
      case 2: return _StepAllergies(selected: _allergies, noAllergy: _noAllergy, controller: _allergyCtrl, onToggle: _toggleAllergy, onCustomAdd: _addCustomAllergy, onNoAllergy: () => setState(() { _noAllergy = !_noAllergy; if (_noAllergy) _allergies.clear(); }));
      case 3: return _StepBudget(controller: _budgetCtrl);
      case 4: return _StepMealFreq(freq: _mealFreq, onChanged: (v) => setState(() => _mealFreq = v));
      default: return const SizedBox();
    }
  }
}
class _StepFoodPrefs extends StatelessWidget {
  final List<String> selected;
  final Function(String) onToggle;
  const _StepFoodPrefs({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    const tags = [
      Tag('Pedas', FontAwesomeIcons.pepperHot),
      Tag('Manis', FontAwesomeIcons.candyCane),
      Tag('Gurih', FontAwesomeIcons.utensils),
      Tag('Asin', FontAwesomeIcons.mortarPestle),
      Tag('Ayam', FontAwesomeIcons.drumstickBite),
      Tag('Sapi', FontAwesomeIcons.cow),
      Tag('Seafood', FontAwesomeIcons.fish),
      Tag('Sayuran', FontAwesomeIcons.carrot)
    const groups = [
      {'label': 'Rasa', 'tags': ['Pedas', 'Manis', 'Gurih', 'Asin', 'Asam', 'Umami']},
      {'label': 'Bahan Utama', 'tags': ['Ayam', 'Sapi', 'Ikan', 'Seafood', 'Sayuran', 'Tahu/Tempe', 'Telur']},
      {'label': 'Jenis Masakan', 'tags': ['Nasi', 'Mie', 'Sup/Soto', 'Gorengan', 'Bakar/Panggang']},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Makanan Favoritmu?',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.slate900,
                    letterSpacing: -0.5)),
            SizedBox(width: 8),
            Icon(Icons.sentiment_satisfied, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Pilih beberapa rasa dan bahan makanan yang kamu sukai.',
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.slate500,
                fontWeight: FontWeight.w500,
                height: 1.5)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.orange100 : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isSelected ? AppTheme.orange500 : AppTheme.slate200,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: AppTheme.orange500.withValues(alpha: 51),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(tag.icon,
                        size: 14,
                        color: isSelected
                            ? AppTheme.orange700
                            : AppTheme.slate600),
                    const SizedBox(width: 8),
                    Text(tag.text,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isSelected
                                ? AppTheme.orange700
                                : AppTheme.slate600)),
                  ],
        const Text('Makanan Favoritmu?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate900, letterSpacing: -0.5)),
        const SizedBox(height: 6),
         Text('Pilih minimal 1. CookCase+ akan merekomendasikan menu sesuai seleramu.', style: TextStyle(fontSize: 13, color: context.colors.surface, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 24),
        ...(groups).map((g) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(g['label'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textHint, letterSpacing: 0.5)),
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
                    boxShadow: isSel ? [BoxShadow(color: AppTheme.orange500.withValues(alpha:0.25), blurRadius: 8, offset: const Offset(0, 2))] : null,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (isSel) ...[Icon(Icons.check_rounded, size: 14, color: context.colors.cardBackground), const SizedBox(width: 4)],
                    Text(tag, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSel ? context.colors.cardBackground : context.colors.textSecondary)),
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
    const tags = [
      Tag('Kacang', FontAwesomeIcons.seedling),
      Tag('Susu', FontAwesomeIcons.whiskeyGlass),
      Tag('Telur', FontAwesomeIcons.egg),
      Tag('Seafood', FontAwesomeIcons.fish),
      Tag('Gluten', FontAwesomeIcons.breadSlice),
      Tag('Kedelai', FontAwesomeIcons.seedling)
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppTheme.red50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECDD3))),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppTheme.red500, size: 18),
              SizedBox(width: 6),
              Text('PENTING',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppTheme.red600,
                      letterSpacing: 1)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ada Alergi Bahan Makanan?',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.slate900,
                    letterSpacing: -0.5)),
            SizedBox(width: 8),
            Icon(Icons.warning, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Bantu kami menghindari bahan yang berbahaya untukmu.',
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.slate500,
                fontWeight: FontWeight.w500,
                height: 1.5)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags.map((tag) {
            final isSelected = selected.contains(tag.text);
    const presets = ['Kacang ??', 'Susu ??', 'Telur ??', 'Seafood ??', 'Gluten ??', 'Kedelai ??', 'Wijen ??', 'Udang ??'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppTheme.red50, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFECDD3))),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.warning_amber_rounded, color: AppTheme.red500, size: 14), SizedBox(width: 4), Text('PENTING', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.red600, letterSpacing: 0.5))])),
        const SizedBox(height: 12),
        const Text('Ada Alergi Bahan Makanan? ??', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate900, letterSpacing: -0.5)),
        const SizedBox(height: 6),
         Text('Pilih dari daftar atau ketik sendiri. Kami tidak akan merekomendasikan bahan ini.', style: TextStyle(fontSize: 13, color: context.colors.surface, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 20),
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
              Container(width: 20, height: 20, decoration: BoxDecoration(color: noAllergy ? AppTheme.green500 : context.colors.cardBackground, shape: BoxShape.circle, border: Border.all(color: noAllergy ? AppTheme.green500 : context.colors.textHint, width: 2)),
                child: noAllergy ? Icon(Icons.check, size: 13, color: context.colors.cardBackground) : null),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tidak Ada Alergi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: context.colors.textPrimary)),
                Text('Saya bisa makan semua bahan makanan', style: TextStyle(fontSize: 12, color: context.colors.surface, fontWeight: FontWeight.w500)),
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
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSel ? AppTheme.red50 : context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: isSelected ? AppTheme.red500 : AppTheme.slate200,
                      width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(tag.icon as FaIconData?,
                        size: 14,
                        color:
                            isSelected ? AppTheme.red600 : AppTheme.slate600),
                    const SizedBox(width: 8),
                    Text(tag.text,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isSelected
                                ? AppTheme.red600
                                : AppTheme.slate600)),
                  ],
                  border: Border.all(color: isSel ? AppTheme.red500 : context.colors.border, width: 1.5),
                ),
                child: Text(tag, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSel ? AppTheme.red600 : context.colors.textSecondary)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),

// Step 4: Budget Cycle
class _StepBudgetCycle extends StatelessWidget {
  final String cycle;
  final Function(String) onCycleChanged;
  final TextEditingController budgetController;
  const _StepBudgetCycle(
      {required this.cycle,
      required this.onCycleChanged,
      required this.budgetController});

  @override
  Widget build(BuildContext context) {
    const options = ['Harian', 'Mingguan', 'Bulanan'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Atur Budget Makan',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.slate900,
                    letterSpacing: -0.5)),
            SizedBox(width: 8),
            Icon(Icons.attach_money, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Pilih siklus pengaturan uang makanmu.',
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.slate500,
                fontWeight: FontWeight.w500,
                height: 1.5)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.slate200, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 10.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
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
                      color:
                          isSelected ? AppTheme.orange500 : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: AppTheme.orange500
                                      .withValues(alpha: 76.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ]
                          : null,
                    ),
                    child: Text(
                      opt,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isSelected ? Colors.white : AppTheme.slate500),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Budget $cycle',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.slate700)),
        const SizedBox(height: 8),
        TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: 'Rp  ',
            prefixStyle: const TextStyle(
                color: AppTheme.slate400,
                fontWeight: FontWeight.w700,
                fontSize: 17),
            hintText: '0',
            hintStyle: const TextStyle(
                color: AppTheme.slate300, fontWeight: FontWeight.w700),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppTheme.slate200, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppTheme.slate200, width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppTheme.orange500, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.slate800),
        ),
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
                child: Icon(Icons.add, color: context.colors.cardBackground, size: 22),
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

class _StepBudget extends StatelessWidget {
  final TextEditingController controller;
  const _StepBudget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Alat Masak yang TIDAK Kamu Miliki?',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.slate900,
                    letterSpacing: -0.5)),
            SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.utensils,
                size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.slate500,
                fontWeight: FontWeight.w500,
                height: 1.5),
            children: [
              TextSpan(text: 'Centang alat yang '),
              TextSpan(
                  text: 'tidak ada',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                      color: AppTheme.slate700)),
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
                  border: Border.all(
                      color: isSelected ? AppTheme.slate300 : AppTheme.slate200,
                      width: 2),
                  boxShadow: isSelected
                      ? null
                      : [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 10.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(tool.icon as FaIconData?,
                        size: 28,
                        color:
                            isSelected ? AppTheme.slate500 : AppTheme.slate700),
                    const SizedBox(height: 8),
                    Text(
                      tool.text,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color:
                            isSelected ? AppTheme.slate500 : AppTheme.slate700,
                        decoration:
                            isSelected ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
        const Text('Budget Makan Bulanan ??', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate900, letterSpacing: -0.5)),
        const SizedBox(height: 6),
         Text('Berapa total budget makan kamu dalam sebulan? CookCase+ akan memantau pengeluaran agar kamu tidak defisit.', style: TextStyle(fontSize: 13, color: context.colors.surface, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: context.colors.cardBackground, borderRadius: BorderRadius.circular(20), border: Border.all(color: context.colors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Budget Bulanan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.surface, letterSpacing: 0.3)),
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
                  decoration: InputDecoration(hintText: '0', hintStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: context.colors.border), border: InputBorder.none),
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
              decoration: BoxDecoration(
                color: AppTheme.orange50, borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppTheme.orange200),
              ),
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
            Expanded(child: Text('Budget ini dibagi otomatis per hari. Kamu bisa ubah kapanpun di Pengaturan.', style: TextStyle(fontSize: 12, color: AppTheme.blue700, fontWeight: FontWeight.w500, height: 1.5))),
          ]),
        ),
      ],
    );
  }
}
class _StepMealFreq extends StatelessWidget {
  final int freq;
  final Function(int) onChanged;
  const _StepMealFreq({required this.freq, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      {'val': 2, 'label': '2 kali', 'desc': 'Siang & Malam', 'icon': '???'},
      {'val': 3, 'label': '3 kali', 'desc': 'Sarapan, Siang & Malam', 'icon': '?????????'},
      {'val': 4, 'label': '4 kali', 'desc': '3 makan + 1 cemilan', 'icon': '???????????'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Seberapa Sering Kamu Makan?',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.slate900,
                    letterSpacing: -0.5)),
            SizedBox(width: 8),
            Icon(Icons.restaurant, size: 24, color: AppTheme.slate900),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Termasuk sarapan, makan siang, dan makan malam.',
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.slate500,
                fontWeight: FontWeight.w500,
                height: 1.5)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.slate100, width: 2),
            // ignore: deprecated_member_use
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 10.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Text(
                '$freq',
                style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.orange500,
                    letterSpacing: -2),
              ),
              const Text('kali sehari',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.slate600,
                      letterSpacing: 0.5)),
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
                      onTap: () {
                        if (freq > 1) onChanged(freq - 1);
                      },
                    ),
                    const SizedBox(width: 36),
                    _CounterButton(
                      label: '+',
                      color: AppTheme.orange500,
                      textColor: Colors.white,
                      onTap: () {
                        if (freq < 6) onChanged(freq + 1);
                      },
                    ),
                  ],
                ),
        const Text('Jadwal Makan Sehari ???', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.slate900, letterSpacing: -0.5)),
        const SizedBox(height: 6),
         Text('Berapa kali kamu biasanya makan dalam sehari? Ini membantu kami membagi budget dan rekomendasi menu.', style: TextStyle(fontSize: 13, color: context.colors.surface, fontWeight: FontWeight.w500, height: 1.5)),
        const SizedBox(height: 28),
        Column(children: (options).map((opt) {
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
                boxShadow: isSel ? [BoxShadow(color: AppTheme.orange500.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 3))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(children: [
                Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSel ? AppTheme.orange500 : context.colors.textHint, width: 2)),
                  child: isSel ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.orange500, shape: BoxShape.circle))) : null),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(opt['label'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isSel ? AppTheme.orange700 : context.colors.textPrimary, letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text(opt['desc'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSel ? AppTheme.orange600 : context.colors.surface)),
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

class _CounterButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _CounterButton(
      {required this.label,
      required this.color,
      required this.textColor,
      required this.onTap});

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
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 20.4),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
          border: Border.all(color: AppTheme.slate200),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, color: textColor)),
        ),
      ),
    );
  }
}
