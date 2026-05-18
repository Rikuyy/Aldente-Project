import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

class DashboardService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── GET /api/dashboard ──────────────────────────────────────
  Future<Map<String, dynamic>> getDashboard() async {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan'};
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali'
        };
      } else {
        return {'success': false, 'message': 'Gagal memuat dashboard'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ── POST /api/dashboard/budget ──────────────────────────────
  Future<Map<String, dynamic>> setBudget(double totalBudget,
      {String? bulan}) async {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan'};
    }

    try {
      final Map<String, dynamic> body = {'total_budget': totalBudget};
      if (bulan != null) body['bulan'] = bulan;

      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/budget'),
        headers: _headers(token),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Budget berhasil disimpan'};
      } else {
        return {'success': false, 'message': 'Gagal menyimpan budget'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }
}
