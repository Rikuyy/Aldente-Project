class ApiConfig {
  // 1. Jika pakai Emulator Android, gunakan: http://10.0.2.2:8000/api
  // 2. Jika pakai HP Fisik (WiFi sama), gunakan IP Laptop, contoh: http://192.168.1.5:8000/api
  // 3. Jika pakai iOS Simulator, gunakan: http://127.0.0.1:8000/api

  static const String _host = '10.0.2.2'; // Ubah di sini saja jika ganti device
  static const String _port = '8000';

  static const String baseUrl = 'http://192.168.1.10:8000/api';
}
