class ApiConfig {
  // Ubah ke 127.0.0.1 karena kamu sedang running di Web (Edge/Chrome)
  static const String _host = '127.0.0.1';
  static const String _port = '8000';

  static const String baseUrl = 'http://$_host:$_port/api';
}
