import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';

class _Transaction {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String date;
  final double amount;
  final bool isDebit;
  final TransactionCategory category;
  final int month; // 1-12
  final int year;

  const _Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.date,
    required this.amount,
    required this.isDebit,
    required this.category,
    required this.month,
    required this.year,
  });
}

enum TransactionCategory { food, grocery, cook, topup, refund }

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  String _period = 'Bulan Ini';
  int _touchedIndex = -1;
  String _mutationMonth = 'Semua';
  int _mutationYear = 0; // 0 = Semua

  static const _monthOptions = [
    'Semua', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const _yearOptions = [0, 2025, 2024, 2023]; // 0 = Semua

  final List<_Transaction> _transactions = const [
    _Transaction(id: '1', title: 'Pengisian Budget', subtitle: 'Budget masuk dari dompet', time: '08.00', date: 'Hari ini', amount: 500000, isDebit: false, category: TransactionCategory.topup, month: 5, year: 2025),
    _Transaction(id: '2', title: 'Nasi Goreng Telur', subtitle: 'Masak sendiri', time: '09.15', date: 'Hari ini', amount: 12000, isDebit: true, category: TransactionCategory.cook, month: 5, year: 2025),
    _Transaction(id: '3', title: 'Beli Mie Instan', subtitle: 'Warung Bu Sari • 4 bungkus', time: '11.30', date: 'Hari ini', amount: 14000, isDebit: true, category: TransactionCategory.grocery, month: 5, year: 2025),
    _Transaction(id: '4', title: 'Makan Siang Warteg', subtitle: 'Nasi + Sayur + Tempe', time: '13.00', date: 'Hari ini', amount: 15000, isDebit: true, category: TransactionCategory.food, month: 5, year: 2025),
    _Transaction(id: '5', title: 'Refund Belanja', subtitle: 'Kelebihan bayar dikembalikan', time: '15.20', date: 'Hari ini', amount: 3000, isDebit: false, category: TransactionCategory.refund, month: 5, year: 2025),
    _Transaction(id: '6', title: 'Kopi & Roti Bakar', subtitle: 'Sarapan di kantin', time: '07.45', date: 'Kemarin', amount: 18000, isDebit: true, category: TransactionCategory.food, month: 5, year: 2025),
    _Transaction(id: '7', title: 'Beli Telur 1 kg', subtitle: 'Toko Sembako Pak Budi', time: '10.00', date: 'Kemarin', amount: 28000, isDebit: true, category: TransactionCategory.grocery, month: 5, year: 2025),
    _Transaction(id: '8', title: 'Mie Nyemek Masak', subtitle: 'Masak sendiri dari stok', time: '12.30', date: 'Kemarin', amount: 5000, isDebit: true, category: TransactionCategory.cook, month: 5, year: 2025),
    _Transaction(id: '9', title: 'Ayam Goreng Lalapan', subtitle: 'Warung Pak Haji', time: '19.00', date: 'Kemarin', amount: 25000, isDebit: true, category: TransactionCategory.food, month: 5, year: 2025),
    _Transaction(id: '10', title: 'Belanja Bulanan', subtitle: 'Beras, bumbu, minyak', time: '09.00', date: '14 Mei', amount: 120000, isDebit: true, category: TransactionCategory.grocery, month: 5, year: 2025),
    _Transaction(id: '11', title: 'Makan Soto Ayam', subtitle: 'Warung Bu Dewi', time: '12.00', date: '20 Apr', amount: 15000, isDebit: true, category: TransactionCategory.food, month: 4, year: 2025),
    _Transaction(id: '12', title: 'Pengisian Budget', subtitle: 'Budget masuk dari dompet', time: '08.00', date: '1 Apr', amount: 500000, isDebit: false, category: TransactionCategory.topup, month: 4, year: 2025),
    _Transaction(id: '13', title: 'Beli Sayuran', subtitle: 'Pasar tradisional', time: '07.30', date: '5 Apr', amount: 35000, isDebit: true, category: TransactionCategory.grocery, month: 4, year: 2025),
    _Transaction(id: '14', title: 'Nasi Padang', subtitle: 'RM Sederhana', time: '13.00', date: '10 Mar', amount: 22000, isDebit: true, category: TransactionCategory.food, month: 3, year: 2025),
    _Transaction(id: '15', title: 'Pengisian Budget', subtitle: 'Budget masuk dari dompet', time: '08.00', date: '1 Mar', amount: 500000, isDebit: false, category: TransactionCategory.topup, month: 3, year: 2025),
    _Transaction(id: '16', title: 'Makan Sate Ayam', subtitle: 'Sate Pak Kumis', time: '18.30', date: '25 Des 2024', amount: 30000, isDebit: true, category: TransactionCategory.food, month: 12, year: 2024),
    _Transaction(id: '17', title: 'Pengisian Budget', subtitle: 'Budget masuk dari dompet', time: '08.00', date: '1 Des 2024', amount: 500000, isDebit: false, category: TransactionCategory.topup, month: 12, year: 2024),
    _Transaction(id: '18', title: 'Belanja Akhir Tahun', subtitle: 'Stok bahan masak', time: '10.00', date: '20 Des 2024', amount: 150000, isDebit: true, category: TransactionCategory.grocery, month: 12, year: 2024),
  ];

  final List<FlSpot> _lineSpots = const [
    FlSpot(0, 15000), FlSpot(1, 30000), FlSpot(2, 45000), FlSpot(3, 20000),
    FlSpot(4, 50000), FlSpot(5, 15000), FlSpot(6, 65000),
  ];
  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  IconData _categoryIcon(TransactionCategory c) {
    switch (c) {
      case TransactionCategory.food:     return Icons.restaurant_rounded;
      case TransactionCategory.grocery:  return Icons.shopping_basket_rounded;
      case TransactionCategory.cook:     return Icons.outdoor_grill_rounded;
      case TransactionCategory.topup:    return Icons.add_circle_rounded;
      case TransactionCategory.refund:   return Icons.undo_rounded;
    }
  }

  Color _categoryColor(TransactionCategory c) {
    switch (c) {
      case TransactionCategory.food:     return AppTheme.orange500;
      case TransactionCategory.grocery:  return AppTheme.blue500;
      case TransactionCategory.cook:     return AppTheme.green600;
      case TransactionCategory.topup:    return const Color(0xFF8B5CF6);
      case TransactionCategory.refund:   return AppTheme.green500;
    }
  }

  Color _categoryBg(TransactionCategory c) {
    switch (c) {
      case TransactionCategory.food:     return AppTheme.orange50;
      case TransactionCategory.grocery:  return AppTheme.blue50;
      case TransactionCategory.cook:     return AppTheme.green50;
      case TransactionCategory.topup:    return AppTheme.purple50;
      case TransactionCategory.refund:   return AppTheme.green50;
    }
  }

  /// Transactions filtered by selected mutation month + year
  List<_Transaction> get _filteredTransactions {
    return _transactions.where((t) {
      final monthMatch = _mutationMonth == 'Semua' || t.month == _monthOptions.indexOf(_mutationMonth);
      final yearMatch = _mutationYear == 0 || t.year == _mutationYear;
      return monthMatch && yearMatch;
    }).toList();
  }

  Map<String, List<_Transaction>> get _grouped {
    final map = <String, List<_Transaction>>{};
    for (final t in _filteredTransactions) {
      map.putIfAbsent(t.date, () => []).add(t);
    }
    return map;
  }

  String _formatRp(double v) => v.abs()
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _MutationFilterPicker(
        currentMonth: _mutationMonth,
        currentYear: _mutationYear,
        monthOptions: _monthOptions,
        yearOptions: _yearOptions,
        onSelect: (month, year) => setState(() {
          _mutationMonth = month;
          _mutationYear = year;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalOut = _transactions.where((t) => t.isDebit).fold(0.0, (s, t) => s + t.amount);
    final totalIn  = _transactions.where((t) => !t.isDebit).fold(0.0, (s, t) => s + t.amount);
    final balance  = totalIn - totalOut;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: context.colors.cardBackground,
            elevation: 0,
            toolbarHeight: 56,
            automaticallyImplyLeading: false,
            title: Text(
              'Laporan Keuangan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.4),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: context.colors.cardBackground,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (_) => _PeriodPicker(current: _period, onSelect: (p) => setState(() => _period = p)),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(children: [
                    Text(_period, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.textSecondary)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: context.colors.textHint),
                  ]),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: context.colors.border, height: 1),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([

              // ── Balance Card ──
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SALDO BUDGET', style: TextStyle(color: AppTheme.slate400, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${_formatRp(balance)}',
                      style: TextStyle(
                        color: balance >= 0 ? Colors.white : AppTheme.red500,
                        fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _BalanceItem(label: 'Pemasukan', amount: totalIn, isPositive: true)),
                        Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1)),
                        Expanded(child: _BalanceItem(label: 'Pengeluaran', amount: totalOut, isPositive: false)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Summary chips ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _SummaryChip(label: 'Rata-rata/Hari', value: 'Rp 34.285', icon: Icons.bar_chart_rounded, color: AppTheme.blue500, bg: AppTheme.blue50)),
                    SizedBox(width: 12),
                    Expanded(child: _SummaryChip(label: 'Prediksi Akhir', value: 'Rp 1.028.000', icon: Icons.warning_rounded, color: AppTheme.red500, bg: AppTheme.red50, isWarning: true)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Warning banner ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.orange50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.orange200),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline_rounded, color: AppTheme.orange600, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prediksi Akhir Bulan: Defisit', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF431407), fontSize: 13)),
                          SizedBox(height: 4),
                          Text(
                            'Dengan pengeluaran saat ini, diprediksi total pengeluaran akhir bulan mencapai Rp1.028.000 (melebihi budget Rp900.000). Kurangi jajan di luar!',
                            style: TextStyle(fontSize: 12, color: Color(0xFF9A3412), fontWeight: FontWeight.w500, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Spending trend chart ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tren Pengeluaran Harian', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.colors.textPrimary)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 160,
                      child: LineChart(LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20000,
                          getDrawingHorizontalLine: (_) => FlLine(color: context.colors.border, strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            interval: 20000,
                            getTitlesWidget: (v, m) => Text(
                              '${(v / 1000).toInt()}k',
                              style: TextStyle(fontSize: 9, color: context.colors.textHint, fontWeight: FontWeight.w600),
                            ),
                          )),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, m) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                v.toInt() < _days.length ? _days[v.toInt()] : '',
                                style: TextStyle(fontSize: 10, color: context.colors.textHint, fontWeight: FontWeight.w600),
                              ),
                            ),
                          )),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _lineSpots,
                            isCurved: true,
                            color: AppTheme.orange600,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                                radius: 4,
                                color: AppTheme.orange600,
                                strokeWidth: 2,
                                strokeColor: context.colors.cardBackground,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [AppTheme.orange500.withValues(alpha: 0.18), AppTheme.orange500.withValues(alpha: 0)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        minY: 0,
                        maxY: 80000,
                      )),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Composition pie ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Komposisi Pengeluaran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.colors.textPrimary)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          width: 120, height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 32,
                                pieTouchData: PieTouchData(touchCallback: (e, resp) {
                                  setState(() => _touchedIndex = resp?.touchedSection?.touchedSectionIndex ?? -1);
                                }),
                                sections: [
                                  PieChartSectionData(value: 150000, color: AppTheme.orange500, radius: _touchedIndex == 0 ? 32 : 28, showTitle: false),
                                  PieChartSectionData(value: 90000,  color: AppTheme.blue500,   radius: _touchedIndex == 1 ? 32 : 28, showTitle: false),
                                  PieChartSectionData(value: 60000,  color: AppTheme.green500,  radius: _touchedIndex == 2 ? 32 : 28, showTitle: false),
                                ],
                              )),
                              Text('62%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.colors.textPrimary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LegendItem(color: AppTheme.orange500, label: 'Masak Sendiri', value: 'Rp 150.000'),
                            SizedBox(height: 12),
                            _LegendItem(color: AppTheme.blue500,   label: 'Beli di Luar',   value: 'Rp 90.000'),
                            SizedBox(height: 12),
                            _LegendItem(color: AppTheme.green500,  label: 'Belanja Bahan',  value: 'Rp 60.000'),
                          ],
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Mutation header with month filter ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mutasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.3)),
                    Row(
                      children: [
                        // Month filter chip
                        GestureDetector(
                          onTap: _showMonthPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (_mutationMonth != 'Semua' || _mutationYear != 0) ? AppTheme.orange50 : context.colors.border,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: (_mutationMonth != 'Semua' || _mutationYear != 0) ? AppTheme.orange200 : Colors.transparent,
                              ),
                            ),
                            child: Row(children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 14,
                                color: (_mutationMonth != 'Semua' || _mutationYear != 0) ? AppTheme.orange600 : context.colors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                [
                                  if (_mutationYear != 0) '$_mutationYear',
                                  if (_mutationMonth != 'Semua') _mutationMonth,
                                  if (_mutationMonth == 'Semua' && _mutationYear == 0) 'Semua',
                                ].join(' · '),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: (_mutationMonth != 'Semua' || _mutationYear != 0) ? AppTheme.orange600 : context.colors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: (_mutationMonth != 'Semua' || _mutationYear != 0) ? AppTheme.orange600 : context.colors.textHint,
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.orange50,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: AppTheme.orange200),
                          ),
                          child: const Row(children: [
                            Icon(Icons.filter_list_rounded, size: 14, color: AppTheme.orange600),
                            SizedBox(width: 4),
                            Text('Filter', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.orange600)),
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Empty state for mutation when no data ──
              if (_grouped.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: context.colors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 40, color: context.colors.textHint),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada mutasi ditemukan',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: context.colors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coba ubah filter bulan atau tahun',
                        style: TextStyle(fontSize: 12, color: context.colors.textHint),
                      ),
                    ],
                  ),
                )
              else
                ..._grouped.entries.map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Row(children: [
                        Text(entry.key, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textSecondary, letterSpacing: 0.3)),
                        const SizedBox(width: 8),
                        Expanded(child: Divider(color: context.colors.border, height: 1)),
                        const SizedBox(width: 8),
                        Text(
                          '- Rp ${_formatRp(entry.value.where((t) => t.isDebit).fold(0.0, (s, t) => s + t.amount))}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.red500),
                        ),
                      ]),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: context.colors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.colors.border),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: entry.value.asMap().entries.map((e) {
                          final t = e.value;
                          final isLast = e.key == entry.value.length - 1;
                          return _MutationRow(
                            transaction: t,
                            isLast: isLast,
                            categoryIcon: _categoryIcon(t.category),
                            categoryColor: _categoryColor(t.category),
                            categoryBg: _categoryBg(t.category),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                )).toList(),

              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Mutation Filter Picker Bottom Sheet (Year + Month) ──
class _MutationFilterPicker extends StatefulWidget {
  final String currentMonth;
  final int currentYear;
  final List<String> monthOptions;
  final List<int> yearOptions;
  final void Function(String month, int year) onSelect;

  const _MutationFilterPicker({
    required this.currentMonth,
    required this.currentYear,
    required this.monthOptions,
    required this.yearOptions,
    required this.onSelect,
  });

  @override
  State<_MutationFilterPicker> createState() => _MutationFilterPickerState();
}

class _MutationFilterPickerState extends State<_MutationFilterPicker> {
  late String _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.currentMonth;
    _selectedYear = widget.currentYear;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: Container(width: 36, height: 4, decoration: BoxDecoration(color: context.colors.border, borderRadius: BorderRadius.circular(2))),
          ),
        ),
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Filter Mutasi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: context.colors.textPrimary)),
        ),
        const SizedBox(height: 20),

        // ── Year section ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Tahun', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textSecondary, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.yearOptions.map((y) {
              final isSelected = y == _selectedYear;
              final label = y == 0 ? 'Semua' : '$y';
              return GestureDetector(
                onTap: () => setState(() => _selectedYear = y),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.orange600 : context.colors.border,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : context.colors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // ── Month section ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Bulan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textSecondary, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.monthOptions.map((m) {
              final isSelected = m == _selectedMonth;
              return GestureDetector(
                onTap: () => setState(() => _selectedMonth = m),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.orange600 : context.colors.border,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    m,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : context.colors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // ── Apply button ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Reset
              GestureDetector(
                onTap: () {
                  widget.onSelect('Semua', 0);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Reset', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.textSecondary)),
                ),
              ),
              const SizedBox(width: 10),
              // Terapkan
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onSelect(_selectedMonth, _selectedYear);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppTheme.orange600,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Terapkan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _MutationRow extends StatelessWidget {
  final _Transaction transaction;
  final bool isLast;
  final IconData categoryIcon;
  final Color categoryColor;
  final Color categoryBg;
  const _MutationRow({required this.transaction, required this.isLast, required this.categoryIcon, required this.categoryColor, required this.categoryBg});

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: categoryBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(categoryIcon, color: categoryColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.colors.textPrimary)),
                const SizedBox(height: 2),
                Text(transaction.subtitle, style: TextStyle(fontSize: 11, color: context.colors.textHint, fontWeight: FontWeight.w500)),
              ],
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isDebit ? '-' : '+'}Rp ${_fmt(transaction.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: transaction.isDebit ? context.colors.textPrimary : AppTheme.green600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(transaction.time, style: TextStyle(fontSize: 10, color: context.colors.textHint, fontWeight: FontWeight.w500)),
              ],
            ),
          ]),
        ),
        if (!isLast) Divider(height: 1, color: context.colors.border, indent: 68),
      ],
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isPositive;
  const _BalanceItem({required this.label, required this.amount, required this.isPositive});

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 13, color: isPositive ? AppTheme.green500 : AppTheme.red500),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.slate400, fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 4),
      Text('Rp ${_fmt(amount)}', style: TextStyle(color: isPositive ? AppTheme.green500 : AppTheme.red500, fontWeight: FontWeight.w800, fontSize: 13)),
    ]);
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool isWarning;
  const _SummaryChip({required this.label, required this.value, required this.icon, required this.color, required this.bg, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isWarning ? AppTheme.red600 : context.colors.textPrimary)),
        ])),
      ]),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendItem({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
      ])),
    ]);
  }
}

class _PeriodPicker extends StatelessWidget {
  final String current;
  final Function(String) onSelect;
  const _PeriodPicker({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const options = ['Hari Ini', 'Minggu Ini', 'Bulan Ini', '3 Bulan Terakhir'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4, decoration: BoxDecoration(color: context.colors.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text('Pilih Periode', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: context.colors.textPrimary)),
        const SizedBox(height: 12),
        ...options.map((o) => ListTile(
          leading: Icon(
            o == current ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
            color: o == current ? AppTheme.orange600 : context.colors.textHint,
            size: 20,
          ),
          title: Text(o, style: TextStyle(
            fontWeight: o == current ? FontWeight.w700 : FontWeight.w500,
            color: o == current ? AppTheme.orange600 : context.colors.textSecondary,
          )),
          onTap: () { onSelect(o); Navigator.pop(context); },
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Mutasi Item ───────────────────────────────────────────────
class _MutasiItem extends StatelessWidget {
  final dynamic item;
  final String Function(double) formatRupiah;
  const _MutasiItem({required this.item, required this.formatRupiah});

  @override
  Widget build(BuildContext context) {
    final jenis = item['Jenis_Pengeluaran'] ?? 'Beli';
    final jumlah = (item['Total Pengeluaran'] ?? 0).toDouble();
    final tanggal = item['Tanggal'] ?? '';
    final isMasak = jenis == 'Masak';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 10.2),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMasak ? AppTheme.orange50 : AppTheme.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isMasak ? Icons.restaurant_rounded : Icons.shopping_bag_rounded,
              color: isMasak ? AppTheme.orange600 : AppTheme.slate500,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMasak ? 'Masak Sendiri' : 'Beli / Jajan',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.slate800),
                ),
                Text(tanggal,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.slate400,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // Jumlah
          Text(
            formatRupiah(jumlah),
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: AppTheme.slate800),
          ),
        ],
      ),
    );
  }
}
