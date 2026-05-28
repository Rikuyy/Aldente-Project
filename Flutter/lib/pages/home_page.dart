import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/dashboard_service.dart';

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

  // Informasi tambahan untuk perhitungan budget harian
  int _totalHariBulan = 30; // default, nanti diisi dari API jika ada
  int _hariKe = DateTime.now().day;

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

    final service = DashboardService();
    final results = await Future.wait([
      service.getDashboard(),
      service.getInventory(),
    ]);

    final dashboardResponse = results[0];
    final stokResponse = results[1];

    // Proses dashboard
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

    // Proses stok
    await _processStokResponse(stokResponse);

    setState(() {
      _isLoading = false;
    });
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
    // Jika API menyediakan total_hari_bulan, bisa diambil
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

  // Helper untuk mendapatkan warna background resep berdasarkan kategori
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan utama':
        return AppTheme.orange400;
      case 'sup':
        return AppTheme.green400;
      case 'dessert':
        return AppTheme.pink400;
      default:
        return AppTheme.blue400;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: context.colors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Coba Lagi'),
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

    // Hitung alokasi harian ideal (misal total budget / jumlah hari)
    final budgetPerHariIdeal =
        _totalHariBulan > 0 ? totalBudget / _totalHariBulan : 0;
    final sisaHari = _totalHariBulan - _hariKe + 1;
    final budgetPerHariSisa = sisaHari > 0 ? sisaBulan / sisaHari : 0;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CookCash',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hai, $_userName!',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.push('/notifications'),
                      icon: const Icon(Icons.notifications_rounded),
                      color: context.colors.textSecondary,
                    ),
                    GestureDetector(
                      onTap: () => context.go('/app/profile'),
                      child: CircleAvatar(
                        backgroundColor: AppTheme.orange100,
                        foregroundColor: AppTheme.orange600,
                        child: Text(_userInitial),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Peringatan budget
            if (pesanPeringatan != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusBudget == 'Kritis'
                      ? AppTheme.red50
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusBudget == 'Kritis'
                        ? AppTheme.red200
                        : AppTheme.orange200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      statusBudget == 'Kritis'
                          ? Icons.warning_rounded
                          : Icons.warning_amber_rounded,
                      color: statusBudget == 'Kritis'
                          ? AppTheme.red600
                          : AppTheme.orange600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Budget: $statusBudget',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusBudget == 'Kritis'
                                  ? AppTheme.red700
                                  : const Color(0xFF9A3412),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pesanPeringatan,
                            style: TextStyle(
                              color: statusBudget == 'Kritis'
                                  ? AppTheme.red600
                                  : const Color(0xFFC2410C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // ========== KARTU BUDGET DESAIN GELAP (seperti lama) ==========
            GestureDetector(
              onTap: () => context.go('/app/finance'),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E293B),
                      Color(0xFF0F172A)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.slate900.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -24,
                      right: -24,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          color: Color(0x0FFFFFFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -16,
                      left: -16,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0x08FFFFFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.account_balance_wallet_rounded,
                                      color: Color(0xFFCBD5E1), size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'SISA BUDGET HARI INI',
                                    style: TextStyle(
                                      color: Color(0xFFCBD5E1),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0x1AFFFFFF),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: const Color(0x1AFFFFFF)),
                                ),
                                child: Text(
                                  'Hari ke-$_hariKe',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _formatCurrency(sisaHariIni),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (totalBudget > 0)
                                  ? (sisaBulan / totalBudget).clamp(0.0, 1.0)
                                  : 0.0,
                              minHeight: 6,
                              backgroundColor: const Color(0x1AFFFFFF),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.orange400),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$persenSisa% dari budget bulan ini tersisa',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Informasi tambahan perhitungan matematika
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x1AFFFFFF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Alokasi per hari (ideal):',
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11),
                                    ),
                                    Text(
                                      _formatCurrency(
                                          budgetPerHariIdeal.toInt()),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Sisa hari bulan ini:',
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11),
                                    ),
                                    Text(
                                      '$sisaHari hari',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Budget per hari (sisa):',
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11),
                                    ),
                                    Text(
                                      _formatCurrency(
                                          budgetPerHariSisa.toInt()),
                                      style: const TextStyle(
                                          color: AppTheme.orange400,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ========== RINGKASAN BULAN INI ==========
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: context.colors.cardBackground,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RINGKASAN BULAN INI',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            label: 'Total Budget',
                            value: _formatCurrency(totalBudget),
                            icon: Icons.account_balance_wallet_rounded,
                            color: AppTheme.green600,
                          ),
                        ),
                        Expanded(
                          child: _InfoTile(
                            label: 'Total Keluar',
                            value: _formatCurrency(totalKeluar),
                            icon: Icons.remove_circle_outline,
                            color: AppTheme.red500,
                          ),
                        ),
                        Expanded(
                          child: _InfoTile(
                            label: 'Sisa Bulan',
                            value: _formatCurrency(sisaBulan),
                            icon: Icons.arrow_forward,
                            color: AppTheme.orange600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========== STOK BAHAN ==========
            const Text(
              'STOK BAHAN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_isLoadingStok)
              const Center(child: CircularProgressIndicator())
            else if (_stokErrorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.red50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.red600),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_stokErrorMessage!)),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _StokCard(
                      title: 'Bahan Segar',
                      count: _totalSegar,
                      color: AppTheme.green600,
                      icon: Icons.eco_rounded,
                      filter: 'segar',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StokCard(
                      title: 'Bahan Kemasan',
                      count: _totalKemasan,
                      color: AppTheme.blue600,
                      icon: Icons.inventory_rounded,
                      filter: 'kemasan',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // ========== REKOMENDASI RESEP ==========
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'REKOMENDASI RESEP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/app/consultation'),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_rekomendasiResep.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('Belum ada rekomendasi resep. Coba lagi nanti.'),
                ),
              )
            else
              Column(
                children: [
                  // Rekomendasi unggulan (pertama) dengan placeholder gambar
                  _ResepCard(
                    resep: _rekomendasiResep.first,
                    isFeatured: true,
                    colorResolver: _getCategoryColor,
                  ),
                  const SizedBox(height: 12),
                  // Rekomendasi lainnya dalam grid 2 kolom
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _rekomendasiResep.length - 1,
                    itemBuilder: (context, index) {
                      return _ResepCard(
                        resep: _rekomendasiResep[index + 1],
                        isFeatured: false,
                        colorResolver: _getCategoryColor,
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ========== WIDGET PENDUKUNG ==========

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _InfoTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: context.colors.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text('$count item',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (count == 0)
              const Text('Belum ada bahan', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ResepCard extends StatelessWidget {
  final dynamic resep;
  final bool isFeatured;
  final Color Function(String category) colorResolver;
  const _ResepCard(
      {required this.resep,
      required this.isFeatured,
      required this.colorResolver});

  @override
  Widget build(BuildContext context) {
    final title = resep['Title Cleaned'] ?? 'Resep';
    final category = resep['Category'] ?? '';
    final loves = resep['Loves'] ?? 0;
    final String firstLetter = title.isNotEmpty ? title[0] : 'R';
    final Color categoryColor = colorResolver(category);

    if (isFeatured) {
      return GestureDetector(
        onTap: () => context.go('/app/consultation'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.orange500.withValues(alpha: 0.1),
                Colors.transparent
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppTheme.orange500.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              // Placeholder gambar (lingkaran berwarna + inisial)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    categoryColor,
                    categoryColor.withValues(alpha: 0.6)
                  ]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Paling Disukai',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.orange600)),
                    const SizedBox(height: 4),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(category,
                        style: TextStyle(
                            fontSize: 12, color: context.colors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.favorite,
                            size: 12, color: AppTheme.red500),
                        const SizedBox(width: 4),
                        Text('$loves suka',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.orange500),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => context.go('/app/consultation'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Placeholder gambar (lingkaran kecil dengan inisial)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        categoryColor,
                        categoryColor.withValues(alpha: 0.6)
                      ]),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(category,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: categoryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.favorite, size: 12, color: AppTheme.red500),
                  const SizedBox(width: 4),
                  Text('$loves suka', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}
