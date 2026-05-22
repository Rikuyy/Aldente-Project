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
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: context.colors.cardBackground,
            elevation: 0,
            expandedHeight: 0,
            toolbarHeight: 72,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'CookCash',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: context.colors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Hai, Budi!',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.colors.surface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.waving_hand, size: 12, color: context.colors.surface),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/notifications'),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(Icons.notifications_rounded, size: 22, color: context.colors.textHint),
                                if (unreadCount > 0)
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.orange500,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(color: context.colors.cardBackground, width: 1.5),
                                      ),
                                      child: Text(
                                        '$unreadCount',
                                        style: TextStyle(color: context.colors.cardBackground, fontSize: 9, fontWeight: FontWeight.w900),
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
                              border: Border.all(color: AppTheme.orange200, width: 2),
                            ),
                            child: const Center(
                              child: Text(
                                'B',
                                style: TextStyle(
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
              child: Container(color: context.colors.border, height: 1),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.orange200,
                    ),
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
                          color: context.colors.cardBackground,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 20.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.orange600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Budget: Waspada',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Color(0xFF9A3412),
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sisa uang makan tinggal 20% dari jatah minggu ini. Hati-hati defisit!',
                              style: TextStyle(
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
                GestureDetector(
                  onTap: () => context.go('/app/finance'),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
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
                        Positioned(
                          top: -30,
                          right: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: context.colors.cardBackground.withValues(alpha: 12.75),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFCBD5E1), size: 16),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: context.colors.cardBackground.withValues(alpha: 25.5),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: context.colors.cardBackground.withValues(alpha: 25.5)),
                                  ),
                                  child: Text(
                                    'Minggu Ini',
                                    style: TextStyle(
                                      color: context.colors.cardBackground,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'HARI INI',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rp 15.000',
                              style: TextStyle(
                                color: context.colors.cardBackground,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 1,
                              color: context.colors.cardBackground.withValues(alpha: 25.5),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_month_rounded, color: Color(0xFF94A3B8), size: 12),
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
                                    SizedBox(height: 6),
                                    Text(
                                      'Rp 450.000',
                                      style: TextStyle(
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
                                    color: context.colors.cardBackground.withValues(alpha: 25.5),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(Icons.arrow_forward, color: context.colors.cardBackground, size: 20),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'To-Do List Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.add_circle_outline, color: AppTheme.orange600, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Tambah',
                              style: TextStyle(
                                color: AppTheme.orange600,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const _TodoItem(
                  title: 'Rencana Makan Malam',
                  subtitle: 'Nasi Goreng Sosis (Budget sisa: Rp 15.000)',
                  isDone: false,
                ),
                const SizedBox(height: 10),
                const _TodoItem(
                  title: 'Beli Telur di Warung',
                  subtitle: 'Stok menipis, sisa 1 butir',
                  isDone: false,
                ),
                const SizedBox(height: 10),
                const _TodoItem(
                  title: 'Makan Siang',
                  subtitle: 'Soto Ayam (Rp 12.000)',
                  isDone: true,
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
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
        color: isDone ? context.colors.surface : context.colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
        boxShadow: isDone ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 10.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: isDone ? AppTheme.green500 : context.colors.textHint,
            size: 24,
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
                    color: isDone ? context.colors.surface : context.colors.textPrimary,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDone ? context.colors.textHint : context.colors.surface,
                    fontWeight: FontWeight.w500,
                  ),
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
