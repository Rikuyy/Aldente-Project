import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;

  // 1. DAFTAR AKUN (REGISTER)
  Future<Map<String, dynamic>> register(String username, String email,
      String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true && data['access_token'] != null) {
        await saveToken(data['access_token']);
      }

      return data;
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // 2. MASUK AKUN (LOGIN)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true && data['access_token'] != null) {
        await saveToken(data['access_token']);
      }

      return data;
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // 3. LUPA PASSWORD - KIRIM KODE OTP KE EMAIL
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengirim OTP: $e'};
    }
  }

  // 4. VERIFIKASI KODE OTP (REVISI TAMBAHAN)
  Future<Map<String, dynamic>> verifyOtp(String email, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otpCode,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memverifikasi OTP: $e'};
    }
  }

  // 5. ATUR ULANG PASSWORD BARU (REVISI TAMBAHAN)
  Future<Map<String, dynamic>> resetPassword(
      String email, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengatur ulang sandi: $e'};
    }
  }

  // 6. AMBIL DATA PROFIL USER (ME)
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        await removeToken();
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali'
        };
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil data profil'};
    }
  }

  // 7. KELUAR AKUN (LOGOUT)
  Future<void> logout() async {
    final token = await getToken();
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print("Error saat logout: $e");
    } finally {
      await removeToken();
    }
  }

  // --- MANAGEMENT ENKRIPSI TOKEN ---

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
