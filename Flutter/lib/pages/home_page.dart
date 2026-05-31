import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/dashboard_service.dart';
import '../services/todo_notifier.dart';

String _formatRecipeTitle(String rawTitle) {
  if (rawTitle.isEmpty) return 'Resep';

  String text = rawTitle.toLowerCase();
  if (text.contains(' by ')) text = text.split(' by ')[0];
  if (text.contains(' ala ')) text = text.split(' ala ')[0];

  List<String> words = text.split(' ').where((w) => w.isNotEmpty).toList();
  const stopWords = ['uenak', 'enak', 'spesial', 'mantap', 'lezat', 'super'];
  words = words.where((word) => !stopWords.contains(word)).toList();

  return words.map((w) {
    if (w.isEmpty) return '';
    return w[0].toUpperCase() + w.substring(1);
  }).join(' ');
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _isLoadingStok = true;
  String? _errorMessage;
  String? _stokErrorMessage;
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _rekomendasiResep = [];
  List<dynamic> _allStok = [];

  String _userName = '';
  String _userInitial = '';
  Map<String, dynamic> _budget = {};
  int _jumlahSesiMakan = 2;

  DateTime _lastStokRefresh = DateTime.now();
  bool _stokLoadSuccess = true;
  bool _hasShownBudgetDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchDashboardAndStok();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _stokLoadSuccess) {
      _refreshStokIfNeeded();
    }
  }

  Future<void> _refreshStokIfNeeded() async {
    if (DateTime.now().difference(_lastStokRefresh).inSeconds > 5) {
      await _fetchStok();
    }
  }

  Future<void> _fetchDashboardAndStok({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _stokErrorMessage = null;
    });

    try {
      final service = DashboardService();
      final results = await Future.wait([
        service.getDashboard(forceRefresh: forceRefresh),
        service.getInventory(),
      ]);

      final dashboardResponse = results[0];
      final stokResponse = results[1];

      if (dashboardResponse['success'] == true &&
          dashboardResponse['data'] != null) {
        final data = dashboardResponse['data'];
        setState(() {
          _dashboardData = data['data'] ?? data;
          _extractData();
        });
      } else {
        setState(() {
          _errorMessage =
              dashboardResponse['message'] ?? 'Gagal memuat data dashboard';
        });
      }

      await _processStokResponse(stokResponse);
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan sistem: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });

      final isBudgetDue = _dashboardData?['budget']?['is_budget_due'] == true;

      final prefs = await SharedPreferences.getInstance();
      final lastPromptDate = prefs.getString('last_budget_prompt_date');
      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      if (isBudgetDue &&
          lastPromptDate != todayStr &&
          !_hasShownBudgetDialog &&
          _errorMessage == null) {
        _hasShownBudgetDialog = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tampilkanPopUpKonfirmasiBulanan();
        });
      }
    }
  }

  Future<void> _processStokResponse(Map<String, dynamic> response) async {
    setState(() => _isLoadingStok = true);
    if (response['success'] == true && response['data'] != null) {
      try {
        final List<dynamic> data = response['data'];
        List<dynamic> allStocks = [];
        for (var group in data) {
          final bahanList = group['bahan'] as List;
          allStocks.addAll(bahanList);
        }
        setState(() {
          _allStok = allStocks;
          _stokErrorMessage = null;
          _stokLoadSuccess = true;
          _lastStokRefresh = DateTime.now();
        });
      } catch (e) {
        setState(() {
          _stokErrorMessage = 'Gagal memproses data stok';
          _stokLoadSuccess = false;
        });
      }
    } else {
      setState(() {
        _stokErrorMessage = response['message'] ?? 'Gagal memuat stok';
        _stokLoadSuccess = false;
      });
    }
    setState(() => _isLoadingStok = false);
  }

  Future<void> _fetchStok() async {
    final service = DashboardService();
    final response = await service.getInventory();
    await _processStokResponse(response);
  }

  void _extractData() {
    if (_dashboardData == null) return;
    final user = _dashboardData!['pengguna'] ?? {};
    _userName = user['nama'] ?? 'Pengguna';
    _userInitial = user['inisial'] ?? 'P';
    _budget = _dashboardData!['budget'] ?? {};
    _rekomendasiResep = _dashboardData!['rekomendasi_resep'] ?? [];

    _jumlahSesiMakan =
        int.tryParse(user['jumlah_makan']?.toString() ?? '2') ?? 2;
  }

  void _tampilkanPopUpKonfirmasiBulanan() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded,
                  color: AppTheme.orange600),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Uang Makan Bulanan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: const Text(
            'Apakah kamu sudah mendapatkan uang makan bulanan untuk siklus periode baru ini? Jika belum, kami akan bertanya lagi besok.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('last_budget_prompt_date',
                    DateTime.now().toIso8601String().split('T')[0]);

                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('Belum',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _tampilkanFormInputBudget();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sudah, Konfirmasi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _tampilkanFormInputBudget() {
    final TextEditingController nominalController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: AppTheme.orange100,
                              shape: BoxShape.circle),
                          child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppTheme.orange600),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text('Input Uang Masuk',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Nominal Bulan Ini (Rp)',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CurrencyFormatter(),
                      ],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nominalController.text.isEmpty) return;

                                setStateSheet(() => isSubmitting = true);

                                final nominal = int.tryParse(nominalController
                                        .text
                                        .replaceAll('.', '')) ??
                                    0;
                                final service = DashboardService();

                                final respMutasi =
                                    await service.tambahPemasukan(nominal);
                                final respSiklus =
                                    await service.setBudget(nominal.toDouble());

                                setStateSheet(() => isSubmitting = false);

                                if (respMutasi['success'] == true &&
                                    respSiklus['success'] == true) {
                                  if (!context.mounted) return;
                                  Navigator.of(sheetContext).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Pemasukan & Siklus baru berhasil dicatat!'),
                                        backgroundColor: Colors.green),
                                  );
                                  _refreshData();
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Gagal menyimpan data'),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.orange600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3))
                            : const Text('Mulai Siklus Baru',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int get _totalSegar =>
      _allStok.where((s) => (s['Tipe_Bahan'] ?? 'segar') == 'segar').length;
  int get _totalKemasan =>
      _allStok.where((s) => (s['Tipe_Bahan'] ?? 'segar') == 'kemasan').length;

  String _formatCurrency(int? amount) {
    if (amount == null || amount == 0) return 'Rp 0';
    String stringValue = amount.toString();
    String result = '';
    int length = stringValue.length;
    for (int i = 0; i < length; i++) {
      if ((length - i) % 3 == 0 && i != 0) result += '.';
      result += stringValue[i];
    }
    return 'Rp $result';
  }

  Future<void> _refreshData() async {
    await _fetchDashboardAndStok();
  }

  // =========================================================================
  // FIX: SWAP RESEP YANG SANGAT AMAN UNTUK NAVIGASI (ANTI MACET)
  // =========================================================================
  void _swapResepKeTodo(BuildContext context, dynamic resep) async {
    final int jmlMakan = _jumlahSesiMakan;

    List<String> sesiLabels = [];
    if (jmlMakan == 2) {
      sesiLabels = ['Sesi 1 (Pagi/Siang)', 'Sesi 2 (Malam)'];
    } else if (jmlMakan == 3) {
      sesiLabels = ['Sesi 1 (Sarapan)', 'Sesi 2 (Siang)', 'Sesi 3 (Malam)'];
    } else if (jmlMakan == 4) {
      sesiLabels = [
        'Sesi 1 (Sarapan)',
        'Sesi 2 (Siang)',
        'Sesi 3 (Sore)',
        'Sesi 4 (Malam)'
      ];
    } else {
      sesiLabels = List.generate(jmlMakan, (i) => 'Sesi ${i + 1}');
    }

    Map<String, String> jadwalHariIni = {};
    if (_dashboardData != null && _dashboardData!['jadwal_hari_ini'] != null) {
      try {
        final jhi = _dashboardData!['jadwal_hari_ini'];
        if (jhi is Map) {
          jhi.forEach((k, v) => jadwalHariIni[k.toString()] = v.toString());
        }
      } catch (e) {
        debugPrint('Error parse jadwal: $e');
      }
    }

    // 1. TUNGGU HASIL PILIHAN USER DARI BOTTOM SHEET
    final selectedSesi = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.slate200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ganti resep di sesi mana?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              _formatRecipeTitle(
                  resep['Title Cleaned'] ?? resep['title'] ?? ''),
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.slate400,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ...List.generate(sesiLabels.length, (i) {
              String dbSesiLabel = sesiLabels[i];
              String indexSesi = (i + 1).toString();
              String menuSaatIni = jadwalHariIni[indexSesi] ?? '';

              if (menuSaatIni.isEmpty) {
                menuSaatIni = 'Kosong';
              } else {
                menuSaatIni = _formatRecipeTitle(menuSaatIni);
              }

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.orange600.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: AppTheme.orange600,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                title: Text('Sesi ${i + 1}. $menuSaatIni',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.slate400),
                onTap: () {
                  // TUTUP BOTTOM SHEET DAN KEMBALIKAN PILIHAN
                  Navigator.of(bottomSheetContext).pop({
                    'sesiKe': i + 1,
                    'sesiLabel': dbSesiLabel,
                  });
                },
              );
            }),
          ],
        ),
      ),
    );

    // Jika user klik di luar (batal), hentikan proses.
    if (selectedSesi == null) return;

    // TANGKAP NAVIGATOR DAN ROUTER SEBELUM PROSES ASYNC DIMULAI
    final router = GoRouter.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 2. TAMPILKAN LOADING OVERLAY DI HALAMAN UTAMA
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: AppTheme.orange600),
      ),
    );

    final int sesiKe = selectedSesi['sesiKe'];
    final String dbSesiLabel = selectedSesi['sesiLabel'];

    final dynamic rawSteps = resep['Steps'] ?? resep['steps'] ?? '';
    String stepsStr =
        (rawSteps is List) ? rawSteps.join('\n') : rawSteps.toString();

    // 3. SIMPAN KE LARAVEL
    final service = DashboardService();
    await service.tukarResepTodo(
        (resep['_id'] ?? resep['id'] ?? '').toString(), sesiKe, dbSesiLabel);

    // 4. SIMPAN KE TODO NOTIFIER LOKAL
    await TodoNotifier.instance.gantiJadwal({
      'sesi_ke': sesiKe,
      'sesi_label': dbSesiLabel,
      'resep': {
        'id': (resep['_id'] ?? resep['id'] ?? '').toString(),
        'title': resep['Title Cleaned'] ?? resep['title'] ?? '-',
        'ingredients':
            resep['Ingredients Cleaned'] ?? resep['ingredients'] ?? '',
        'steps': stepsStr,
        'category': resep['Category'] ?? resep['category'] ?? '',
      },
    });

    if (!context.mounted) return;

    // 5. TUTUP LOADING OVERLAY DENGAN AMAN
    Navigator.of(context, rootNavigator: true).pop();

    // 6. BERI JEDA ANIMASI AGAR TIDAK MACET SAAT ROUTING
    Future.delayed(const Duration(milliseconds: 150), () {
      // 7. PINDAH KE TODO LIST
      router.go('/app/todo');

      // 8. TAMPILKAN SNACKBAR SETELAH PINDAH
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sesi $sesiKe berhasil diperbarui!',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.orange600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan utama':
        return const Color(0xFF0284C7);
      case 'sup':
        return const Color(0xFF0D9488);
      case 'dessert':
        return const Color(0xFFBE123C);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan utama':
        return Icons.restaurant_rounded;
      case 'sup':
        return Icons.soup_kitchen_rounded;
      case 'dessert':
        return Icons.bakery_dining_rounded;
      default:
        return Icons.flatware_rounded;
    }
  }

  void _showRecipeDetailPopup(BuildContext context, dynamic resep) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecipeDetailSheet(
        resep: resep,
        categoryColor: _getCategoryColor(resep['Category'] ?? ''),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 150, height: 28, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 16, color: Colors.white),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 850;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.surface,
        body: SafeArea(child: _buildShimmerLoading()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: context.colors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final sisaBulan = _budget['sisa_bulan'] ?? 0;
    final totalKeluar = _budget['total_keluar'] ?? 0;
    final totalBudget = _budget['total_budget'] ?? 0;
    final budgetPerHariSisa = (_budget['budget_per_hari'] ?? 0).toDouble();
    final hariKe = _budget['hari_ke'] ?? 1;
    final aktivitasTerakhir = _budget['aktivitas_terakhir'];

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // HEADER SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CookCash',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hai, $_userName! 👋',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: const Icon(Icons.notifications_none_rounded,
                            size: 24),
                        color: context.colors.textSecondary,
                      ),
                      GestureDetector(
                        onTap: () => context.go('/app/profile'),
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppTheme.orange200, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.orange100,
                            foregroundColor: AppTheme.orange600,
                            child: Text(_userInitial,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // RESPONSIVE FINANCE SECTION
              if (isWideScreen)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildBudgetCard(
                        sisaBulan,
                        hariKe,
                        budgetPerHariSisa,
                        aktivitasTerakhir,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: _buildSummaryCard(
                          context, totalBudget, totalKeluar, sisaBulan),
                    ),
                  ],
                )
              else ...[
                _buildBudgetCard(
                  sisaBulan,
                  hariKe,
                  budgetPerHariSisa,
                  aktivitasTerakhir,
                ),
                const SizedBox(height: 24),
                _buildSummaryCard(context, totalBudget, totalKeluar, sisaBulan),
              ],

              const SizedBox(height: 32),

              // STOK BAHAN SECTION
              const Text(
                'Manajemen Stok',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 16),
              if (_isLoadingStok)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator()))
              else if (_stokErrorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(_stokErrorMessage!,
                      style: const TextStyle(color: Color(0xFFB91C1C))),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _StokCard(
                        title: 'Bahan Segar',
                        count: _totalSegar,
                        color: const Color(0xFF0D9488),
                        icon: Icons.layers_outlined,
                        filter: 'segar',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StokCard(
                        title: 'Bahan Kemasan',
                        count: _totalKemasan,
                        color: const Color(0xFF4F46E5),
                        icon: Icons.all_inbox_rounded,
                        filter: 'kemasan',
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 36),

              // REKOMENDASI RESEP SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rekomendasi Menu Hari Ini',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5),
                  ),
                  IconButton(
                    onPressed: () => _fetchDashboardAndStok(forceRefresh: true),
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppTheme.orange600),
                    tooltip: 'Acak Ulang Resep',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_rekomendasiResep.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: context.colors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Text('Tidak ada rekomendasi resep saat ini.',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              else ...[
                _FeaturedRecipeCard(
                  resep: _rekomendasiResep.first,
                  colorResolver: _getCategoryColor,
                  iconResolver: _getCategoryIcon,
                  onTap: () =>
                      _showRecipeDetailPopup(context, _rekomendasiResep.first),
                  onSwap: () =>
                      _swapResepKeTodo(context, _rekomendasiResep.first),
                ),
                const SizedBox(height: 16),
                Builder(builder: (context) {
                  int gridCount = _rekomendasiResep.length > 1
                      ? _rekomendasiResep.length - 1
                      : 0;
                  if (gridCount > 10) gridCount = 10;

                  if (gridCount > 0) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth > 1200
                            ? 4
                            : (screenWidth > 800 ? 3 : 2),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: screenWidth > 1200
                            ? 2.2
                            : (screenWidth > 800 ? 1.8 : 1.6),
                      ),
                      itemCount: gridCount,
                      itemBuilder: (context, index) {
                        final resep = _rekomendasiResep[index + 1];
                        return _GridRecipeCard(
                          resep: resep,
                          colorResolver: _getCategoryColor,
                          iconResolver: _getCategoryIcon,
                          onTap: () => _showRecipeDetailPopup(context, resep),
                          onSwap: () => _swapResepKeTodo(context, resep),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- CARD BUDGET GELAP ---
  Widget _buildBudgetCard(
    int sisaSaldo,
    int hariKe,
    double budgetPerHariSisa,
    dynamic aktivitasTerakhir,
  ) {
    String nominalAktivitas = '-';
    String ketAktivitas = 'Belum ada mutasi';
    Color warnaAktivitas = Colors.blueGrey.shade400;

    if (aktivitasTerakhir != null) {
      nominalAktivitas = aktivitasTerakhir['nominal'];
      ketAktivitas = aktivitasTerakhir['keterangan'];
      warnaAktivitas = aktivitasTerakhir['kategori'] == 'Pemasukan'
          ? const Color(0xFF10B981)
          : const Color(0xFFEF4444);
    }

    final int targetPengeluaranHarian = budgetPerHariSisa.toInt();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BUDGET HARI INI',
                style: TextStyle(
                    color: Colors.blueGrey.shade300,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('HARI KE-$hariKe',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(targetPengeluaranHarian),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded,
                            size: 14, color: Colors.blueGrey.shade400),
                        const SizedBox(width: 6),
                        Text('Total Saldo',
                            style: TextStyle(
                                color: Colors.blueGrey.shade400, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatCurrency(sisaSaldo),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withValues(alpha: 0.1)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history_rounded,
                              size: 14, color: Colors.blueGrey.shade400),
                          const SizedBox(width: 6),
                          Text('Aktivitas Terakhir',
                              style: TextStyle(
                                  color: Colors.blueGrey.shade400,
                                  fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nominalAktivitas,
                        style: TextStyle(
                            color: warnaAktivitas,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, int totalBudget, int totalKeluar, int sisaBulan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETAIL KEUANGAN',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _SummaryTile(
              label: 'Pemasukan Bulan Ini',
              value: _formatCurrency(totalBudget),
              icon: Icons.arrow_downward_rounded,
              color: const Color(0xFF10B981)),
          const Divider(height: 24),
          _SummaryTile(
              label: 'Pengeluaran Bulan Ini',
              value: _formatCurrency(totalKeluar),
              icon: Icons.arrow_upward_rounded,
              color: const Color(0xFFEF4444)),
          const Divider(height: 24),
          _SummaryTile(
              label: 'Total Saldo ',
              value: _formatCurrency(sisaBulan),
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF3B82F6)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/app/finance'),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('Kelola Keuangan / Mutasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B2A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _StokCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final String filter;
  const _StokCard(
      {required this.title,
      required this.count,
      required this.color,
      required this.icon,
      required this.filter});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/app/inventory', extra: {'filter': filter}),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('$count Item',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedRecipeCard extends StatelessWidget {
  final dynamic resep;
  final Color Function(String category) colorResolver;
  final IconData Function(String category) iconResolver;
  final VoidCallback onTap;
  final VoidCallback onSwap;

  const _FeaturedRecipeCard(
      {required this.resep,
      required this.colorResolver,
      required this.iconResolver,
      required this.onTap,
      required this.onSwap});

  @override
  Widget build(BuildContext context) {
    final rawTitle = resep['Title Cleaned'] ?? 'Resep';
    final title = _formatRecipeTitle(rawTitle);
    final category = resep['Category'] ?? 'Umum';
    final Color categoryColor = colorResolver(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: categoryColor.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        size: 14, color: categoryColor),
                    const SizedBox(width: 4),
                    Text(
                      'REKOMENDASI UTAMA',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: categoryColor,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
                height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onSwap,
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, minimumSize: Size.zero),
                icon: const Icon(Icons.swap_horiz_rounded,
                    size: 16, color: AppTheme.orange600),
                label: const Text('Pakai di Todo',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.orange600)),
              ),
              TextButton.icon(
                onPressed: onTap,
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, minimumSize: Size.zero),
                icon: Text('Lihat Resep Detail',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: categoryColor)),
                label: Icon(Icons.chevron_right_rounded,
                    size: 18, color: categoryColor),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _GridRecipeCard extends StatelessWidget {
  final dynamic resep;
  final Color Function(String category) colorResolver;
  final IconData Function(String category) iconResolver;
  final VoidCallback onTap;
  final VoidCallback onSwap;

  const _GridRecipeCard(
      {required this.resep,
      required this.colorResolver,
      required this.iconResolver,
      required this.onTap,
      required this.onSwap});

  @override
  Widget build(BuildContext context) {
    final rawTitle = resep['Title Cleaned'] ?? 'Resep';
    final title = _formatRecipeTitle(rawTitle);
    final category = resep['Category'] ?? 'Umum';
    final Color categoryColor = colorResolver(category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(
                    color: categoryColor.withValues(alpha: 0.5), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                    letterSpacing: 0.3),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onSwap,
                child: const Icon(Icons.swap_horiz_rounded,
                    size: 18, color: AppTheme.orange600),
              ),
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Detail',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: categoryColor)),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded,
                        size: 14, color: categoryColor),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _RecipeDetailSheet extends StatelessWidget {
  final dynamic resep;
  final Color categoryColor;
  const _RecipeDetailSheet({required this.resep, required this.categoryColor});

  @override
  Widget build(BuildContext context) {
    final rawTitle = resep['Title Cleaned'] ?? resep['title'] ?? 'Resep';
    final title = _formatRecipeTitle(rawTitle);
    final category = resep['Category'] ?? resep['category'] ?? '';

    final ingredients =
        resep['Ingredients Cleaned'] ?? resep['ingredients'] ?? '';

    final dynamic rawSteps = resep['Steps'] ?? resep['steps'];
    List<String> stepsList = [];
    if (rawSteps is List) {
      stepsList = rawSteps.map((s) => s.toString()).toList();
    } else if (rawSteps is String && rawSteps.isNotEmpty) {
      stepsList = rawSteps
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.slate200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.slate700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (category.isNotEmpty)
                                    _InfoChip(
                                        icon: Icons.label_outline,
                                        label: category.toUpperCase(),
                                        color: categoryColor.withValues(
                                            alpha: 0.1),
                                        textColor: categoryColor),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(
                        icon: Icons.kitchen_outlined, label: 'Bahan-bahan'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.slate50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.slate200),
                      ),
                      child: _buildIngredientsList(ingredients.toString()),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      icon: Icons.format_list_numbered_rounded,
                      label: 'Langkah Memasak (${stepsList.length})',
                    ),
                    const SizedBox(height: 10),
                    if (stepsList.isEmpty)
                      const Text(
                        'Langkah memasak tidak tersedia.',
                        style:
                            TextStyle(color: AppTheme.slate400, fontSize: 13),
                      )
                    else
                      ...List.generate(stepsList.length, (i) {
                        final raw = stepsList[i];
                        final cleaned = raw
                            .replaceFirst(RegExp(r'^\d+[\)\.]\s*'), '')
                            .trim();
                        return _StepTile(
                            number: i + 1,
                            text: cleaned.isEmpty ? raw : cleaned,
                            color: categoryColor);
                      }),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        label: const Text(
                          'Tutup',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D1B2A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIngredientsList(String raw) {
    final items =
        raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.slate700,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  const _InfoChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.slate700),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.slate700,
          ),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final int number;
  final String text;
  final Color color;
  const _StepTile(
      {required this.number, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.slate100.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.slate700,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanedText = newValue.text.replaceAll('.', '');
    double? value = double.tryParse(cleanedText);

    if (value == null) {
      return oldValue;
    }

    String formatted = '';
    String str = value.toInt().toString();
    int length = str.length;

    for (int i = 0; i < length; i++) {
      formatted += str[i];
      if ((length - i - 1) % 3 == 0 && i != length - 1) {
        formatted += '.';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
