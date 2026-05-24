// lib/models/finance_model.dart

class FinanceRingkasanModel {
  final double saldo;
  final double totalPemasukan;
  final double totalPengeluaran;
  final double rataPerHari;
  final double prediksiAkhirBulan;
  final bool prediksiDefisit;
  final String pesanPrediksi;
  final int persenMasak;
  final List<KomposisiKategori> komposisi;

  FinanceRingkasanModel({
    required this.saldo,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.rataPerHari,
    required this.prediksiAkhirBulan,
    required this.prediksiDefisit,
    required this.pesanPrediksi,
    required this.persenMasak,
    required this.komposisi,
  });

  factory FinanceRingkasanModel.fromJson(Map<String, dynamic> json) {
    var list = json['komposisi'] as List? ?? [];
    List<KomposisiKategori> kompoList =
        list.map((i) => KomposisiKategori.fromJson(i)).toList();

    return FinanceRingkasanModel(
      saldo: (json['saldo'] ?? 0).toDouble(),
      totalPemasukan: (json['total_pemasukan'] ?? 0).toDouble(),
      totalPengeluaran: (json['total_pengeluaran'] ?? 0).toDouble(),
      rataPerHari: (json['rata_per_hari'] ?? 0).toDouble(),
      prediksiAkhirBulan: (json['prediksi_akhir_bulan'] ?? 0).toDouble(),
      prediksiDefisit: json['prediksi_defisit'] ?? false,
      pesanPrediksi: json['pesan_prediksi'] ?? '',
      persenMasak: json['persen_masak'] ?? 0,
      komposisi: kompoList,
    );
  }
}

class KomposisiKategori {
  final String kategori;
  final double jumlah;
  final String warna;

  KomposisiKategori(
      {required this.kategori, required this.jumlah, required this.warna});

  factory KomposisiKategori.fromJson(Map<String, dynamic> json) {
    return KomposisiKategori(
      kategori: json['kategori'] ?? '',
      jumlah: (json['jumlah'] ?? 0).toDouble(),
      warna: json['warna'] ?? 'orange',
    );
  }
}

class FinanceGrafikModel {
  final String tanggal;
  final int hari;
  final double jumlah;

  FinanceGrafikModel(
      {required this.tanggal, required this.hari, required this.jumlah});

  factory FinanceGrafikModel.fromJson(Map<String, dynamic> json) {
    return FinanceGrafikModel(
      tanggal: json['tanggal'] ?? '',
      hari: json['hari'] ?? 0,
      jumlah: (json['jumlah'] ?? 0).toDouble(),
    );
  }
}

class FinanceMutasiModel {
  final String id;
  final String judul;
  final String keterangan;
  final String waktu;
  final String tanggal;
  final double jumlah;
  final bool isDebit;
  final String jenisPengeluaran;

  FinanceMutasiModel({
    required this.id,
    required this.judul,
    required this.keterangan,
    required this.waktu,
    required this.tanggal,
    required this.jumlah,
    required this.isDebit,
    required this.jenisPengeluaran,
  });

  factory FinanceMutasiModel.fromJson(Map<String, dynamic> json) {
    return FinanceMutasiModel(
      id: json['_id'] ?? '',
      judul: json['judul'] ?? 'Pengeluaran',
      keterangan: json['keterangan'] ?? '',
      waktu: json['waktu'] ?? '00:00',
      tanggal: json['tanggal'] ?? '',
      jumlah: (json['jumlah'] ?? 0).toDouble(),
      isDebit: json['is_debit'] ?? true,
      jenisPengeluaran: json['jenis_pengeluaran'] ?? '',
    );
  }
}

class GroupedMutasi {
  final String tanggalLabel;
  final double totalKeluar;
  final List<FinanceMutasiModel> transaksi;

  GroupedMutasi(
      {required this.tanggalLabel,
      required this.totalKeluar,
      required this.transaksi});

  factory GroupedMutasi.fromJson(Map<String, dynamic> json) {
    var list = json['transaksi'] as List? ?? [];
    List<FinanceMutasiModel> txList =
        list.map((i) => FinanceMutasiModel.fromJson(i)).toList();
    return GroupedMutasi(
      tanggalLabel: json['tanggal_label'] ?? '', // ← ganti dari json['tanggal']
      totalKeluar: (json['total_keluar'] ?? 0).toDouble(),
      transaksi: txList,
    );
  }
}
