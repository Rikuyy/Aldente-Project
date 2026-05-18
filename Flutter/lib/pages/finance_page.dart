import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  final FinanceService _service = FinanceService();

  bool _isLoading = true;
  String? _errorMsg;

  // Periode
  String _bulan = _bulanSekarang();

  // Ringkasan
  double _totalPengeluaran = 0;
  double _rataPerHari = 0;
  double _prediksiAkhirBulan = 0;
  double _trendPersen = 0;
  List<dynamic> _komposisi = [];
  int _persenMasak = 0;

  // Grafik
  List<FlSpot> _grafikSpots = [];
  double _maxY = 10000;

  // Mutasi
  List<dynamic> _mutasi = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  static String _bulanSekarang() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    await Future.wait([
      _loadRingkasan(),
      _loadGrafik(),
      _loadMutasi(reset: true),
    ]);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadRingkasan() async {
    final result = await _service.getRingkasan(_bulan);
    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        _totalPengeluaran = (data['total_pengeluaran'] ?? 0).toDouble();
        _rataPerHari = (data['rata_per_hari'] ?? 0).toDouble();
        _prediksiAkhirBulan = (data['prediksi_akhir_bulan'] ?? 0).toDouble();
        _trendPersen = (data['trend_persen'] ?? 0).toDouble();
        _komposisi = data['komposisi'] ?? [];
        _persenMasak = data['persen_masak'] ?? 0;
      });
    } else {
      setState(() => _errorMsg = result['message']);
    }
  }

  Future<void> _loadGrafik() async {
    final result = await _service.getGrafik(_bulan);
    if (!mounted) return;

    if (result['success'] == true) {
      final List<dynamic> data = result['data']['data'] ?? [];
      final spots = data.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), (e.value['jumlah'] ?? 0).toDouble());
      }).toList();

      final maxVal = spots.isEmpty
          ? 10000.0
          : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

      setState(() {
        _grafikSpots = spots;
        _maxY = maxVal > 0 ? maxVal * 1.2 : 10000;
      });
    }
  }

  Future<void> _loadMutasi({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _mutasi = [];
    }

    setState(() => _isLoadingMore = true);

    final result = await _service.getMutasi(_bulan, page: _currentPage);
    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        _mutasi.addAll(data['data'] ?? []);
        _lastPage = data['last_page'] ?? 1;
        _isLoadingMore = false;
      });
    } else {
      setState(() => _isLoadingMore = false);
    }
  }

  void _gantiBulan(int delta) {
    final parts = _bulan.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]) + delta;

    if (month > 12) {
      month = 1;
      year++;
    }
    if (month < 1) {
      month = 12;
      year--;
    }

    setState(() {
      _bulan = '$year-${month.toString().padLeft(2, '0')}';
    });
    _loadAll();
  }

  String _formatRupiah(double value) {
    if (value >= 1000000)
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} jt';
    if (value >= 1000) return 'Rp ${(value / 1000).toStringAsFixed(0)}.000';
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  String _namaBulan(String bulan) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final parts = bulan.split('-');
    final m = int.tryParse(parts[1]) ?? 1;
    return '${names[m]} ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _loadAll, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ───────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 60,
              title: const Text(
                'Laporan Keuangan',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.slate800,
                    letterSpacing: -0.5),
              ),
              actions: [
                // Navigasi bulan
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _gantiBulan(-1),
                      child: const Icon(Icons.chevron_left,
                          color: AppTheme.slate500),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.slate100,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        _namaBulan(_bulan),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slate500),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _gantiBulan(1),
                      child: const Icon(Icons.chevron_right,
                          color: AppTheme.slate500),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: AppTheme.slate100, height: 1),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // ── Summary Cards ─────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total Pengeluaran',
                          value: _formatRupiah(_totalPengeluaran),
                          trend: _trendPersen >= 0
                              ? '+${_trendPersen.toStringAsFixed(1)}% dari bulan lalu'
                              : '${_trendPersen.toStringAsFixed(1)}% dari bulan lalu',
                          isPositive: _trendPersen < 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Rata-rata/Hari',
                          value: _formatRupiah(_rataPerHari),
                          trend: 'Per hari bulan ini',
                          isPositive: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Warning Prediksi ──────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.orange50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.orange200),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 10.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppTheme.orange600, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Prediksi Akhir Bulan',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF431407),
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Estimasi total pengeluaran akhir bulan ini: ${_formatRupiah(_prediksiAkhirBulan)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9A3412),
                                    fontWeight: FontWeight.w500,
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Line Chart ────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.slate100),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 10.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tren Pengeluaran Harian',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.slate800,
                                letterSpacing: 0.3)),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 180,
                          child: _grafikSpots.isEmpty
                              ? const Center(
                                  child: Text('Belum ada data',
                                      style:
                                          TextStyle(color: AppTheme.slate400)))
                              : LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: _maxY / 4,
                                      getDrawingHorizontalLine: (_) =>
                                          const FlLine(
                                              color: AppTheme.slate100,
                                              strokeWidth: 1),
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          interval: _maxY / 4,
                                          getTitlesWidget: (v, m) => Text(
                                            '${(v / 1000).toStringAsFixed(0)}k',
                                            style: const TextStyle(
                                                fontSize: 9,
                                                color: AppTheme.slate400,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: (_grafikSpots.length / 7)
                                              .ceilToDouble(),
                                          getTitlesWidget: (v, m) {
                                            final idx = v.toInt();
                                            if (idx < 0 ||
                                                idx >= _grafikSpots.length)
                                              return const SizedBox();
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Text(
                                                '${idx + 1}',
                                                style: const TextStyle(
                                                    fontSize: 9,
                                                    color: AppTheme.slate400,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: _grafikSpots,
                                        isCurved: true,
                                        color: AppTheme.orange600,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (_, __, ___, ____) =>
                                              FlDotCirclePainter(
                                            radius: 4,
                                            color: AppTheme.orange600,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          ),
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.orange500
                                                  .withValues(alpha: 51),
                                              AppTheme.orange500
                                                  .withValues(alpha: 0)
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ],
                                    minY: 0,
                                    maxY: _maxY,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Pie Chart Komposisi ───────────────────
                  if (_komposisi.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.slate100),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 10.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Komposisi Pengeluaran',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppTheme.slate800)),
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
                                          sections: _komposisi
                                              .asMap()
                                              .entries
                                              .map((e) {
                                            final colors = [
                                              AppTheme.orange500,
                                              AppTheme.slate200
                                            ];
                                            return PieChartSectionData(
                                              value: (e.value['jumlah'] ?? 0)
                                                  .toDouble(),
                                              color:
                                                  colors[e.key % colors.length],
                                              radius: 28,
                                              showTitle: false,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      Text(
                                        '$_persenMasak%',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            color: AppTheme.slate800),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _komposisi.asMap().entries.map((e) {
                                  final colors = [
                                    AppTheme.orange500,
                                    AppTheme.slate200
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _LegendItem(
                                      color: colors[e.key % colors.length],
                                      label: e.value['kategori'],
                                      value: _formatRupiah(
                                          (e.value['jumlah'] ?? 0).toDouble()),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ── Mutasi / Riwayat Transaksi ────────────
                  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slate800,
                        letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 12),

                  if (_mutasi.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Belum ada transaksi bulan ini',
                            style: TextStyle(
                                color: AppTheme.slate400,
                                fontWeight: FontWeight.w500)),
                      ),
                    )
                  else ...[
                    ..._mutasi.map((item) =>
                        _MutasiItem(item: item, formatRupiah: _formatRupiah)),
                    const SizedBox(height: 12),

                    // Load more
                    if (_currentPage < _lastPage)
                      Center(
                        child: _isLoadingMore
                            ? const CircularProgressIndicator()
                            : TextButton(
                                onPressed: () {
                                  _currentPage++;
                                  _loadMutasi();
                                },
                                child: const Text('Lihat Lebih Banyak',
                                    style: TextStyle(
                                        color: AppTheme.orange600,
                                        fontWeight: FontWeight.w700)),
                              ),
                      ),
                  ],

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

// ── Summary Card ──────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;

  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.trend,
      required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 10.2),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slate500,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.slate800,
                  letterSpacing: -0.5)),
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
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isPositive ? AppTheme.green500 : AppTheme.red500),
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

// ── Legend Item ───────────────────────────────────────────────
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendItem(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slate600)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.slate800)),
        ),
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
