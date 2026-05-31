import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/auth_services.dart';

/// Singleton ChangeNotifier sebagai jembatan komunikasi antara
/// ConsultationPage / HomePage dan TodoPage.
class TodoNotifier extends ChangeNotifier {
  TodoNotifier._();
  static final TodoNotifier instance = TodoNotifier._();

  // Swap yang belum di-apply (baru masuk dari HomePage/ConsultationPage)
  final Map<int, Map<String, dynamic>> _pendingSwaps = {};

  // Swap yang sudah di-apply — dipakai ulang setelah refresh
  final Map<int, Map<String, dynamic>> _appliedSwaps = {};

  bool _todosLoaded = false;
  bool get todosLoaded => _todosLoaded;
  void markTodosLoaded() => _todosLoaded = true;

  void resetTodosLoaded() {
    _todosLoaded = false;
    _appliedSwaps.clear();
  }

  bool get hasPending => _pendingSwaps.isNotEmpty;

  List<Map<String, dynamic>> consumeAllPending() {
    final all = _pendingSwaps.values.toList();
    _appliedSwaps.addAll(_pendingSwaps);
    _pendingSwaps.clear();
    return all;
  }

  List<Map<String, dynamic>> getAppliedSwaps() => _appliedSwaps.values.toList();

  void clearAppliedSwap(int sesiKe) => _appliedSwaps.remove(sesiKe);

  /// Dipanggil oleh ConsultationPage / HomePage saat user konfirmasi ganti.
  /// Sekarang menyimpan perubahan ke backend terlebih dahulu,
  /// lalu baru update state lokal.
  Future<void> gantiJadwal(Map<String, dynamic> data) async {
    final sesiKe = data['sesi_ke'] as int;
    final resepId = (data['resep']?['id'] ?? '').toString();
    final tanggal = DateTime.now().toIso8601String().substring(0, 10);

    // 1. Simpan ke backend — agar persisten setelah relog
    final berhasil = await _simpanGantiResepKeBackend(
      sesiKe: sesiKe,
      resepId: resepId,
      tanggal: tanggal,
    );

    if (!berhasil) {
      // Gagal simpan ke backend — jangan update UI
      // ConsultationPage/HomePage bisa menampilkan error dari sini
      // dengan cara menambahkan callback onError jika diperlukan
      debugPrint('❌ Gagal simpan ganti resep ke backend (sesi $sesiKe)');
      return;
    }

    // 2. Update state lokal seperti sebelumnya
    _pendingSwaps[sesiKe] = data;
    _appliedSwaps.remove(sesiKe);
    notifyListeners();
  }

  /// HTTP call ke PATCH /jadwal/ganti-resep
  Future<bool> _simpanGantiResepKeBackend({
    required int sesiKe,
    required String resepId,
    required String tanggal,
  }) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/jadwal/ganti-resep'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'sesi_ke': sesiKe,
          'resep_id': resepId,
          'tanggal': tanggal,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Ganti resep sesi $sesiKe berhasil disimpan ke backend');
        return true;
      } else {
        debugPrint('❌ Backend error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception saat ganti resep: $e');
      return false;
    }
  }
}
