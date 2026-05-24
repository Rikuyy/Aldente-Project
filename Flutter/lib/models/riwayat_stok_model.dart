// lib/models/riwayat_stok_model.dart

class RiwayatStokModel {
  final String? id;
  final String idUser;
  final String namaBahan;
  final String tipeTransaksi; // 'in' atau 'out'
  final double jumlah;
  final String satuan;
  final String keterangan;
  final DateTime waktu;

  RiwayatStokModel({
    this.id,
    required this.idUser,
    required this.namaBahan,
    required this.tipeTransaksi,
    required this.jumlah,
    required this.satuan,
    required this.keterangan,
    required this.waktu,
  });

  factory RiwayatStokModel.fromJson(Map<String, dynamic> json) {
    return RiwayatStokModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      idUser: json['Id_User'] ?? '',
      namaBahan: json['Nama_Bahan'] ?? '',
      tipeTransaksi: json['Tipe_Transaksi'] ?? 'in',
      jumlah: (json['Jumlah'] ?? 0).toDouble(),
      satuan: json['Satuan'] ?? '',
      keterangan: json['Keterangan'] ?? '',
      waktu: json['Waktu'] != null
          ? DateTime.tryParse(json['Waktu'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id_User': idUser,
      'Nama_Bahan': namaBahan,
      'Tipe_Transaksi': tipeTransaksi,
      'Jumlah': jumlah,
      'Satuan': satuan,
      'Keterangan': keterangan,
      'Waktu': waktu.toIso8601String(),
    };
  }

  // Helper untuk tampilan
  String get tanggalLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(waktu.year, waktu.month, waktu.day);

    if (itemDate == today) {
      return 'Hari Ini';
    } else if (itemDate == yesterday) {
      return 'Kemarin';
    } else {
      return '${waktu.day}/${waktu.month}/${waktu.year}';
    }
  }
}
