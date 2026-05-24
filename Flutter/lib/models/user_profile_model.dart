// lib/models/user_profile_model.dart

class UserProfileModel {
  final String id;
  final String username;
  final String nama;
  final String email;
  final List<String> kategoriFavorit;
  final List<String> alergi;
  final double? budgetBulanan;
  final int? jumlahMakan;

  UserProfileModel({
    required this.id,
    required this.username,
    required this.nama,
    required this.email,
    required this.kategoriFavorit,
    required this.alergi,
    this.budgetBulanan,
    this.jumlahMakan,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      nama: json['nama'] ??
          json['username'] ??
          '', // Fallback ke username jika nama kosong
      email: json['email'] ?? '',
      kategoriFavorit: List<String>.from(json['kategori_favorit'] ?? []),
      alergi: List<String>.from(json['alergi'] ?? []),
      budgetBulanan: json['budget_bulanan'] != null
          ? (json['budget_bulanan'] as num).toDouble()
          : null,
      jumlahMakan: json['jumlah_makan'] != null
          ? (json['jumlah_makan'] as num).toInt()
          : 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Kategori_Favorit': kategoriFavorit,
      'Alergi': alergi, // <--- SUDAH DIPERBAIKI (sebelumnya 'allergies')
      'Budget_Bulanan': budgetBulanan,
      'Jumlah_Makan': jumlahMakan,
    };
  }
}
