import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/stok_model.dart';

class StockService {
  final String baseUrl = ApiService.baseUrl;

  // Mengambil token JWT yang disimpan saat user login
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Menyusun header standard API dengan Bearer Token
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ============================================================
  // POST /api/inventory (Tambah bahan ke MongoDB)
  // ============================================================
  Future<Map<String, dynamic>> tambahStok(StokModel bahan) async {
    final token = await _getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login kembali.'
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/inventory'),
        headers: _headers(token),
        body: jsonEncode(bahan.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Data berhasil disimpan ke MongoDB!',
          'data': StokModel.fromJson(data['data'])
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambahkan data stok.'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ============================================================
  // GET /api/inventory (Ambil semua data stok terkelompok)
  // ============================================================
  Future<Map<String, dynamic>> getStok() async {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan.'};
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/inventory'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Gagal memuat stok.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }
}
