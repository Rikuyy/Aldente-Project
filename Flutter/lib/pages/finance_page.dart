import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/finance_model.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  int _touchedIndex = -1;
  String _mutationMonth = 'Semua';
  int _mutationYear = 0;

  FinanceRingkasanModel? _ringkasan;
  List<FinanceGrafikModel> _grafikData = [];
  List<GroupedMutasi> _groupedMutasi = [];
  bool _isLoading = true;
  String _error = '';

  static const _monthOptions = [
    'Semua',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  static const _yearOptions = [0, 2025, 2026];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatRp(double amount) {
    String str = amount.toInt().toString();
    String result = '';
    int length = str.length;
    for (int i = 0; i < length; i++) {
      result += str[i];
      if ((length - i - 1) % 3 == 0 && i != length - 1) result += '.';
    }
    return 'Rp $result';
  }

  String _getCurrentBulan() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final bulanQuery = _getCurrentBulan();
      await Future.wait([
        _loadRingkasan(bulanQuery).timeout(const Duration(seconds: 10)),
        _loadGrafik(bulanQuery).timeout(const Duration(seconds: 10)),
        _loadMutasi().timeout(const Duration(seconds: 10)),
      ]);
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('❌ Error _loadData: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data. Periksa koneksi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRingkasan(String bulan) async {
    final resp = await ApiService.get('/keuangan/ringkasan?bulan=$bulan');
    if (!mounted) return;
    if (resp['success'] == true) {
      setState(() {
        _ringkasan = FinanceRingkasanModel.fromJson(resp['data']['data']);
      });
    } else {
      throw Exception('Ringkasan gagal: ${resp['message']}');
    }
  }

  Future<void> _loadGrafik(String bulan) async {
    final resp = await ApiService.get('/keuangan/grafik?bulan=$bulan');
    if (!mounted) return;
    if (resp['success'] == true) {
      final perTanggal = resp['data']['per_tanggal'] as List;
      setState(() {
        _grafikData =
            perTanggal.map((j) => FinanceGrafikModel.fromJson(j)).toList();
      });
    } else {
      throw Exception('Grafik gagal: ${resp['message']}');
    }
  }

  Future<void> _loadMutasi() async {
    try {
      Map<String, String> query = {};
      if (_mutationMonth != 'Semua') {
        final bulanIndex = _monthOptions.indexOf(_mutationMonth);
        if (bulanIndex >= 1 && bulanIndex <= 12) {
          query['bulan'] = bulanIndex.toString().padLeft(2, '0');
        }
      }
      if (_mutationYear != 0) {
        query['tahun'] = _mutationYear.toString();
      }
      String url = '/keuangan/mutasi';
      if (query.isNotEmpty) {
        url += '?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }
      final resp = await ApiService.get(url);
      if (!mounted) return;
      debugPrint(
          '✅ Mutasi resp: success=${resp['success']}, data type=${resp['data']?.runtimeType}');
      if (resp['success'] == true && resp['data'] != null) {
        final dynamic rawData = resp['data'];
        final List list = rawData is List ? rawData : [];
        setState(() {
          _groupedMutasi = list.map((e) => GroupedMutasi.fromJson(e)).toList();
        });
        debugPrint('✅ Mutasi loaded: ${_groupedMutasi.length} group');
      } else {
        setState(() => _groupedMutasi = []);
        debugPrint('⚠️ Mutasi kosong atau gagal: ${resp['message']}');
      }
    } catch (e) {
      debugPrint('❌ Error load mutasi: $e');
      if (!mounted) return;
      setState(() => _groupedMutasi = []);
    }
  }

  void _applyFilter(String month, int year) {
    setState(() {
      _mutationMonth = month;
      _mutationYear = year;
    });
    _loadMutasi();
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.cardBackground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _MutationFilterPicker(
        currentMonth: _mutationMonth,
        currentYear: _mutationYear,
        monthOptions: _monthOptions,
        yearOptions: _yearOptions,
        onSelect: _applyFilter,
      ),
    );
  }

  Future<void> _showTopUpDialog() async {
    final jumlahController = TextEditingController();
    final keteranganController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Pemasukan (Topup)'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CurrencyFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Isi nominal';
                  if (v.replaceAll('.', '').isEmpty) return 'Isi nominal';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: keteranganController,
                decoration: const InputDecoration(
                  labelText: 'Detail Tambahan (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: TextStyle(color: context.colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final jumlahText = jumlahController.text.replaceAll('.', '');
                final jumlah = double.tryParse(jumlahText) ?? 0;
                if (jumlah <= 0) return;
                final detailTambahan = keteranganController.text.trim();
                try {
                  // Disesuaikan dengan struktur log keuangan di database backend Anda
                  final response =
                      await ApiService.post('/keuangan/pemasukan', {
                    'kategori': 'Pemasukan',
                    'keterangan': 'Top Up',
                    'total_nominal': jumlah,
                    'detail': detailTambahan.isNotEmpty
                        ? {'info': detailTambahan}
                        : null,
                  });
                  if (response['success'] == true) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Pemasukan berhasil ditambahkan')),
                      );
                      Navigator.pop(context);
                    }
                    await _loadData();
                  } else {
                    throw Exception(response['message'] ?? 'Gagal');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Gagal: $e'),
                          backgroundColor: Colors.red),
                    );
                    Navigator.pop(context);
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange600,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _showManualExpenseDialog() async {
    final jumlahController = TextEditingController();
    final keteranganController = TextEditingController();
    String? selectedJenis; // Menyimpan tipe pilihan keterangan dari database
    final formKey = GlobalKey<FormState>();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Catat Pengeluaran Manual'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Jenis Keterangan'),
                items: const [
                  DropdownMenuItem(
                      value: 'Pengurangan Budget',
                      child: Text('Penarikan Budget (kurangi saldo)')),
                  DropdownMenuItem(
                      value: 'Lainnya',
                      child: Text('Pengeluaran Lain (jajan, dll)')),
                ],
                onChanged: (v) => selectedJenis = v,
                validator: (v) => v == null ? 'Pilih jenis keterangan' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CurrencyFormatter(),
                ],
                decoration: const InputDecoration(
                    labelText: 'Nominal (Rp)', prefixText: 'Rp '),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Isi nominal';
                  if (v.replaceAll('.', '').isEmpty) return 'Isi nominal';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: keteranganController,
                decoration:
                    const InputDecoration(labelText: 'Detail Pengeluaran'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Isi detail pengeluaran' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final jumlahText = jumlahController.text.replaceAll('.', '');
                final jumlah = double.tryParse(jumlahText) ?? 0;
                if (jumlah <= 0) return;
                final detailText = keteranganController.text.trim();
                try {
                  // Mengirim parameter yang sesuai dengan enum log keuangan database Anda
                  final response =
                      await ApiService.post('/keuangan/pengeluaran', {
                    'kategori': 'Pengeluaran',
                    'keterangan':
                        selectedJenis, // 'Pengurangan Budget' atau 'Lainnya'
                    'total_nominal': jumlah,
                    'detail': {'catatan': detailText},
                  });
                  if (response['success'] == true) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pengeluaran dicatat')),
                      );
                      Navigator.pop(context);
                    }
                    await _loadData();
                  } else {
                    throw Exception(response['message'] ?? 'Gagal');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Gagal: $e'),
                          backgroundColor: Colors.red),
                    );
                    Navigator.pop(context);
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange600,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  List<FlSpot> get _lineSpots {
    if (_grafikData.isEmpty) return [];
    return _grafikData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.jumlah);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: context.colors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_ringkasan == null) return const SizedBox.shrink();

    final totalPemasukan = _ringkasan!.totalPemasukan;
    final totalPengeluaran = _ringkasan!.totalPengeluaran;
    final saldo = _ringkasan!.saldo;

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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: context.colors.textPrimary,
                  letterSpacing: -0.4),
            ),
            actions: [
              GestureDetector(
                onTap: _showManualExpenseDialog,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.red50,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppTheme.red200),
                  ),
                  child: Row(children: [
                    Icon(Icons.remove_circle_rounded,
                        size: 16, color: AppTheme.red600),
                    const SizedBox(width: 4),
                    Text('Catat',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.red600)),
                  ]),
                ),
              ),
              GestureDetector(
                onTap: _showTopUpDialog,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.green50,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppTheme.green200),
                  ),
                  child: Row(children: [
                    Icon(Icons.add_circle_rounded,
                        size: 16, color: AppTheme.green600),
                    const SizedBox(width: 4),
                    Text('Topup',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.green600)),
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
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SALDO BUDGET',
                        style: TextStyle(
                            color: AppTheme.slate400,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Text(
                      _formatRp(saldo),
                      style: TextStyle(
                        color: saldo >= 0 ? Colors.white : AppTheme.red500,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _BalanceItem(
                                label: 'Pemasukan',
                                amount: totalPemasukan,
                                format: _formatRp,
                                isPositive: true)),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withOpacity(0.1)),
                        Expanded(
                            child: _BalanceItem(
                                label: 'Pengeluaran',
                                amount: totalPengeluaran,
                                format: _formatRp,
                                isPositive: false)),
                      ],
                    ),
                  ],
                ),
              ),
              if (_ringkasan!.isOverbudgetHariIni)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.red50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.red200),
                  ),
                  child: Row(children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppTheme.red600, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '⚠️ Hari ini overbudget sebesar ${_formatRp(_ringkasan!.overbudgetAmount)}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.red700),
                      ),
                    ),
                  ]),
                ),
              if (_ringkasan!.isSisaTipis)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.orange50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.orange200),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppTheme.orange600, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '💡 Sisa budget per hari tinggal ${_formatRp(_ringkasan!.sisaBudgetPerHari)}. Aturlah pengeluaran Anda.',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.orange700),
                      ),
                    ),
                  ]),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SummaryChip(
                    label: 'Budget per Hari',
                    value: _formatRp(_ringkasan!.rataPerHari),
                    icon: Icons.bar_chart_rounded,
                    color: AppTheme.blue500,
                    bg: AppTheme.blue50),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tren Pengeluaran Harian',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: context.colors.textPrimary)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 160,
                      child: _grafikData.isEmpty
                          ? const Center(child: Text('Tidak ada data grafik'))
                          : LineChart(LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 20000,
                                getDrawingHorizontalLine: (_) => FlLine(
                                    color: context.colors.border,
                                    strokeWidth: 1),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 38,
                                  interval: 20000,
                                  getTitlesWidget: (v, m) => Text(
                                    '${(v / 1000).toInt()}k',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: context.colors.textHint,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, m) => Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      v.toInt() < _grafikData.length
                                          ? '${_grafikData[v.toInt()].hari}'
                                          : '',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: context.colors.textHint,
                                          fontWeight: FontWeight.w600),
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
                                    getDotPainter: (_, __, ___, ____) =>
                                        FlDotCirclePainter(
                                      radius: 4,
                                      color: AppTheme.orange600,
                                      strokeWidth: 2,
                                      strokeColor:
                                          context.colors.cardBackground,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.orange500.withOpacity(0.18),
                                        AppTheme.orange500.withOpacity(0)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                              minY: 0,
                              maxY: _grafikData
                                      .map((e) => e.jumlah)
                                      .reduce((a, b) => a > b ? a : b) +
                                  10000,
                            )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Komposisi Pengeluaran',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: context.colors.textPrimary)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 32,
                                pieTouchData:
                                    PieTouchData(touchCallback: (e, resp) {
                                  setState(() => _touchedIndex = resp
                                          ?.touchedSection
                                          ?.touchedSectionIndex ??
                                      -1);
                                }),
                                sections: _ringkasan!.komposisi
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final idx = entry.key;
                                  final item = entry.value;
                                  return PieChartSectionData(
                                    value: item.jumlah,
                                    color: _getColorFromString(item.warna),
                                    radius: _touchedIndex == idx ? 32 : 28,
                                    showTitle: false,
                                  );
                                }).toList(),
                              )),
                              Builder(builder: (_) {
                                final idx = _touchedIndex;
                                final komposisi = _ringkasan!.komposisi;
                                final persen =
                                    (idx >= 0 && idx < komposisi.length)
                                        ? komposisi[idx].persen
                                        : _ringkasan!.persenMasak;
                                return Text('$persen%',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: context.colors.textPrimary));
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _ringkasan!.komposisi.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _LegendItem(
                                    color: _getColorFromString(item.warna),
                                    label: item.kategori,
                                    value: _formatRp(item.jumlah),
                                    persen: item.persen),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mutasi',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: context.colors.textPrimary,
                            letterSpacing: -0.3)),
                    GestureDetector(
                      onTap: _showMonthPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              (_mutationMonth != 'Semua' || _mutationYear != 0)
                                  ? AppTheme.orange50
                                  : context.colors.border,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: (_mutationMonth != 'Semua' ||
                                    _mutationYear != 0)
                                ? AppTheme.orange200
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(children: [
                          Icon(Icons.calendar_month_rounded,
                              size: 14,
                              color: (_mutationMonth != 'Semua' ||
                                      _mutationYear != 0)
                                  ? AppTheme.orange600
                                  : context.colors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            [
                              if (_mutationYear != 0) '$_mutationYear',
                              if (_mutationMonth != 'Semua') _mutationMonth,
                              if (_mutationMonth == 'Semua' &&
                                  _mutationYear == 0)
                                'Semua',
                            ].join(' · '),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: (_mutationMonth != 'Semua' ||
                                      _mutationYear != 0)
                                  ? AppTheme.orange600
                                  : context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: (_mutationMonth != 'Semua' ||
                                      _mutationYear != 0)
                                  ? AppTheme.orange600
                                  : context.colors.textHint),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_groupedMutasi.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: context.colors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(children: [
                    Icon(Icons.receipt_long_rounded,
                        size: 40, color: context.colors.textHint),
                    const SizedBox(height: 12),
                    Text('Tidak ada mutasi ditemukan',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: context.colors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('Coba ubah filter bulan atau tahun',
                        style: TextStyle(
                            fontSize: 12, color: context.colors.textHint)),
                  ]),
                )
              else
                ..._groupedMutasi.map((group) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Row(children: [
                            Text(group.tanggalLabel,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: context.colors.textSecondary,
                                    letterSpacing: 0.3)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Divider(
                                    color: context.colors.border, height: 1)),
                            const SizedBox(width: 8),
                            Text(
                              '- ${_formatRp(group.totalKeluar)}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.red500),
                            ),
                          ]),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: context.colors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: context.colors.border),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Column(
                            children: group.transaksi.asMap().entries.map((e) {
                              final t = e.value;
                              final isLast =
                                  e.key == group.transaksi.length - 1;
                              return _MutationRow(
                                  transaction: t,
                                  isLast: isLast,
                                  format: _formatRp);
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )),
              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String color) {
    switch (color) {
      case 'orange':
        return AppTheme.orange500;
      case 'blue':
        return AppTheme.blue500;
      case 'green':
        return AppTheme.green500;
      default:
        return AppTheme.orange500;
    }
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final double amount;
  final String Function(double) format;
  final bool isPositive;
  const _BalanceItem(
      {required this.label,
      required this.amount,
      required this.format,
      required this.isPositive});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
            isPositive
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            size: 13,
            color: isPositive ? AppTheme.green500 : AppTheme.red500),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppTheme.slate400,
                fontSize: 10,
                fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 4),
      Text(format(amount),
          style: TextStyle(
              color: isPositive ? AppTheme.green500 : AppTheme.red500,
              fontWeight: FontWeight.w800,
              fontSize: 13)),
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
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
    this.isWarning = false,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isWarning
                      ? AppTheme.red600
                      : context.colors.textPrimary)),
        ])),
      ]),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final int persen;
  const _LegendItem(
      {required this.color,
      required this.label,
      required this.value,
      required this.persen});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text('$persen%',
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w800)),
        ]),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary)),
      ])),
    ]);
  }
}

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
          Center(
              child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: context.colors.border,
                          borderRadius: BorderRadius.circular(2))))),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Filter Mutasi',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: context.colors.textPrimary))),
          const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Tahun',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textSecondary,
                      letterSpacing: 0.5))),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.orange600
                                  : context.colors.border,
                              borderRadius: BorderRadius.circular(50)),
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : context.colors.textSecondary))),
                    );
                  }).toList())),
          const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Bulan',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textSecondary,
                      letterSpacing: 0.5))),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.orange600
                                  : context.colors.border,
                              borderRadius: BorderRadius.circular(50)),
                          child: Text(m,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : context.colors.textSecondary))),
                    );
                  }).toList())),
          const SizedBox(height: 24),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    widget.onSelect('Semua', 0);
                    Navigator.pop(context);
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                      decoration: BoxDecoration(
                          color: context.colors.border,
                          borderRadius: BorderRadius.circular(14)),
                      child: Text('Reset',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textSecondary))),
                ),
                const SizedBox(width: 10),
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
                            borderRadius: BorderRadius.circular(14)),
                        alignment: Alignment.center,
                        child: const Text('Terapkan',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white))),
                  ),
                ),
              ])),
          const SizedBox(height: 32),
        ]);
  }
}

class _MutationRow extends StatelessWidget {
  final FinanceMutasiModel transaction;
  final bool isLast;
  final String Function(double) format;
  const _MutationRow(
      {required this.transaction, required this.isLast, required this.format});
  @override
  Widget build(BuildContext context) {
    IconData categoryIcon;
    Color categoryColor;
    Color categoryBg;

    // Logika Icon menyesuaikan dengan isi field 'Kategori' database Anda
    switch (transaction.jenisPengeluaran) {
      case 'Pengeluaran':
        categoryIcon = Icons.remove_circle_outline_rounded;
        categoryColor = AppTheme.red500;
        categoryBg = AppTheme.red50;
        break;
      case 'Pemasukan':
        categoryIcon = Icons.add_circle_rounded;
        categoryColor = AppTheme.green600;
        categoryBg = AppTheme.green50;
        break;
      default:
        categoryIcon = Icons.receipt_rounded;
        categoryColor = AppTheme.slate500;
        categoryBg = AppTheme.slate50;
    }

    String prefix = '';
    final ket = transaction
        .keterangan; // Berisi Masak, Beli, Top Up, Pengurangan Budget, Lainnya
    if (ket.isNotEmpty) {
      prefix = '[$ket] ';
    }

    String judulUtama = prefix +
        (transaction.namaResep.isNotEmpty
            ? transaction.namaResep
            : transaction.judul);

    String subJudul = transaction.keterangan;
    if (transaction.sesiMakan.isNotEmpty) {
      subJudul = '${transaction.sesiMakan} • $subJudul';
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: categoryBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(categoryIcon, color: categoryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(judulUtama,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: context.colors.textPrimary)),
              const SizedBox(height: 2),
              Text(subJudul,
                  style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textHint,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
                (transaction.isDebit ? '- ' : '+ ') +
                    format(transaction.jumlah),
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: transaction.isDebit
                        ? context.colors.textPrimary
                        : AppTheme.green600,
                    letterSpacing: -0.3)),
            const SizedBox(height: 2),
            Text(transaction.waktu,
                style: TextStyle(
                    fontSize: 10,
                    color: context.colors.textHint,
                    fontWeight: FontWeight.w500)),
          ]),
        ]),
      ),
      if (!isLast) Divider(height: 1, color: context.colors.border, indent: 68),
    ]);
  }
}

// Formatter khusus untuk format angka ribuan (titik otomatis)
class _CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Buang titik yang ada saat user mengetik untuk mendapatkan nilai asli
    String cleanedText = newValue.text.replaceAll('.', '');
    double? value = double.tryParse(cleanedText);

    if (value == null) {
      return oldValue;
    }

    String formatted = '';
    String str = value.toInt().toString();
    int length = str.length;

    // Pasang titik per 3 digit
    for (int i = 0; i < length; i++) {
      formatted += str[i];
      if ((length - i - 1) % 3 == 0 && i != length - 1) {
        formatted += '.';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
