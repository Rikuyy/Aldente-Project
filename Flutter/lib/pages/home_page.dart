import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/dashboard_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DashboardService _service = DashboardService();

  bool _isLoading = true;
  String? _errorMsg;

  // User
  String _nama = '';
  String _inisial = '';

  // Budget
  double _sisaHariIni = 0;
  double _sisaBulan = 0;
  String _statusBudget = 'Aman';
  String? _warningMsg;

  // Rekomendasi resep
  List<dynamic> _rekomendasi = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final result = await _service.getDashboard();

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        _nama = data['user']['nama'] ?? '';
        _inisial = data['user']['inisial'] ?? '';
        _sisaHariIni = (data['budget']['sisa_hari_ini'] ?? 0).toDouble();
        _sisaBulan = (data['budget']['sisa_bulan'] ?? 0).toDouble();
        _statusBudget = data['budget']['status'] ?? 'Aman';
        _warningMsg = data['budget']['warning_msg'];
        _rekomendasi = data['rekomendasi_resep'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMsg = result['message'];
        _isLoading = false;
      });
    }
  }

  String _formatRupiah(double value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} jt';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}.000';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    const unreadCount = 3;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.slate50,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMsg != null) {
      return Scaffold(
        backgroundColor: AppTheme.slate50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppTheme.slate300),
              const SizedBox(height: 12),
              Text(_errorMsg!,
                  style:
                      const TextStyle(color: AppTheme.slate500, fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboard,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ──────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              expandedHeight: 0,
              toolbarHeight: 72,
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Kiri: logo + sapaan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'CookCase+',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.slate800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Hai, $_nama!',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.slate500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.waving_hand,
                                  size: 12, color: AppTheme.slate500),
                            ],
                          ),
                        ],
                      ),
                      // Kanan: notif + avatar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/notifications'),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.slate50,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.notifications_rounded,
                                      size: 22, color: AppTheme.slate400),
                                  if (unreadCount > 0)
                                    Positioned(
                                      top: -6,
                                      right: -6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.orange500,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                              color: Colors.white, width: 1.5),
                                        ),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => context.go('/app/profile'),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.orange100,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.orange200, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  _inisial,
                                  style: const TextStyle(
                                    color: AppTheme.orange600,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: AppTheme.slate100, height: 1),
              ),
            ),

            // ── Content ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // Warning Banner (hanya muncul kalau Waspada / Kritis)
                  if (_warningMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.orange200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 10.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 20.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              _statusBudget == 'Kritis'
                                  ? Icons.error_rounded
                                  : Icons.warning_amber_rounded,
                              color: AppTheme.orange600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status Budget: $_statusBudget',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: Color(0xFF9A3412),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _warningMsg!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFC2410C),
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Main Budget Card
                  GestureDetector(
                    onTap: () => context.go('/app/finance'),
                    child: Container(
                      padding: const EdgeInsets.all(24),
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
                            color: AppTheme.slate900.withValues(alpha: 76.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Decorative circle
                          Positioned(
                            top: -30,
                            right: -20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 12.75),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header card
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet_rounded,
                                          color: Color(0xFFCBD5E1), size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'SISA BUDGET',
                                        style: TextStyle(
                                          color: Color(0xFFCBD5E1),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 25.5),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 25.5)),
                                    ),
                                    child: const Text(
                                      'Bulan Ini',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Sisa hari ini
                              const Text(
                                'HARI INI',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatRupiah(_sisaHariIni),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 25.5)),
                              const SizedBox(height: 20),
                              // Sisa bulan + arrow
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.calendar_month_rounded,
                                              color: Color(0xFF94A3B8),
                                              size: 12),
                                          SizedBox(width: 4),
                                          Text(
                                            'SISA BULAN INI',
                                            style: TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatRupiah(_sisaBulan),
                                        style: const TextStyle(
                                          color: Color(0xFFE2E8F0),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 25.5),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.arrow_forward,
                                        color: Colors.white, size: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Rekomendasi Resep
                  if (_rekomendasi.isNotEmpty) ...[
                    const Text(
                      'Rekomendasi Resep',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slate800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._rekomendasi.map((resep) => _ResepCard(resep: resep)),
                    const SizedBox(height: 24),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Kartu Resep ───────────────────────────────────────────────
class _ResepCard extends StatelessWidget {
  final Map<String, dynamic> resep;
  const _ResepCard({required this.resep});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 10.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon resep
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.orange100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant_menu_rounded,
                color: AppTheme.orange600, size: 22),
          ),
          const SizedBox(width: 12),
          // Nama + info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resep['Title Cleaned'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.slate800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${resep['Total Ingredients']} bahan  ·  ${resep['Total Steps']} langkah',
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.slate500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Loves count
          Row(
            children: [
              const Icon(Icons.favorite_rounded,
                  color: AppTheme.orange500, size: 14),
              const SizedBox(width: 4),
              Text(
                '${resep['Loves']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slate600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
