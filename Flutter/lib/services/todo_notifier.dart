import 'package:flutter/foundation.dart';

/// Singleton ChangeNotifier sebagai jembatan komunikasi antara
/// ConsultationPage dan TodoPage.
///
/// Masalah: ConsultationPage dan TodoPage bisa hidup di dua cabang
/// navigator yang berbeda (go_router), sehingga Navigator.pop(result)
/// tidak bisa membawa data dari Consultation → Todo.
///
/// Solusi: ConsultationPage memanggil [gantiJadwal(data)] saat user
/// konfirmasi. TodoPage listen notifier ini dan langsung update state-nya.
///
/// Cara pakai:
///   // Di ConsultationPage setelah konfirmasi:
///   TodoNotifier.instance.gantiJadwal(result);
///
///   // Di TodoPage._initState:
///   TodoNotifier.instance.addListener(_onNotifierChanged);
///
///   // Di TodoPage.dispose:
///   TodoNotifier.instance.removeListener(_onNotifierChanged);
class TodoNotifier extends ChangeNotifier {
  TodoNotifier._();
  static final TodoNotifier instance = TodoNotifier._();

  /// Data penggantian resep terakhir.
  /// Format:
  /// {
  ///   'sesi_ke'   : int,
  ///   'sesi_label': String,
  ///   'resep'     : {
  ///     'id'         : String,
  ///     'title'      : String,
  ///     'ingredients': String,
  ///     'steps'      : String,
  ///     'category'   : String,
  ///   }
  /// }
  Map<String, dynamic>? _pendingGantiJadwal;

  /// Konsumsi data penggantian — mengembalikan data lalu reset ke null
  /// agar tidak di-apply ulang saat TodoPage rebuild berikutnya.
  Map<String, dynamic>? consumePendingGantiJadwal() {
    final data = _pendingGantiJadwal;
    _pendingGantiJadwal = null;
    return data;
  }

  /// Dipanggil oleh ConsultationPage saat user konfirmasi ganti jadwal.
  void gantiJadwal(Map<String, dynamic> data) {
    _pendingGantiJadwal = data;
    notifyListeners();
  }
}
