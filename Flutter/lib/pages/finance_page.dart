import 'dart:convert';
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
  String _period = 'Bulan Ini';
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

  static const _yearOptions = [0, 2025, 2024, 2023];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      const bulanQuery = '2026-05';
      bool anyApiSuccess = false;

      final ringkasanResp =
          await ApiService.get('/keuangan/ringkasan?bulan=$bulanQuery');
      if (ringkasanResp['success'] == true) {
        _ringkasan =
            FinanceRingkasanModel.fromJson(ringkasanResp['data']['data']);
        anyApiSuccess = true;
        print('✅ Ringkasan dari API');
      } else {
        print('⚠️ Ringkasan API gagal');
      }

      final grafikResp =
          await ApiService.get('/keuangan/grafik?bulan=$bulanQuery');
      if (grafikResp['success'] == true) {
        final perTanggal = grafikResp['data']['per_tanggal'] as List;
        _grafikData =
            perTanggal.map((j) => FinanceGrafikModel.fromJson(j)).toList();
        anyApiSuccess = true;
        print('✅ Grafik dari API');
      }

      await _loadMutasi();
      if (_groupedMutasi.isNotEmpty) anyApiSuccess = true;

      if (!anyApiSuccess) {
        print('⚠️ Semua API gagal, fallback ke JSON lokal');
        await _loadFromJson();
      }

      setState(() => _isLoading = false);
    } catch (e, stack) {
      print('❌ Error _loadData: $e\n$stack');
      await _loadFromJson();
      setState(() => _isLoading = false);
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
        url += '?' + query.entries.map((e) => '${e.key}=${e.value}').join('&');
      }
      final resp = await ApiService.get(url);
      if (resp['success'] == true &&
          resp['data'] != null &&
          (resp['data'] as List).isNotEmpty) {
        final List list = resp['data'];
        setState(() {
          _groupedMutasi = list.map((e) => GroupedMutasi.fromJson(e)).toList();
        });
        print('✅ Mutasi dari API: ${_groupedMutasi.length} groups');
      } else {
        setState(() => _groupedMutasi = []);
        print('⚠️ Mutasi API kosong');
      }
    } catch (e) {
      print('❌ Error load mutasi: $e');
      setState(() => _groupedMutasi = []);
    }
  }

  Future<void> _loadFromJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/keuangan.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      List<FinanceMutasiModel> allTransaksi = [];

      for (var item in jsonList) {
        String id = '';
        if (item['_id'] is Map) {
          id = item['_id']['\$oid'] ?? '';
        } else {
          id = item['_id']?.toString() ?? '';
        }

        String rawTanggal = item['Tanggal'] ?? '';
        String normalizedTanggal = _normalizeDate(rawTanggal);
        String waktu = item['Waktu'] ?? '';
        if (waktu.length == 5 && waktu.contains(':')) {
          waktu = '$waktu:00';
        }

        String judul = '';
        String keterangan = '';
        var detail = item['Detail_Beli'];
        if (detail != null && detail is List && detail.isNotEmpty) {
          var first = detail[0];
          judul = first['nama'] ?? 'Transaksi';
          keterangan = '${detail.length} item';
        } else {
          judul = item['Jenis_Pengeluaran'] == 'Masak'
              ? 'Masak sendiri'
              : 'Beli di luar';
          keterangan = '';
        }

        double jumlah = (item['Total_Pengeluaran'] ?? 0).toDouble();
        String jenis = item['Jenis_Pengeluaran'] == 'Masak' ? 'cook' : 'food';

        allTransaksi.add(FinanceMutasiModel(
          id: id,
          judul: judul,
          keterangan: keterangan,
          waktu: waktu,
          tanggal: normalizedTanggal,
          jumlah: jumlah,
          isDebit: true,
          jenisPengeluaran: jenis,
          sesiMakan: '',
          namaResep: '',
          resepId: '',
        ));
      }

      double totalPengeluaran = allTransaksi.fold(0, (s, t) => s + t.jumlah);
      double budget = 3000000;
      double saldo = budget - totalPengeluaran;
      int hariDenganTransaksi =
          allTransaksi.map((t) => t.tanggal).toSet().length;
      double rataPerHari =
          hariDenganTransaksi > 0 ? totalPengeluaran / hariDenganTransaksi : 0;
      int daysInMonth = DateTime.now().day;
      double prediksiAkhir = (totalPengeluaran / daysInMonth) * 30;
      bool prediksiDefisit = prediksiAkhir > budget;
      double totalMasak = allTransaksi
          .where((t) => t.jenisPengeluaran == 'cook')
          .fold(0, (s, t) => s + t.jumlah);
      int persenMasak = totalPengeluaran > 0
          ? ((totalMasak / totalPengeluaran) * 100).round()
          : 0;

      _ringkasan = FinanceRingkasanModel(
        saldo: saldo,
        totalPemasukan: budget,
        totalPengeluaran: totalPengeluaran,
        rataPerHari: rataPerHari,
        prediksiAkhirBulan: prediksiAkhir,
        prediksiDefisit: prediksiDefisit,
        pesanPrediksi: prediksiDefisit ? "Diprediksi melebihi budget" : "Aman",
        persenMasak: persenMasak,
        komposisi: [
          KomposisiKategori(
              kategori: 'Masak Sendiri', jumlah: totalMasak, warna: 'orange'),
          KomposisiKategori(
              kategori: 'Beli di Luar',
              jumlah: totalPengeluaran - totalMasak,
              warna: 'blue'),
        ],
      );

      Map<String, double> dailyMap = {};
      for (var t in allTransaksi) {
        dailyMap[t.tanggal] = (dailyMap[t.tanggal] ?? 0) + t.jumlah;
      }
      List<String> sortedDates = dailyMap.keys.toList()..sort();
      _grafikData = [];
      for (var date in sortedDates) {
        int hari = _extractDayFromDate(date);
        _grafikData.add(FinanceGrafikModel(
          tanggal: date,
          hari: hari,
          jumlah: dailyMap[date]!,
        ));
      }

      Map<String, List<FinanceMutasiModel>> grouped = {};
      for (var t in allTransaksi) {
        String label = _getLabelTanggal(t.tanggal);
        grouped.putIfAbsent(label, () => []).add(t);
      }
      _groupedMutasi = grouped.entries
          .map((e) => GroupedMutasi(
                tanggalLabel: e.key,
                totalKeluar: e.value.fold(0, (s, t) => s + t.jumlah),
                totalMasuk: 0,
                transaksi: e.value,
              ))
          .toList();

      print('✅ Fallback JSON loaded: ${_groupedMutasi.length} groups');
    } catch (e) {
      print('❌ Error load JSON: $e');
      setState(() => _error = 'Gagal load data keuangan: $e');
    }
  }

  String _normalizeDate(String dateStr) {
    try {
      var parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int day = int.parse(parts[2]);
      return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  int _extractDayFromDate(String dateStr) {
    try {
      return DateTime.parse(dateStr).day;
    } catch (e) {
      return 0;
    }
  }

  String _getLabelTanggal(String tanggalStr) {
    DateTime tgl = DateTime.parse(tanggalStr);
    DateTime now = DateTime.now();
    if (tgl.year == now.year && tgl.month == now.month && tgl.day == now.day)
      return 'Hari ini';
    if (tgl.year == now.year &&
        tgl.month == now.month &&
        tgl.day == now.day - 1) return 'Kemarin';
    if (tgl.year == now.year) return '${tgl.day} ${_monthOptions[tgl.month]}';
    return '${tgl.day} ${_monthOptions[tgl.month]} ${tgl.year}';
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

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.cardBackground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PeriodPicker(
          current: _period, onSelect: (p) => setState(() => _period = p)),
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
        title: const Text('Tambah Pemasukan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Isi nominal' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: keteranganController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
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
                final jumlah = double.tryParse(jumlahController.text) ?? 0;
                if (jumlah <= 0) return;
                final keterangan = keteranganController.text.trim();
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  final response =
                      await ApiService.post('/keuangan/pemasukan', {
                    'jumlah': jumlah,
                    'keterangan': keterangan,
                  });
                  if (response['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pemasukan berhasil ditambahkan')),
                    );
                    await _loadData();
                  } else {
                    throw Exception(response['message'] ?? 'Gagal');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Gagal: $e'),
                        backgroundColor: Colors.red),
                  );
                  setState(() => _isLoading = false);
                }
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.orange600),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  String _formatRp(double v) => v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  List<FlSpot> get _lineSpots {
    return _grafikData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.jumlah);
    }).toList();
  }

  Map<String, List<FinanceMutasiModel>> get _groupedMutasiMap {
    final map = <String, List<FinanceMutasiModel>>{};
    for (final group in _groupedMutasi) {
      map[group.tanggalLabel] = group.transaksi;
    }
    return map;
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
              Text('Error: $_error'),
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
              // Tombol Topup
              GestureDetector(
                onTap: _showTopUpDialog,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
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
              // Tombol periode
              GestureDetector(
                onTap: _showPeriodPicker,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(children: [
                    Text(_period,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textSecondary)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 16, color: context.colors.textHint),
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
              // Ringkasan saldo
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
                        color: Colors.black.withValues(alpha: 0.2),
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
                      'Rp ${_formatRp(saldo)}',
                      style: TextStyle(
                        color: saldo >= 0 ? Colors.white : AppTheme.red500,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                        color: Colors.white.withValues(alpha: 0.1), height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _BalanceItem(
                                label: 'Pemasukan',
                                amount: totalPemasukan,
                                isPositive: true)),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withValues(alpha: 0.1)),
                        Expanded(
                            child: _BalanceItem(
                                label: 'Pengeluaran',
                                amount: totalPengeluaran,
                                isPositive: false)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Summary chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                        child: _SummaryChip(
                            label: 'Rata-rata/Hari',
                            value: 'Rp ${_formatRp(_ringkasan!.rataPerHari)}',
                            icon: Icons.bar_chart_rounded,
                            color: AppTheme.blue500,
                            bg: AppTheme.blue50)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _SummaryChip(
                            label: 'Prediksi Akhir',
                            value:
                                'Rp ${_formatRp(_ringkasan!.prediksiAkhirBulan)}',
                            icon: Icons.warning_rounded,
                            color: AppTheme.red500,
                            bg: AppTheme.red50,
                            isWarning: true)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Prediksi warning
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.orange50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.orange200),
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
                          Text(
                            _ringkasan!.prediksiDefisit
                                ? 'Prediksi Akhir Bulan: Defisit'
                                : 'Prediksi Akhir Bulan: Aman',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF431407),
                                fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _ringkasan!.pesanPrediksi,
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
              // Grafik tren
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
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
                                        AppTheme.orange500
                                            .withValues(alpha: 0.18),
                                        AppTheme.orange500.withValues(alpha: 0)
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
              // Komposisi pie chart
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
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
                              Text('${_ringkasan!.persenMasak}%',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: context.colors.textPrimary)),
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
                                  value: 'Rp ${_formatRp(item.jumlah)}'),
                            );
                          }).toList(),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Header mutasi dengan filter
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showMonthPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (_mutationMonth != 'Semua' ||
                                      _mutationYear != 0)
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.orange50,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: AppTheme.orange200),
                          ),
                          child: const Row(children: [
                            Icon(Icons.filter_list_rounded,
                                size: 14, color: AppTheme.orange600),
                            SizedBox(width: 4),
                            Text('Filter',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.orange600)),
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Daftar mutasi
              if (_groupedMutasiMap.isEmpty)
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
                    ],
                  ),
                )
              else
                ..._groupedMutasiMap.entries.map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Row(children: [
                            Text(entry.key,
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
                              '- Rp ${_formatRp(entry.value.where((t) => t.isDebit).fold(0.0, (s, t) => s + t.jumlah))}',
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
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Column(
                            children: entry.value.asMap().entries.map((e) {
                              final t = e.value;
                              final isLast = e.key == entry.value.length - 1;
                              return _MutationRow(
                                transaction: t,
                                isLast: isLast,
                              );
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

// ============ WIDGET BANTUAN ============

class _BalanceItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isPositive;
  const _BalanceItem(
      {required this.label, required this.amount, required this.isPositive});
  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
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
      Text('Rp ${_fmt(amount)}',
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
  const _SummaryChip(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.bg,
      this.isWarning = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3))),
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
  const _LegendItem(
      {required this.color, required this.label, required this.value});
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
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary)),
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
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 12),
      Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 16),
      Text('Pilih Periode',
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: context.colors.textPrimary)),
      const SizedBox(height: 12),
      ...options.map((o) => ListTile(
            leading: Icon(
                o == current
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color:
                    o == current ? AppTheme.orange600 : context.colors.textHint,
                size: 20),
            title: Text(o,
                style: TextStyle(
                    fontWeight:
                        o == current ? FontWeight.w700 : FontWeight.w500,
                    color: o == current
                        ? AppTheme.orange600
                        : context.colors.textSecondary)),
            onTap: () {
              onSelect(o);
              Navigator.pop(context);
            },
          )),
      const SizedBox(height: 16),
    ]);
  }
}

class _MutationFilterPicker extends StatefulWidget {
  final String currentMonth;
  final int currentYear;
  final List<String> monthOptions;
  final List<int> yearOptions;
  final void Function(String month, int year) onSelect;
  const _MutationFilterPicker(
      {required this.currentMonth,
      required this.currentYear,
      required this.monthOptions,
      required this.yearOptions,
      required this.onSelect});
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
  const _MutationRow({required this.transaction, required this.isLast});

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    IconData categoryIcon;
    Color categoryColor;
    Color categoryBg;
    switch (transaction.jenisPengeluaran) {
      case 'food':
        categoryIcon = Icons.restaurant_rounded;
        categoryColor = AppTheme.orange500;
        categoryBg = AppTheme.orange50;
        break;
      case 'cook':
        categoryIcon = Icons.outdoor_grill_rounded;
        categoryColor = AppTheme.green600;
        categoryBg = AppTheme.green50;
        break;
      case 'topup':
        categoryIcon = Icons.add_circle_rounded;
        categoryColor = Colors.purple;
        categoryBg = Colors.purple.shade50;
        break;
      default:
        categoryIcon = Icons.receipt_rounded;
        categoryColor = AppTheme.slate500;
        categoryBg = AppTheme.slate50;
    }

    String judulUtama = transaction.judul;
    if (transaction.namaResep.isNotEmpty) {
      judulUtama = transaction.namaResep;
    }
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
                    'Rp ${_fmt(transaction.jumlah)}',
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
