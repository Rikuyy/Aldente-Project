import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const unreadCount = 3;

    // Top recommendation
    const topRec = _Recommendation(
      icon: Icons.restaurant_rounded,
      name: 'Nasi Goreng Telur',
      category: 'Masak Sendiri',
      estimasi: 'Rp 8.000',
      kcal: '420 kkal',
      color: AppTheme.orange500,
      bgColor: AppTheme.orange50,
    );

    const recommendations = [
      _Recommendation(
        icon: Icons.lunch_dining_rounded,
        name: 'Mie Nyemek Pedas',
        category: 'Masak Sendiri',
        estimasi: 'Rp 5.000',
        kcal: '380 kkal',
        color: AppTheme.red500,
        bgColor: AppTheme.red50,
      ),
      _Recommendation(
        icon: Icons.outdoor_grill_rounded,
        name: 'Ayam Bakar Kecap',
        category: 'Masak Sendiri',
        estimasi: 'Rp 12.000',
        kcal: '510 kkal',
        color: AppTheme.green600,
        bgColor: AppTheme.green50,
      ),
    ];

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
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
                        Text('CookCash', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
                        Row(children: [
                          Text('Hai, Budi!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
                          const SizedBox(width: 4),
                          const Icon(Icons.waving_hand, size: 12, color: AppTheme.orange400),
                        ]),
                      ],
                    ),
                    Row(children: [
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(50)),
                          child: Stack(clipBehavior: Clip.none, children: [
                            Icon(Icons.notifications_rounded, size: 22, color: context.colors.textHint),
                            if (unreadCount > 0)
                              Positioned(
                                top: -6, right: -6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.orange500,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: context.colors.cardBackground, width: 1.5),
                                  ),
                                  child: Text('$unreadCount', style: TextStyle(color: context.colors.cardBackground, fontSize: 9, fontWeight: FontWeight.w900)),
                                ),
                              ),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => context.go('/app/profile'),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: AppTheme.orange100, shape: BoxShape.circle, border: Border.all(color: AppTheme.orange200, width: 2)),
                          child: const Center(child: Text('B', style: TextStyle(color: AppTheme.orange600, fontWeight: FontWeight.w900, fontSize: 16))),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: context.colors.border, height: 1)),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Budget Warning ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.orange200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 1))]),
                      child: const Icon(Icons.warning_amber_rounded, color: AppTheme.orange600, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Status Budget: Waspada', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF9A3412), letterSpacing: -0.3)),
                      SizedBox(height: 4),
                      Text('Sisa uang makan tinggal 20% dari jatah minggu ini. Hati-hati defisit!',
                        style: TextStyle(fontSize: 12, color: Color(0xFFC2410C), fontWeight: FontWeight.w500, height: 1.5)),
                    ])),
                  ]),
                ),

                const SizedBox(height: 16),

                // ── Finance Card (redesigned) ──
                GestureDetector(
                  onTap: () => context.go('/app/finance'),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: AppTheme.slate900.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 10))],
                    ),
                    child: Stack(children: [
                      // Decorative circles
                      Positioned(top: -24, right: -24,
                        child: Container(width: 110, height: 110, decoration: const BoxDecoration(color: Color(0x0FFFFFFF), shape: BoxShape.circle))),
                      Positioned(bottom: -16, left: -16,
                        child: Container(width: 80, height: 80, decoration: const BoxDecoration(color: Color(0x08FFFFFF), shape: BoxShape.circle))),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Top row
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Row(children: [
                              Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFCBD5E1), size: 16),
                              SizedBox(width: 8),
                              Text('SISA BUDGET', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                            ]),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x1AFFFFFF),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: const Color(0x1AFFFFFF)),
                              ),
                              child: const Text('Minggu Ini', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ]),

                          const SizedBox(height: 16),

                          // Today's budget
                          const Text('HARI INI', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
                          const SizedBox(height: 4),
                          const Text('Rp 15.000', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1)),

                          const SizedBox(height: 4),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.20,
                              minHeight: 5,
                              backgroundColor: Color(0x1AFFFFFF),
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.orange400),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text('20% dari budget minggu ini tersisa', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w500)),

                          const SizedBox(height: 18),
                          Container(height: 1, color: const Color(0x1AFFFFFF)),
                          const SizedBox(height: 18),

                          // Bottom row
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Icon(Icons.calendar_month_rounded, color: Color(0xFF94A3B8), size: 11),
                                SizedBox(width: 4),
                                Text('SISA BULAN INI', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                              ]),
                              SizedBox(height: 4),
                              Text('Rp 450.000', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 20, fontWeight: FontWeight.w700)),
                            ]),
                            Row(children: [
                              // Quick stats
                              const _FinanceStat(label: 'Keluar', value: 'Rp 50k', color: AppTheme.red500),
                              const SizedBox(width: 12),
                              const _FinanceStat(label: 'Masuk', value: 'Rp 500k', color: AppTheme.green500),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                              ),
                            ]),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Rekomendasi Header ──
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Rekomendasi Untukmu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
                  GestureDetector(
                    onTap: () => context.go('/app/consultation'),
                    child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.orange600)),
                  ),
                ]),

                const SizedBox(height: 16),

                // ── Top Recommendation (featured) ──
                GestureDetector(
                  onTap: () => context.go('/app/consultation'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [topRec.color.withValues(alpha: 0.12), topRec.color.withValues(alpha: 0.04)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: topRec.color.withValues(alpha: 0.2)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(children: [
                      // Main icon circle
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: topRec.color,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: topRec.color.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: Icon(topRec.icon, color: Colors.white, size: 34),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: topRec.color, borderRadius: BorderRadius.circular(50)),
                          child: const Text('✨ Pilihan Terbaik', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                        ),
                        const SizedBox(height: 6),
                        Text(topRec.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: context.colors.textPrimary, letterSpacing: -0.4)),
                        const SizedBox(height: 4),
                        Text(topRec.category, style: TextStyle(fontSize: 11, color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(children: [
                          _RecTag(icon: Icons.payments_rounded, label: topRec.estimasi, color: AppTheme.green600, bg: AppTheme.green50),
                          const SizedBox(width: 6),
                          _RecTag(icon: Icons.local_fire_department_rounded, label: topRec.kcal, color: AppTheme.orange600, bg: AppTheme.orange50),
                        ]),
                      ])),
                      Icon(Icons.chevron_right_rounded, color: topRec.color, size: 24),
                    ]),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Other recommendations ──
                Row(children: recommendations.map((rec) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: rec == recommendations.last ? 0 : 8),
                    child: GestureDetector(
                      onTap: () => context.go('/app/consultation'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: context.colors.border),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Icon circle
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: rec.bgColor, shape: BoxShape.circle),
                            child: Icon(rec.icon, color: rec.color, size: 22),
                          ),
                          const SizedBox(height: 10),
                          Text(rec.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: context.colors.textPrimary, letterSpacing: -0.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(rec.category, style: TextStyle(fontSize: 10, color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.payments_rounded, size: 11, color: AppTheme.green600),
                            const SizedBox(width: 3),
                            Text(rec.estimasi, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.green600)),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.local_fire_department_rounded, size: 11, color: context.colors.textHint),
                            const SizedBox(width: 3),
                            Text(rec.kcal, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.colors.textHint)),
                          ]),
                        ]),
                      ),
                    ),
                  ),
                )).toList()),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Recommendation {
  final IconData icon;
  final String name;
  final String category;
  final String estimasi;
  final String kcal;
  final Color color;
  final Color bgColor;
  const _Recommendation({required this.icon, required this.name, required this.category, required this.estimasi, required this.kcal, required this.color, required this.bgColor});
}

class _FinanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FinanceStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
    ]);
  }
}

class _RecTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _RecTag({required this.icon, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}