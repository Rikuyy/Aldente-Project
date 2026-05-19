import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lineSpots = [
      const FlSpot(0, 15000),
      const FlSpot(1, 30000),
      const FlSpot(2, 45000),
      const FlSpot(3, 20000),
      const FlSpot(4, 50000),
      const FlSpot(5, 15000),
      const FlSpot(6, 65000),
    ];
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: context.colors.cardBackground,
            elevation: 0,
            toolbarHeight: 60,
            title: Text('Laporan Keuangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Text('Minggu Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.surface)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: context.colors.surface),
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: context.colors.border, height: 1)),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Total Pengeluaran',
                        value: 'Rp240.000',
                        trend: '+15% dari minggu lalu',
                        isPositive: false,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Rata-rata/Hari',
                        value: 'Rp34.285',
                        trend: 'Lebih hemat Rp5rb',
                        isPositive: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.orange50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.orange200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
                Container(
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
                      Text('Tren Pengeluaran Harian', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.colors.textPrimary, letterSpacing: 0.3)),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 20000,
                              getDrawingHorizontalLine: (_) => FlLine(color: context.colors.border, strokeWidth: 1),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: 20000,
                                  getTitlesWidget: (v, m) => Text(
                                    '${(v / 1000).toStringAsFixed(0)}k',
                                    style: TextStyle(fontSize: 9, color: context.colors.textHint, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, m) => Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      v.toInt() < days.length ? days[v.toInt()] : '',
                                      style: TextStyle(fontSize: 10, color: context.colors.textHint, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: lineSpots,
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
                                    colors: [AppTheme.orange500.withValues(alpha: 0.2), AppTheme.orange500.withValues(alpha: 0)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                            minY: 0,
                            maxY: 80000,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Container(
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
                          Expanded(
                            child: SizedBox(
                              height: 120,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PieChart(
                                    PieChartData(
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 32,
                                      sections: [
                                        PieChartSectionData(
                                          value: 150000,
                                          color: AppTheme.orange500,
                                          radius: 28,
                                          showTitle: false,
                                        ),
                                        PieChartSectionData(
                                          value: 90000,
                                          color: context.colors.border,
                                          radius: 28,
                                          showTitle: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '62%',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: context.colors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _LegendItem(color: AppTheme.orange500, label: 'Masak Sendiri', value: 'Rp150.000'),
                              const SizedBox(height: 16),
                              _LegendItem(color: context.colors.border, label: 'Jajan Luar', value: 'Rp90.000'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;

  const _SummaryCard({required this.label, required this.value, required this.trend, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: context.colors.surface, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_down : Icons.trending_up,
                size: 12,
                color: isPositive ? AppTheme.green500 : AppTheme.red500,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trend,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isPositive ? AppTheme.green500 : AppTheme.red500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.colors.textPrimary)),
        ),
      ],
    );
  }
}