import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

class StockService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── GET /api/inventory ──────────────────────────────────────
  // Return stok digroup by kategori
  Future<Map<String, dynamic>> getStok() async {
    final token = await _getToken();
    if (token == null)
      return {'success': false, 'message': 'Token tidak ditemukan'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/inventory'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali'
        };
      } else {
        return {'success': false, 'message': 'Gagal memuat stok'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ── GET /api/inventory/search?q=... ────────────────────────
  Future<Map<String, dynamic>> searchStok(String query) async {
    final token = await _getToken();
    if (token == null)
      return {'success': false, 'message': 'Token tidak ditemukan'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/inventory/search?q=$query'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Gagal mencari stok'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ── POST /api/inventory ─────────────────────────────────────
  Future<Map<String, dynamic>> tambahStok({
    required String namaBahan,
    required String kategoriBahan,
    required double jumlahBahan,
    required String satuanBahan,
    required String tanggalBeli,
    required String tanggalKadaluarsa,
  }) async {
    final token = await _getToken();
    if (token == null)
      return {'success': false, 'message': 'Token tidak ditemukan'};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/inventory'),
        headers: _headers(token),
        body: jsonEncode({
          'Nama_Bahan': namaBahan,
          'Kategori_Bahan': kategoriBahan,
          'Jumlah_Bahan': jumlahBahan,
          'Satuan_Bahan': satuanBahan,
          'Tanggal_Beli': tanggalBeli,
          'Tanggal Kadaluarsa': tanggalKadaluarsa,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Stok berhasil ditambahkan'};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambahkan stok'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ── PUT /api/inventory/{id} ─────────────────────────────────
  Future<Map<String, dynamic>> updateStok(
      String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null)
      return {'success': false, 'message': 'Token tidak ditemukan'};

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/inventory/$id'),
        headers: _headers(token),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Stok berhasil diupdate'};
      } else {
        return {'success': false, 'message': 'Gagal mengupdate stok'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ── DELETE /api/inventory/{id} ──────────────────────────────
  Future<Map<String, dynamic>> hapusStok(String id) async {
    final token = await _getToken();
    if (token == null)
      return {'success': false, 'message': 'Token tidak ditemukan'};

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/inventory/$id'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Stok berhasil dihapus'};
      } else {
        return {'success': false, 'message': 'Gagal menghapus stok'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ── POST /api/inventory/masak-selesai ───────────────────────
  // bahan: [{'id': '...', 'jumlah': 1}, ...]
  Future<Map<String, dynamic>> masakSelesai(
      List<Map<String, dynamic>> bahan) async {
    final token = await _getToken();
    if (token == null)
      return {'success': false, 'message': 'Token tidak ditemukan'};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/inventory/masak-selesai'),
        headers: _headers(token),
        body: jsonEncode({'bahan': bahan}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Stok berhasil diperbarui'};
      } else {
        return {'success': false, 'message': 'Gagal memperbarui stok'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }
}
