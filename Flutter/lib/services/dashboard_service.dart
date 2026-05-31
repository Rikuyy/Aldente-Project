import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class DashboardService {
  final String baseUrl = ApiService.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> getDashboard({bool forceRefresh = false}) async {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan'};
    }

    try {
      String targetUrl = '$baseUrl/dashboard';
      if (forceRefresh) {
        targetUrl += '?force_refresh=1';
      }

      final response =
          await http.get(Uri.parse(targetUrl), headers: _headers(token));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali'
        };
      }
      return {'success': false, 'message': 'Gagal memuat dashboard'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

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
      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false};
    }
  }

  Future<Map<String, dynamic>> getInventory() async {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan'};
    }
    try {
      final response = await http.get(Uri.parse('$baseUrl/inventory'),
          headers: _headers(token));
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['data']};
      }
      return {'success': false, 'message': 'Gagal memuat stok'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> tambahPemasukan(int nominal) async {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/keuangan/pemasukan'),
        headers: _headers(token),
        body: jsonEncode({
          'kategori': 'Pemasukan',
          'keterangan': 'Top Up',
          'total_nominal': nominal,
          'detail': {'info': 'Set Uang Makan Bulanan'}
        }),
      );
      return {
        'success': response.statusCode == 200 || response.statusCode == 201
      };
    } catch (e) {
      return {'success': false};
    }
  }

  Future<Map<String, dynamic>> tukarResepTodo(
      String resepId, int sesiKe, String sesiLabel) async {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan'};
    }

    try {
      // NOTE: Jika rute di file web.php/api.php milikmu ikut ganti jadi /jadwal-harian, ubah url ini!
      // Disini aku asumsikan endpoint url nya masih '/jadwal-makan'.
      final response = await http.post(
        Uri.parse('$baseUrl/jadwal-makan'),
        headers: _headers(token),
        body: jsonEncode({
          'Id_Resep': resepId,
          'sesi_ke': sesiKe, // KIRIM SESI_KE KE BACKEND
          'Sesi Makan': sesiLabel,
          'Tanggal': DateTime.now().toIso8601String().split('T')[0]
        }),
      );
      return {
        'success': response.statusCode == 200 || response.statusCode == 201
      };
    } catch (e) {
      return {'success': false};
    }
  }
}
