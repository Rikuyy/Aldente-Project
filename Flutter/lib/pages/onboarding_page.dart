// onboarding_page.dart (FULL)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 1;
  static const int _totalSteps = 4;

  // STEP 1
  List<String> _selectedCategories = [];
  List<String> _availableCategories = [];
  bool _isLoadingCategories = true;
  String? _loadCategoriesError;

  // STEP 2
  final List<String> _allergies = [];
  final TextEditingController _allergyCtrl = TextEditingController();
  bool _noAllergy = false;

  // STEP 3
  final TextEditingController _budgetCtrl = TextEditingController();

  // STEP 4
  int _mealFreq = 3;

  bool _isSaving = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAlreadyOnboarded();
    _budgetCtrl.addListener(() => setState(() {}));
  }

  Future<void> _checkAlreadyOnboarded() async {
    setState(() => _isChecking = true);

    bool backendOnboarded = false;
    try {
      final response = await ApiService.get('/profile');
      if (response['success'] == true) {
        backendOnboarded = response['data']?['status_onboarding'] ?? false;
      }
    } catch (e) {
      print('Error checking backend onboarding: $e');
    }

    if (backendOnboarded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      if (mounted) {
        context.go('/app/home');
      }
      return;
    }

    setState(() => _isChecking = false);
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _loadCategoriesError = null;
    });
    try {
      final response = await ApiService.get('/resep/categories');

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil kategori');
      }

      final raw = response['categories'];
      if (raw is! List) {
        throw Exception('Format kategori tidak dikenal');
      }

      final List<String> categories = (raw as List)
          .map<String>((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList();

      if (categories.isEmpty) {
        throw Exception('Belum ada kategori resep di database');
      }

      setState(() => _availableCategories = categories);
    } catch (e) {
      print('ERROR fetch categories: $e');
      setState(() => _loadCategoriesError = 'Gagal memuat kategori: $e');
      _showError(
          'Gagal memuat kategori makanan. Periksa koneksi atau backend.');
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _saveAndContinue() async {
    // Validasi tiap step
    if (_step == 1 && _selectedCategories.length < 2) {
      _showError('Pilih minimal 2 kategori makanan favorit');
      return;
    }
    if (_step == 2 && !_noAllergy && _allergies.isEmpty) {
      _showError('Pilih alergi atau centang "Tidak Ada Alergi"');
      return;
    }
    if (_step == 3) {
      final clean = _budgetCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      final budget = int.tryParse(clean);
      if (clean.isEmpty || budget == null || budget <= 0) {
        _showError('Masukkan budget bulanan yang valid');
        return;
      }
    }

    if (_step < _totalSteps) {
      setState(() => _step++);
      return;
    }

    // STEP 4: Submit ke backend
    setState(() => _isSaving = true);
    try {
      final cleanBudget =
          _budgetCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');

      // Kirim Alergi: null jika _noAllergy true, else array _allergies
      final Map<String, dynamic> payload = {
        'Kategori_Favorit': _selectedCategories,
        'Alergi': _noAllergy ? null : _allergies,
        'Budget_Bulanan': int.parse(cleanBudget),
        'Jumlah_Makan': _mealFreq,
      };

<<<<<<< Updated upstream
      print('Onboarding payload: $payload');

      final response = await ApiService.post('/onboarding', payload);
=======
      final response = await ApiService.put('/profile/onboarding', payload);
      // ignore: avoid_print
      print('Onboarding PUT response: $response');
>>>>>>> Stashed changes

      if (!mounted) return;

      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_completed', true);
        context.go('/app/home');
      } else {
        _showError(response['message']?.toString() ?? 'Gagal menyimpan data');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _next() async {
    if (_isSaving) return;
    await _saveAndContinue();
  }

  void _back() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      context.go('/');
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _toggleAllergy(String item) {
    setState(() {
      if (_noAllergy) _noAllergy = false;
      if (_allergies.contains(item)) {
        _allergies.remove(item);
      } else {
        _allergies.add(item);
      }
    });
  }

  void _addCustomAllergy() {
    final val = _allergyCtrl.text.trim();
    if (val.isNotEmpty && !_allergies.contains(val)) {
      setState(() {
        _allergies.add(val);
        _allergyCtrl.clear();
      });
    }
  }

  bool get _canContinue {
    if (_step == 1) return _selectedCategories.length >= 2;
    if (_step == 2) return _noAllergy || _allergies.isNotEmpty;
    if (_step == 3) {
      final clean = _budgetCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      final budget = int.tryParse(clean);
      return budget != null && budget > 0;
    }
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
    if (_isChecking) {
      return Scaffold(
        backgroundColor: context.colors.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Column(
        children: [
          // Header
          Container(
            color: context.colors.cardBackground,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _back,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(50)),
                    child: Icon(Icons.chevron_left,
                        size: 22, color: context.colors.textSecondary),
                  ),
                ),
                Column(children: [
                  Text('Langkah $_step dari $_totalSteps',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                      [
                        'Selera Makan',
                        'Alergi',
                        'Budget Bulanan',
                        'Jadwal Makan'
                      ][_step - 1],
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.colors.surface)),
                ]),
                const SizedBox(width: 38),
              ],
            ),
          ),

          // Progress bar
          Stack(children: [
            Container(height: 5, color: context.colors.border),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              widthFactor: _step / _totalSteps,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.orange400, AppTheme.orange600]),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.orange500.withValues(alpha: 0.4),
                        blurRadius: 6)
                  ],
                ),
              ),
            ),
          ]),

          // Step content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0.08, 0), end: Offset.zero)
                    .animate(
                        CurvedAnimation(parent: anim, curve: Curves.easeOut)),
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

          // Tombol Lanjut / Mulai Masak
          Container(
            color: context.colors.cardBackground,
            padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 14,
                bottom: MediaQuery.of(context).padding.bottom + 14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue && !_isSaving ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange600,
                  disabledBackgroundColor: context.colors.border,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_step == _totalSteps ? 'Mulai Masak' : 'Lanjut'),
                          if (_step < _totalSteps) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
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
      case 1:
        if (_isLoadingCategories) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (_loadCategoriesError != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 60),
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(_loadCategoriesError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: _fetchCategories,
                    child: const Text('Coba Lagi')),
              ],
            ),
          );
        }
        return _StepCategoryPrefs(
          selected: _selectedCategories,
          available: _availableCategories,
          onToggle: _toggleCategory,
        );
      case 2:
        return _StepAllergies(
          selected: _allergies,
          noAllergy: _noAllergy,
          controller: _allergyCtrl,
          onToggle: _toggleAllergy,
          onCustomAdd: _addCustomAllergy,
          onNoAllergy: () => setState(() {
            _noAllergy = !_noAllergy;
            if (_noAllergy) _allergies.clear();
          }),
        );
      case 3:
        return _StepBudget(controller: _budgetCtrl);
      case 4:
        return _StepMealFreq(
            freq: _mealFreq, onChanged: (v) => setState(() => _mealFreq = v));
      default:
        return const SizedBox();
    }
  }
}

class _StepCategoryPrefs extends StatelessWidget {
  final List<String> selected;
  final List<String> available;
  final Function(String) onToggle;
  const _StepCategoryPrefs({
    required this.selected,
    required this.available,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori Makanan Favoritmu?',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.slate900,
                letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text(
            'Pilih minimal 2 kategori. CookMate akan merekomendasikan resep sesuai favoritmu.',
            style: TextStyle(
                fontSize: 13,
                color: context.colors.surface,
                fontWeight: FontWeight.w500,
                height: 1.5)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: available.map((category) {
            final isSelected = selected.contains(category);
            return GestureDetector(
              onTap: () => onToggle(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.orange500
                      : context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: isSelected
                          ? AppTheme.orange500
                          : context.colors.border,
                      width: 1.5),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: AppTheme.orange500.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (isSelected) ...[
                    Icon(Icons.check_rounded,
                        size: 14, color: context.colors.cardBackground),
                    const SizedBox(width: 4),
                  ],
                  Text(category,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isSelected
                              ? context.colors.cardBackground
                              : context.colors.textSecondary)),
                ]),
              ),
            );
          }).toList(),
        ),
        if (available.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
                'Tidak ada kategori ditemukan. Silakan coba lagi nanti.',
                style: TextStyle(color: Colors.red)),
          ),
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
  const _StepAllergies({
    required this.selected,
    required this.noAllergy,
    required this.controller,
    required this.onToggle,
    required this.onCustomAdd,
    required this.onNoAllergy,
  });

  @override
  Widget build(BuildContext context) {
    const presets = [
      'Kacang',
      'Susu',
      'Telur',
      'Seafood',
      'Gluten',
      'Kedelai',
      'Wijen',
      'Udang',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: AppTheme.red50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECDD3))),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.red500, size: 14),
            SizedBox(width: 4),
            Text('PENTING',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: AppTheme.red600,
                    letterSpacing: 0.5)),
          ]),
        ),
        const SizedBox(height: 12),
        const Text('Ada Alergi Bahan Makanan?',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.slate900,
                letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text(
            'Pilih dari daftar atau ketik sendiri. Kami tidak akan merekomendasikan bahan ini.',
            style: TextStyle(
                fontSize: 13,
                color: context.colors.surface,
                fontWeight: FontWeight.w500,
                height: 1.5)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onNoAllergy,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  noAllergy ? AppTheme.green50 : context.colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: noAllergy ? AppTheme.green500 : context.colors.border,
                  width: 2),
            ),
            child: Row(children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: noAllergy
                        ? AppTheme.green500
                        : context.colors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: noAllergy
                            ? AppTheme.green500
                            : context.colors.textHint,
                        width: 2)),
                child: noAllergy
                    ? Icon(Icons.check,
                        size: 13, color: context.colors.cardBackground)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Tidak Ada Alergi',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: context.colors.textPrimary)),
                    Text('Saya bisa makan semua bahan makanan',
                        style: TextStyle(
                            fontSize: 12,
                            color: context.colors.surface,
                            fontWeight: FontWeight.w500)),
                  ])),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        if (!noAllergy) ...[
          Text('Pilih dari daftar:',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textHint,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((tag) {
              final isSel = selected.contains(tag);
              return GestureDetector(
                onTap: () => onToggle(tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSel ? AppTheme.red50 : context.colors.cardBackground,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: isSel ? AppTheme.red500 : context.colors.border,
                        width: 1.5),
                  ),
                  child: Text(tag,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isSel
                              ? AppTheme.red600
                              : context.colors.textSecondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Atau ketik sendiri:',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textHint,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onCustomAdd(),
                decoration: InputDecoration(
                  hintText: 'Contoh: Durian, Petai',
                  hintStyle: TextStyle(
                      color: context.colors.textHint,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                  filled: true,
                  fillColor: context.colors.cardBackground,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: context.colors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: context.colors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppTheme.orange500, width: 2)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onCustomAdd,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: AppTheme.orange600,
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.add,
                    color: context.colors.cardBackground, size: 22),
              ),
            ),
          ]),
          if (selected.any((s) => !presets.contains(s))) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selected
                  .where((s) => !presets.contains(s))
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                            color: AppTheme.red50,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: AppTheme.red200)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(tag,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppTheme.red600)),
                          const SizedBox(width: 6),
                          GestureDetector(
                              onTap: () => onToggle(tag),
                              child: const Icon(Icons.close,
                                  size: 14, color: AppTheme.red600)),
                        ]),
                      ))
                  .toList(),
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
        const Text('Budget Makan Bulanan',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.slate900,
                letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text(
            'Berapa total budget makan kamu dalam sebulan? CookMate akan memantau pengeluaran agar kamu tidak defisit.',
            style: TextStyle(
                fontSize: 13,
                color: context.colors.surface,
                fontWeight: FontWeight.w500,
                height: 1.5)),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: context.colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budget Bulanan',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.colors.surface,
                      letterSpacing: 0.3)),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text('Rp',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textHint)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.5),
                    decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: context.colors.border),
                        border: InputBorder.none),
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Divider(
                  color: AppTheme.orange500.withValues(alpha: 0.4),
                  thickness: 2),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Pilih cepat:',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: context.colors.textHint,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['300.000', '500.000', '750.000', '1.000.000'].map((v) {
            return GestureDetector(
              onTap: () => controller.text = v.replaceAll('.', ''),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.orange50,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppTheme.orange200),
                ),
                child: Text('Rp $v',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.orange700)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.blue50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.blue100)),
          child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppTheme.blue500, size: 16),
                SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Budget ini dibagi otomatis per hari. Kamu bisa ubah kapanpun di Pengaturan.',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.blue700,
                            fontWeight: FontWeight.w500,
                            height: 1.5))),
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
      {'val': 2, 'label': '2 kali', 'desc': 'Siang & Malam'},
      {'val': 3, 'label': '3 kali', 'desc': 'Sarapan, Siang & Malam'},
      {'val': 4, 'label': '4 kali', 'desc': '3 makan + 1 cemilan'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jadwal Makan Sehari',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.slate900,
                letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text(
            'Berapa kali kamu biasanya makan dalam sehari? Ini membantu kami membagi budget dan rekomendasi menu.',
            style: TextStyle(
                fontSize: 13,
                color: context.colors.surface,
                fontWeight: FontWeight.w500,
                height: 1.5)),
        const SizedBox(height: 28),
        Column(
          children: options.map((opt) {
            final val = opt['val'] as int;
            final isSel = freq == val;
            return GestureDetector(
              onTap: () => onChanged(val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color:
                      isSel ? AppTheme.orange50 : context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isSel ? AppTheme.orange500 : context.colors.border,
                      width: 2),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                              color: AppTheme.orange500.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ]
                      : [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                ),
                child: Row(children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: isSel
                                ? AppTheme.orange500
                                : context.colors.textHint,
                            width: 2)),
                    child: isSel
                        ? Center(
                            child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                    color: AppTheme.orange500,
                                    shape: BoxShape.circle)))
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(opt['label'] as String,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: isSel
                                    ? AppTheme.orange700
                                    : context.colors.textPrimary,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 2),
                        Text(opt['desc'] as String,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSel
                                    ? AppTheme.orange600
                                    : context.colors.surface)),
                      ])),
                ]),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
