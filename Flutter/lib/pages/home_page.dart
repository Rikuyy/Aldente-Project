import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DashboardService _dashboardService = DashboardService();

  bool _isLoading = true;
  String? _error;

  // Data dari API
  String _nama = 'Pengguna';
  String _inisial = 'P';
  int _unreadCount = 0;

  double _totalBudget = 0;
  double _totalKeluar = 0;
  double _sisaBulan = 0;
  double _sisaHariIni = 0;
  String _statusBudget = 'Aman';
  String? _pesanPeringatan;

  List _rekomendasiResep = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    final result = await _dashboardService.getDashboard();

    if (result['success'] == true) {
      final data = result['data']['data'];
      final pengguna = data['pengguna'];
      final budget = data['budget'];

      setState(() {
        _nama = pengguna['nama'] ?? 'Pengguna';
        _inisial = pengguna['inisial'] ?? 'P';
        _totalBudget = (budget['total_budget'] ?? 0).toDouble();
        _totalKeluar = (budget['total_keluar'] ?? 0).toDouble();
        _sisaBulan = (budget['sisa_bulan'] ?? 0).toDouble();
        _sisaHariIni = (budget['sisa_hari_ini'] ?? 0).toDouble();
        _statusBudget = budget['status'] ?? 'Aman';
        _pesanPeringatan = budget['pesan_peringatan'];
        _rekomendasiResep = data['rekomendasi_resep'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'];
        _isLoading = false;
      });
    }
  }

  String _formatRp(double v) => 'Rp ${v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )}';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
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
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: CustomScrollView(
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
                                'Hai, $_nama!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.surface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.waving_hand,
                                  size: 12, color: context.colors.surface),
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
                                  Icon(Icons.notifications_rounded,
                                      size: 22, color: context.colors.textHint),
                                  if (_unreadCount > 0)
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
                                              color:
                                                  context.colors.cardBackground,
                                              width: 1.5),
                                        ),
                                        child: Text(
                                          '$_unreadCount',
                                          style: TextStyle(
                                              color:
                                                  context.colors.cardBackground,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900),
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
                child: Container(color: context.colors.border, height: 1),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Banner Peringatan ──────────────────────────────
                  if (_pesanPeringatan != null)
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
                              color: context.colors.cardBackground,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(Icons.warning_amber_rounded,
                                color: AppTheme.orange600, size: 20),
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
                                  _pesanPeringatan!,
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

                  if (_pesanPeringatan != null) const SizedBox(height: 16),

                  // ── Kartu Budget ───────────────────────────────────
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            _formatRp(_sisaHariIni),
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
                            color: context.colors.cardBackground
                                .withValues(alpha: 25.5),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.calendar_month_rounded,
                                          color: Color(0xFF94A3B8), size: 12),
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
                                    _formatRp(_sisaBulan),
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
                                  color: context.colors.cardBackground
                                      .withValues(alpha: 25.5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.arrow_forward,
                                    color: context.colors.cardBackground,
                                    size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                  // ── To-Do List (masih dummy) ───────────────────────
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              Icon(Icons.add_circle_outline,
                                  color: AppTheme.orange600, size: 16),
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
      ),
    );
  }
}

class _TodoItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;
  const _TodoItem(
      {required this.title, required this.subtitle, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? context.colors.surface : context.colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
        boxShadow: isDone
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 10.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: isDone ? AppTheme.green500 : context.colors.textHint,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDone
                        ? context.colors.surface
                        : context.colors.textPrimary,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDone
                        ? context.colors.textHint
                        : context.colors.surface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}