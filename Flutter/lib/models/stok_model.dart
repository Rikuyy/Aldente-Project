class StokModel {
  final String? id;
  final String idUser;
  final String namaBahan;
  final String kategoriBahan;
  double jumlahBahan;
  final String satuanBahan;
  final String tipeBahan; // 'kemasan' atau 'segar'
  final DateTime? tanggalBeli;
  final DateTime? tanggalKadaluarsa;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  StokModel({
    this.id,
    required this.idUser,
    required this.namaBahan,
    required this.kategoriBahan,
    required this.jumlahBahan,
    required this.satuanBahan,
    required this.tipeBahan,
    this.tanggalBeli,
    this.tanggalKadaluarsa,
    this.updatedAt,
    this.createdAt,
  });

  factory StokModel.fromJson(Map<String, dynamic> json) {
    return StokModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      idUser: json['Id_User'] ?? '',
      namaBahan: json['Nama_Bahan'] ?? '',
      kategoriBahan: json['Kategori_Bahan'] ?? '',
      jumlahBahan: (json['Jumlah_Bahan'] ?? 0).toDouble(),
      satuanBahan: json['Satuan_Bahan'] ?? '',
      tipeBahan: json['Tipe_Bahan'] ?? 'segar',
      tanggalBeli: json['Tanggal_Beli'] != null
          ? DateTime.tryParse(json['Tanggal_Beli'].toString())
          : null,
      tanggalKadaluarsa: json['Tanggal_Kadaluarsa'] != null
          ? DateTime.tryParse(json['Tanggal_Kadaluarsa'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'Id_User': idUser,
      'Nama_Bahan': namaBahan,
      'Kategori_Bahan': kategoriBahan,
      'Jumlah_Bahan': jumlahBahan,
      'Satuan_Bahan': satuanBahan,
      'Tipe_Bahan': tipeBahan,
      if (tanggalBeli != null) 'Tanggal_Beli': tanggalBeli!.toIso8601String(),
      if (tanggalKadaluarsa != null)
        'Tanggal_Kadaluarsa': tanggalKadaluarsa!.toIso8601String(),
    };
  }

  StokModel copyWith({
    String? id,
    String? idUser,
    String? namaBahan,
    String? kategoriBahan,
    double? jumlahBahan,
    String? satuanBahan,
    String? tipeBahan,
    DateTime? tanggalBeli,
    DateTime? tanggalKadaluarsa,
  }) {
    return StokModel(
      id: id ?? this.id,
      idUser: idUser ?? this.idUser,
      namaBahan: namaBahan ?? this.namaBahan,
      kategoriBahan: kategoriBahan ?? this.kategoriBahan,
      jumlahBahan: jumlahBahan ?? this.jumlahBahan,
      satuanBahan: satuanBahan ?? this.satuanBahan,
      tipeBahan: tipeBahan ?? this.tipeBahan,
      tanggalBeli: tanggalBeli ?? this.tanggalBeli,
      tanggalKadaluarsa: tanggalKadaluarsa ?? this.tanggalKadaluarsa,
    );
  }
}
