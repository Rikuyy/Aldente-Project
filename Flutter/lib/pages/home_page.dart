import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../services/dashboard_service.dart';

// --- FUNGSI FILTER & FORMAT NAMA RESEP AGAR TAMBAH CLEAN ---
String _formatRecipeTitle(String rawTitle) {
  if (rawTitle.isEmpty) return 'Resep';

  String text = rawTitle.toLowerCase();

  if (text.contains(' by ')) text = text.split(' by ')[0];
  if (text.contains(' ala ')) text = text.split(' ala ')[0];

  List<String> words = text.split(' ').where((w) => w.isNotEmpty).toList();

  final stopWords = ['uenak', 'enak', 'spesial', 'mantap', 'lezat', 'super'];
  words = words.where((word) => !stopWords.contains(word)).toList();

  return words.map((w) {
    if (w.isEmpty) return '';
    return w[0].toUpperCase() + w.substring(1);
  }).join(' ');
}
// -----------------------------------------------------------

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

  DateTime _lastStokRefresh = DateTime.now();
  bool _stokLoadSuccess = true;

  int _totalHariBulan = 30;
  final int _hariKe = DateTime.now().day;

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

  Future<void> _fetchDashboardAndStok() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _stokErrorMessage = null;
    });

    try {
      final service = DashboardService();
      final results = await Future.wait([
        service.getDashboard(),
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
    _totalHariBulan = _budget['total_hari_bulan'] ??
        DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
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
    final rawTitle = resep['Title Cleaned'] ?? 'Resep';
    final title = _formatRecipeTitle(rawTitle);
    final category = resep['Category'] ?? 'Tidak ada kategori';
    final loves = resep['Loves'] ?? 0;
    final totalIngredients = resep['Total Ingredients'] ?? 0;
    final totalSteps = resep['Total Steps'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border:
                    Border.all(color: _getCategoryColor(category), width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: _getCategoryColor(category),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.favorite_border_rounded,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('$loves menyukai resep ini',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.shopping_basket_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('$totalIngredients bahan diperlukan',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.format_list_numbered_rounded,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('$totalSteps langkah memasak',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Detail instruksi dan takaran bahan lengkap dapat diakses melalui modul buku resep utama.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
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
          const SizedBox(height: 32),
          Container(width: 150, height: 24, color: Colors.white),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
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

    final sisaHariIni = _budget['sisa_hari_ini'] ?? 0;
    final persenSisa = _budget['persen_sisa'] ?? 0;
    final statusBudget = _budget['status'] ?? 'Aman';
    final pesanPeringatan = _budget['pesan_peringatan'];
    final totalBudget = _budget['total_budget'] ?? 0;
    final totalKeluar = _budget['total_keluar'] ?? 0;
    final sisaBulan = _budget['sisa_bulan'] ?? 0;

    final budgetPerHariIdeal =
        _totalHariBulan > 0 ? totalBudget / _totalHariBulan : 0;
    final sisaHari = _totalHariBulan - _hariKe + 1;
    final budgetPerHariSisa = sisaHari > 0 ? sisaBulan / sisaHari : 0;

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

              // WARNING BANNER
              if (pesanPeringatan != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusBudget == 'Kritis'
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusBudget == 'Kritis'
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFFFED7AA),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusBudget == 'Kritis'
                            ? Icons.error_outline_rounded
                            : Icons.warning_amber_rounded,
                        color: statusBudget == 'Kritis'
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFEA580C),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Keuangan: $statusBudget',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: statusBudget == 'Kritis'
                                    ? const Color(0xFF991B1B)
                                    : const Color(0xFF9A3412),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pesanPeringatan,
                              style: TextStyle(
                                fontSize: 13,
                                color: statusBudget == 'Kritis'
                                    ? const Color(0xFFB91C1C)
                                    : const Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // RESPONSIVE FINANCE SECTION
              if (isWideScreen)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildBudgetCard(
                          sisaHariIni,
                          totalBudget,
                          sisaBulan,
                          persenSisa,
                          budgetPerHariIdeal,
                          sisaHari,
                          budgetPerHariSisa),
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
                    sisaHariIni,
                    totalBudget,
                    sisaBulan,
                    persenSisa,
                    budgetPerHariIdeal,
                    sisaHari,
                    budgetPerHariSisa),
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
              const Text(
                'Rekomendasi Menu Hari Ini',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 16),

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
                // REKOMENDASI TERATAS (DESAIN ELEGAN DENGAN SHADOW SENADA YANG ANDA SUKAI)
                _FeaturedRecipeCard(
                  resep: _rekomendasiResep.first,
                  colorResolver: _getCategoryColor,
                  iconResolver: _getCategoryIcon,
                  onTap: () =>
                      _showRecipeDetailPopup(context, _rekomendasiResep.first),
                ),
                const SizedBox(height: 16),
                if (_rekomendasiResep.length > 1)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          screenWidth > 1200 ? 4 : (screenWidth > 800 ? 3 : 2),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      // REVISI: Rasio ditingkatkan agar card tidak terlalu kotak dan terlihat lebih lebar
                      childAspectRatio: screenWidth > 1200
                          ? 2.2
                          : (screenWidth > 800 ? 1.8 : 1.6),
                    ),
                    // Dipaksa melalukan loop sebanyak 1 kali (+1 utama = total 12 resep simetris)
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      // Sistem Safe Loop Modulo agar aman jika item bawaan kurang dari 12
                      final resepIndex =
                          1 + (index % (_rekomendasiResep.length - 1));
                      final resep = _rekomendasiResep[resepIndex];
                      return _GridRecipeCard(
                        resep: resep,
                        colorResolver: _getCategoryColor,
                        iconResolver: _getCategoryIcon,
                        onTap: () => _showRecipeDetailPopup(context, resep),
                      );
                    },
                  ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(
      int sisaHariIni,
      int totalBudget,
      int sisaBulan,
      int persenSisa,
      double budgetPerHariIdeal,
      int sisaHari,
      double budgetPerHariSisa) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SISA ANGGARAN HARI INI',
                style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(6)),
                child: Text('Hari ke-$_hariKe',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(sisaHariIni),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (totalBudget > 0)
                  ? (sisaBulan / totalBudget).clamp(0.0, 1.0)
                  : 0.0,
              minHeight: 6,
              backgroundColor: const Color(0x1AFFFFFF),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
            ),
          ),
          const SizedBox(height: 8),
          Text('$persenSisa% sisa alokasi bulanan tersedia',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0x0DFFFFFF),
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _BudgetDetailRow(
                    label: 'Alokasi Ideal Harian',
                    value: _formatCurrency(budgetPerHariIdeal.toInt())),
                const SizedBox(height: 8),
                _BudgetDetailRow(
                    label: 'Sisa Waktu Bulan Ini', value: '$sisaHari Hari'),
                const SizedBox(height: 8),
                _BudgetDetailRow(
                    label: 'Rekomendasi Sisa Harian',
                    value: _formatCurrency(budgetPerHariSisa.toInt()),
                    isAccent: true),
              ],
            ),
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
            'IKHTISAR BULAN INI',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _SummaryTile(
              label: 'Total Batas Anggaran',
              value: _formatCurrency(totalBudget),
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF0D9488)),
          const Divider(height: 24),
          _SummaryTile(
              label: 'Total Pengeluaran',
              value: _formatCurrency(totalKeluar),
              icon: Icons.analytics_outlined,
              color: const Color(0xFFE11D48)),
          const Divider(height: 24),
          _SummaryTile(
              label: 'Sisa Saldo Kumulatif',
              value: _formatCurrency(sisaBulan),
              icon: Icons.savings_outlined,
              color: const Color(0xFFF97316)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/app/finance/mutasi'),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('Lihat Mutasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B2A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAccent;
  const _BudgetDetailRow(
      {required this.label, required this.value, this.isAccent = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: isAccent ? const Color(0xFFF97316) : Colors.white,
            fontSize: 13,
            fontWeight: isAccent ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
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

// --- KARTU REKOMENDASI TERATAS (PREMIUM MINIMALIS ELEGAN + SHADOW SENADA) ---
class _FeaturedRecipeCard extends StatelessWidget {
  final dynamic resep;
  final Color Function(String category) colorResolver;
  final IconData Function(String category) iconResolver;
  final VoidCallback onTap;

  const _FeaturedRecipeCard(
      {required this.resep,
      required this.colorResolver,
      required this.iconResolver,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rawTitle = resep['Title Cleaned'] ?? 'Resep';
    final title = _formatRecipeTitle(rawTitle);
    final category = resep['Category'] ?? 'Umum';
    final loves = resep['Loves'] ?? 0;
    final Color categoryColor = colorResolver(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: categoryColor.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.12),
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
                  color: categoryColor.withOpacity(0.1),
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
              Row(
                children: [
                  const Icon(Icons.favorite_rounded,
                      size: 16, color: Color(0xFFEF4444)),
                  const SizedBox(width: 4),
                  Text('$loves',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444))),
                ],
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
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
          )
        ],
      ),
    );
  }
}

// --- REVISI: KARTU GRID RESEP KECIL (KEMBALI KE BASE AWAL YANG CLEAN & BG PUTIH) ---
class _GridRecipeCard extends StatelessWidget {
  final dynamic resep;
  final Color Function(String category) colorResolver;
  final IconData Function(String category) iconResolver;
  final VoidCallback onTap;

  const _GridRecipeCard(
      {required this.resep,
      required this.colorResolver,
      required this.iconResolver,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rawTitle = resep['Title Cleaned'] ?? 'Resep';
    final title = _formatRecipeTitle(rawTitle);
    final category = resep['Category'] ?? 'Umum';
    final Color categoryColor = colorResolver(category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context
            .colors.cardBackground, // Background putih bersih bawaan awal
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200), // Border tipis soft
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border:
                    Border.all(color: categoryColor.withOpacity(0.5), width: 1),
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
                    fontSize: 14, // Ukuran teks proporsional & clean
                    fontWeight:
                        FontWeight.bold, // Ketebalan bold standar yang rapi
                    color: Color(
                        0xFF1E293B), // Kembali ke warna gelap premium yang bersih
                    height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Lihat Detail',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: categoryColor)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: categoryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
