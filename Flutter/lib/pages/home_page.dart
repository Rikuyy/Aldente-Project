import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/dashboard_service.dart';

<<<<<<< HEAD
=======
class _Recommendation {
  final IconData icon;
  final String name;
  final String category;
  final String estimasi;
  final Color color;
  final Color bgColor;
  const _Recommendation(
      {required this.icon,
      required this.name,
      required this.category,
      required this.estimasi,
      required this.color,
      required this.bgColor});
}

class _StockReminder {
  final String id;
  final String name;
  final IconData icon;
  final Color iconColor;
  final ReminderType type;
  final double currentQty;
  final double maxQty;
  final String unit;
  final int daysAgo;
  final int maxDays;

  const _StockReminder({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.type,
    required this.currentQty,
    required this.maxQty,
    required this.unit,
    required this.daysAgo,
    required this.maxDays,
  });

  double get stockPercent => (currentQty / maxQty).clamp(0.0, 1.0);
  double get freshnessPercent => (1 - daysAgo / maxDays).clamp(0.0, 1.0);
  int get daysLeft => (maxDays - daysAgo).clamp(0, maxDays);
}

enum ReminderType { lowStock, expiringSoon }

>>>>>>> 3dce3ded2007c2340c53492b0ffca3ec2144b212
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  final PageController _recPageCtrl = PageController(viewportFraction: 0.82);

  @override
  void dispose() {
    _recPageCtrl.dispose();
    super.dispose();
  }

  static const _categories = [
    'Semua',
    'Masak Sendiri',
    'Sarapan',
    'Makan Siang',
    'Makan Malam'
  ];

  static const _allRecommendations = [
    _Recommendation(
        icon: Icons.restaurant_rounded,
        name: 'Nasi Goreng Telur',
        category: 'Masak Sendiri',
        estimasi: 'Rp 8.000',
        color: AppTheme.orange500,
        bgColor: AppTheme.orange50),
    _Recommendation(
        icon: Icons.lunch_dining_rounded,
        name: 'Mie Nyemek Pedas',
        category: 'Masak Sendiri',
        estimasi: 'Rp 5.000',
        color: AppTheme.red500,
        bgColor: AppTheme.red50),
    _Recommendation(
        icon: Icons.outdoor_grill_rounded,
        name: 'Ayam Bakar Kecap',
        category: 'Makan Malam',
        estimasi: 'Rp 12.000',
        color: AppTheme.green600,
        bgColor: AppTheme.green50),
    _Recommendation(
        icon: Icons.egg_rounded,
        name: 'Telur Dadar Sayur',
        category: 'Sarapan',
        estimasi: 'Rp 4.000',
        color: AppTheme.orange400,
        bgColor: AppTheme.orange50),
    _Recommendation(
        icon: Icons.rice_bowl_rounded,
        name: 'Nasi Uduk Sederhana',
        category: 'Sarapan',
        estimasi: 'Rp 6.000',
        color: AppTheme.blue500,
        bgColor: AppTheme.blue50),
    _Recommendation(
        icon: Icons.ramen_dining_rounded,
        name: 'Soto Ayam Kuah',
        category: 'Makan Siang',
        estimasi: 'Rp 10.000',
        color: AppTheme.purple600,
        bgColor: AppTheme.purple50),
  ];

  static const _stockReminders = [
    _StockReminder(
        id: '1',
        name: 'Telur Ayam',
        type: ReminderType.lowStock,
        icon: Icons.egg_rounded,
        iconColor: AppTheme.orange400,
        currentQty: 2,
        maxQty: 12,
        unit: 'butir',
        daysAgo: 1,
        maxDays: 7),
    _StockReminder(
        id: '2',
        name: 'Dada Ayam',
        type: ReminderType.expiringSoon,
        icon: Icons.lunch_dining_rounded,
        iconColor: AppTheme.orange500,
        currentQty: 250,
        maxQty: 500,
        unit: 'gram',
        daysAgo: 5,
        maxDays: 7),
    _StockReminder(
        id: '3',
        name: 'Tomat',
        type: ReminderType.expiringSoon,
        icon: Icons.spa_rounded,
        iconColor: AppTheme.red500,
        currentQty: 2,
        maxQty: 6,
        unit: 'pcs',
        daysAgo: 4,
        maxDays: 5),
    _StockReminder(
        id: '4',
        name: 'Minyak Goreng',
        type: ReminderType.lowStock,
        icon: Icons.opacity_rounded,
        iconColor: AppTheme.blue500,
        currentQty: 200,
        maxQty: 1000,
        unit: 'ml',
        daysAgo: 2,
        maxDays: 30),
  ];

  List<_Recommendation> get _filteredRecs {
    final cat = _categories[_selectedCategoryIndex];
    if (cat == 'Semua') return _allRecommendations;
    return _allRecommendations.where((r) => r.category == cat).toList();
  }

  _Recommendation get _topRec => _filteredRecs.first;
  List<_Recommendation> get _otherRecs => _filteredRecs.skip(1).toList();

  List<_StockReminder> get _lowStockReminders =>
      _stockReminders.where((s) => s.type == ReminderType.lowStock).toList();
  List<_StockReminder> get _expiringReminders => _stockReminders
      .where((s) => s.type == ReminderType.expiringSoon)
      .toList();

  @override
  Widget build(BuildContext context) {
    const unreadCount = 3;

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
                        Text('CookCash',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: context.colors.textPrimary,
                                letterSpacing: -0.5)),
                        Row(children: [
                          Text('Hai, Budi!',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textSecondary)),
                          const SizedBox(width: 4),
                          const Icon(Icons.waving_hand,
                              size: 12, color: AppTheme.orange400),
                        ]),
                      ],
                    ),
                    Row(children: [
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(50)),
                          child: Stack(clipBehavior: Clip.none, children: [
                            Icon(Icons.notifications_rounded,
                                size: 22, color: context.colors.textHint),
                            if (unreadCount > 0)
                              Positioned(
                                  top: -6,
                                  right: -6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: AppTheme.orange500,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color:
                                                context.colors.cardBackground,
                                            width: 1.5)),
                                    child: Text('$unreadCount',
                                        style: TextStyle(
                                            color:
                                                context.colors.cardBackground,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900)),
                                  )),
                          ]),
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
                                  color: AppTheme.orange200, width: 2)),
                          child: const Center(
                              child: Text('B',
                                  style: TextStyle(
                                      color: AppTheme.orange600,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16))),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: context.colors.border, height: 1)),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.orange200),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
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
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1))
                                ]),
                            child: const Icon(Icons.warning_amber_rounded,
                                color: AppTheme.orange600, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Status Budget: Waspada',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: Color(0xFF9A3412),
                                        letterSpacing: -0.3)),
                                SizedBox(height: 4),
                                Text(
                                    'Sisa uang makan tinggal 20% dari jatah minggu ini. Hati-hati defisit!',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFC2410C),
                                        fontWeight: FontWeight.w500,
                                        height: 1.5)),
                              ])),
                        ]),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
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
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.slate900.withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 10))
                        ],
                      ),
                      child: Stack(children: [
                        Positioned(
                            top: -24,
                            right: -24,
                            child: Container(
                                width: 110,
                                height: 110,
                                decoration: const BoxDecoration(
                                    color: Color(0x0FFFFFFF),
                                    shape: BoxShape.circle))),
                        Positioned(
                            bottom: -16,
                            left: -16,
                            child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                    color: Color(0x08FFFFFF),
                                    shape: BoxShape.circle))),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(children: [
                                        Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            color: Color(0xFFCBD5E1),
                                            size: 16),
                                        SizedBox(width: 8),
                                        Text('SISA BUDGET',
                                            style: TextStyle(
                                                color: Color(0xFFCBD5E1),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.2)),
                                      ]),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: const Color(0x1AFFFFFF),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                                color:
                                                    const Color(0x1AFFFFFF))),
                                        child: const Text('Minggu Ini',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ]),
                                const SizedBox(height: 16),
                                const Text('HARI INI',
                                    style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2)),
                                const SizedBox(height: 4),
                                const Text('Rp 15.000',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1)),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: const LinearProgressIndicator(
                                      value: 0.20,
                                      minHeight: 5,
                                      backgroundColor: Color(0x1AFFFFFF),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.orange400)),
                                ),
                                const SizedBox(height: 6),
                                const Text('20% dari budget minggu ini tersisa',
                                    style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 18),
                                Container(
                                    height: 1, color: const Color(0x1AFFFFFF)),
                                const SizedBox(height: 18),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Icon(Icons.calendar_month_rounded,
                                                  color: Color(0xFF94A3B8),
                                                  size: 11),
                                              SizedBox(width: 4),
                                              Text('SISA BULAN INI',
                                                  style: TextStyle(
                                                      color: Color(0xFF94A3B8),
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 1.5)),
                                            ]),
                                            SizedBox(height: 4),
                                            Text('Rp 450.000',
                                                style: TextStyle(
                                                    color: Color(0xFFE2E8F0),
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ]),
                                      Row(children: [
                                        const _FinanceStat(
                                            label: 'Keluar',
                                            value: 'Rp 50k',
                                            color: AppTheme.red400),
                                        const SizedBox(width: 12),
                                        const _FinanceStat(
                                            label: 'Masuk',
                                            value: 'Rp 500k',
                                            color: AppTheme.green500),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: const Color(0x1AFFFFFF),
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 18),
                                        ),
                                      ]),
                                    ]),
                              ]),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rekomendasi Untukmu',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: context.colors.textPrimary,
                                letterSpacing: -0.5)),
                        GestureDetector(
                          onTap: () => context.go('/app/consultation'),
                          child: const Text('Lihat Semua',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.orange600)),
                        ),
                      ]),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final isSelected = _selectedCategoryIndex == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategoryIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                          ),
                          child: Text(_categories[i],
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : context.colors.textSecondary)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (_filteredRecs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => context.go('/app/consultation'),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _topRec.color.withValues(alpha: 0.12),
                              _topRec.color.withValues(alpha: 0.03)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: _topRec.color.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: _topRec.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: _topRec.color.withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6))
                              ],
                            ),
                            child: Icon(_topRec.icon,
                                color: Colors.white, size: 34),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: _topRec.color,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: const Text('Pilihan Terbaik dari Kita',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3)),
                                ),
                                const SizedBox(height: 6),
                                Text(_topRec.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: context.colors.textPrimary,
                                        letterSpacing: -0.4)),
                                const SizedBox(height: 4),
                                Text(_topRec.category,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: context.colors.textSecondary,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: AppTheme.green50,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.payments_rounded,
                                              size: 10,
                                              color: AppTheme.green600),
                                          const SizedBox(width: 3),
                                          Text(_topRec.estimasi,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.green600)),
                                        ]),
                                  ),
                                ]),
                              ])),
                          Icon(Icons.chevron_right_rounded,
                              color: _topRec.color, size: 24),
                        ]),
                      ),
                    ),
                  ),
<<<<<<< HEAD

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
=======
                const SizedBox(height: 12),
                if (_otherRecs.isNotEmpty)
                  SizedBox(
                    height: 160,
                    child: PageView.builder(
                      controller: _recPageCtrl,
                      itemCount: _otherRecs.length,
                      itemBuilder: (_, i) {
                        final rec = _otherRecs[i];
                        return Padding(
                          padding:
                              EdgeInsets.only(right: 12, left: i == 0 ? 20 : 0),
                          child: GestureDetector(
                            onTap: () => context.go('/app/consultation'),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.colors.cardBackground,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: context.colors.border),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ],
>>>>>>> 3dce3ded2007c2340c53492b0ffca3ec2144b212
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                            color: rec.bgColor,
                                            shape: BoxShape.circle),
                                        child: Icon(rec.icon,
                                            color: rec.color, size: 20),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                            color: rec.bgColor,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: Text(rec.category,
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: rec.color)),
                                      ),
                                    ]),
                                    const SizedBox(height: 10),
                                    Text(rec.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: context.colors.textPrimary,
                                            letterSpacing: -0.3),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const Spacer(),
                                    Row(children: [
                                      const Icon(Icons.payments_rounded,
                                          size: 11, color: AppTheme.green600),
                                      const SizedBox(width: 3),
                                      Text(rec.estimasi,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.green600)),
                                      const Spacer(),
                                      Icon(Icons.arrow_forward_ios_rounded,
                                          size: 11,
                                          color: context.colors.textHint),
                                    ]),
                                  ]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reminder Stok',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: context.colors.textPrimary,
                                letterSpacing: -0.5)),
                        GestureDetector(
                          onTap: () => context.go('/app/inventory'),
                          child: const Text('Lihat Stok',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.orange600)),
                        ),
                      ]),
                ),
                const SizedBox(height: 12),
                if (_lowStockReminders.isNotEmpty ||
                    _expiringReminders.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.red50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.red200),
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
                                        color: Colors.black
                                            .withValues(alpha: 0.06),
                                        blurRadius: 4)
                                  ]),
                              child: const Icon(Icons.inventory_2_rounded,
                                  color: AppTheme.red500, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                    '${_lowStockReminders.length + _expiringReminders.length} item perlu perhatian',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: AppTheme.red600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_lowStockReminders.length} stok menipis · ${_expiringReminders.length} akan kedaluarsa',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.red500
                                            .withValues(alpha: 0.8)),
                                  ),
                                ])),
                            GestureDetector(
                              onTap: () => context.go('/app/inventory'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: AppTheme.red500,
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Text('Cek',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                            ),
                          ]),
                    ),
                  ),
                const SizedBox(height: 12),
                if (_lowStockReminders.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Row(children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppTheme.orange500,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Stok Menipis',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: context.colors.textSecondary,
                              letterSpacing: 0.3)),
                      const SizedBox(width: 8),
                      Expanded(child: Divider(color: context.colors.border)),
                    ]),
                  ),
                  ..._lowStockReminders.map((s) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: _StockReminderCard(
                            reminder: s,
                            onTap: () => context.go('/app/inventory')),
                      )),
                ],
                if (_expiringReminders.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Row(children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppTheme.red500, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Segera Kedaluarsa',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: context.colors.textSecondary,
                              letterSpacing: 0.3)),
                      const SizedBox(width: 8),
                      Expanded(child: Divider(color: context.colors.border)),
                    ]),
                  ),
                  ..._expiringReminders.map((s) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: _StockReminderCard(
                            reminder: s,
                            onTap: () => context.go('/app/inventory')),
                      )),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
<<<<<<< HEAD
=======

class _StockReminderCard extends StatefulWidget {
  final _StockReminder reminder;
  final VoidCallback onTap;
  const _StockReminderCard({required this.reminder, required this.onTap});

  @override
  State<_StockReminderCard> createState() => _StockReminderCardState();
}

class _StockReminderCardState extends State<_StockReminderCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _animCtrl.forward() : _animCtrl.reverse();
  }

  Color get _barColor {
    final r = widget.reminder;
    if (r.type == ReminderType.lowStock) {
      if (r.stockPercent < 0.2) return AppTheme.red500;
      if (r.stockPercent < 0.5) return AppTheme.orange500;
      return AppTheme.green500;
    } else {
      if (r.freshnessPercent < 0.2) return AppTheme.red500;
      if (r.freshnessPercent < 0.5) return AppTheme.orange500;
      return AppTheme.green500;
    }
  }

  double get _barValue => widget.reminder.type == ReminderType.lowStock
      ? widget.reminder.stockPercent
      : widget.reminder.freshnessPercent;

  @override
  Widget build(BuildContext context) {
    final r = widget.reminder;
    final isLow = r.type == ReminderType.lowStock;
    final accentColor = isLow ? AppTheme.orange500 : AppTheme.red500;
    final bgColor = isLow ? AppTheme.orange50 : AppTheme.red50;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: _expanded
                  ? accentColor.withValues(alpha: 0.3)
                  : context.colors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(r.icon, color: r.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(r.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: context.colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    isLow
                        ? '${r.currentQty.toInt()} ${r.unit} tersisa'
                        : 'Diinput ${r.daysAgo} hari lalu · ${r.daysLeft} hari lagi',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accentColor),
                  ),
                ])),
            // Countdown chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(50)),
              child: Text(
                isLow
                    ? '${(r.stockPercent * 100).toInt()}%'
                    : '${r.daysLeft}h lagi',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accentColor),
              ),
            ),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: context.colors.textHint),
            ),
          ]),
          SizeTransition(
            sizeFactor: _expandAnim,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 12),
              // Progress bar
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isLow ? 'Sisa Stok' : 'Kesegaran',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.textHint),
                              ),
                              Text(
                                isLow
                                    ? '${r.currentQty.toInt()} / ${r.maxQty.toInt()} ${r.unit}'
                                    : 'Hari ke-${r.daysAgo} dari ${r.maxDays}',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.textSecondary),
                              ),
                            ]),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _barValue,
                            minHeight: 8,
                            backgroundColor: context.colors.border,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_barColor),
                          ),
                        ),
                      ]),
                ),
              ]),
              const SizedBox(height: 12),
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onTap,
                  icon: Icon(
                      isLow
                          ? Icons.add_shopping_cart_rounded
                          : Icons.inventory_2_rounded,
                      size: 16),
                  label: Text(isLow ? 'Tambah Stok' : 'Lihat di Inventori'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FinanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FinanceStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(label,
          style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 9,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(value,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w800)),
    ]);
  }
}
>>>>>>> 3dce3ded2007c2340c53492b0ffca3ec2144b212
