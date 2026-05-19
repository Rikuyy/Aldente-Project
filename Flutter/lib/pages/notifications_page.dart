import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class _Notification {
  final String id;
  final String type;
  final String title;
  final String message;
  final String time;
  final String date;
  bool isRead;

  _Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.date,
    required this.isRead,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _filter = 'all';

  final List<_Notification> _notifications = [
    _Notification(id: '1', type: 'recipe', title: 'Reminder Memasak', message: 'Waktunya masak Mie Nyemek Telur Pedas untuk makan siang! Semua bahan sudah tersedia di dapurmu.', time: '10 menit lalu', date: 'Hari ini', isRead: false),
    _Notification(id: '2', type: 'shopping', title: 'Stok Hampir Habis', message: 'Telur tersisa 2 butir. Jangan lupa belanja besok agar tidak kehabisan bahan masakan favoritmu!', time: '1 jam lalu', date: 'Hari ini', isRead: false),
    _Notification(id: '3', type: 'budget', title: 'Peringatan Budget', message: 'Budget mingguan tersisa Rp50.000 dari total Rp200.000. Pertimbangkan masak sendiri untuk hemat.', time: '3 jam lalu', date: 'Hari ini', isRead: false),
    _Notification(id: '4', type: 'tip', title: 'Tips dari CookBot', message: 'Simpan sisa sayuran di wadah kedap udara agar tahan lebih lama hingga 5 hari!', time: '5 jam lalu', date: 'Hari ini', isRead: true),
    _Notification(id: '5', type: 'recipe', title: 'Resep Baru Untukmu', message: 'Berdasarkan DNA rasa kamu, kami merekomendasikan Nasi Goreng Pedas Manis. Cek sekarang!', time: '1 hari lalu', date: 'Kemarin', isRead: true),
    _Notification(id: '6', type: 'budget', title: 'Laporan Minggu Lalu', message: 'Kamu berhasil menghemat Rp75.000 minggu lalu dengan masak sendiri. Pertahankan!', time: '2 hari lalu', date: '28 Maret', isRead: true),
    _Notification(id: '7', type: 'shopping', title: 'Reminder Belanja', message: 'Bawang merah dan cabai sudah habis. Tambahkan ke daftar belanja minggu ini.', time: '3 hari lalu', date: '27 Maret', isRead: true),
  ];

  IconData _getIcon(String type) {
    switch (type) {
      case 'recipe': return Icons.restaurant_menu_rounded;
      case 'shopping': return Icons.shopping_cart_rounded;
      case 'budget': return Icons.trending_down_rounded;
      default: return Icons.auto_awesome_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'recipe': return AppTheme.orange500;
      case 'shopping': return AppTheme.blue500;
      case 'budget': return AppTheme.red500;
      default: return AppTheme.purple600;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<_Notification> get _filtered =>
      _filter == 'unread' ? _notifications.where((n) => !n.isRead).toList() : _notifications;

  Map<String, List<_Notification>> get _grouped {
    final map = <String, List<_Notification>>{};
    for (final n in _filtered) {
      map.putIfAbsent(n.date, () => []).add(n);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Column(
        children: [
          Container(
            color: context.colors.cardBackground,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 20, right: 20, bottom: 12,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(50)),
                        child: Icon(Icons.chevron_left, size: 24, color: context.colors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notifikasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.colors.textPrimary, letterSpacing: -0.5)),
                          if (_unreadCount > 0)
                            Text('$_unreadCount belum dibaca', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.surface)),
                        ],
                      ),
                    ),
                    if (_unreadCount > 0)
                      GestureDetector(
                        onTap: () => setState(() {
                          for (final n in _notifications) { n.isRead = true; }
                        }),
                        child: const Text('Tandai Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.orange600)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: ['all', 'unread'].map((f) {
                    final label = f == 'all' ? 'Semua' : 'Belum Dibaca${_unreadCount > 0 ? ' ($_unreadCount)' : ''}';
                    final isSelected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.orange500 : context.colors.border,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? context.colors.cardBackground : context.colors.textSecondary)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.border),

          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: context.colors.border, shape: BoxShape.circle),
                          child: Icon(Icons.check_circle_outline_rounded, size: 48, color: context.colors.textHint),
                        ),
                        const SizedBox(height: 16),
                        Text('Semua Sudah Dibaca!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: context.colors.textPrimary)),
                        const SizedBox(height: 8),
                         Text('Tidak ada notifikasi yang belum dibaca.', style: TextStyle(fontSize: 13, color: context.colors.surface, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: _grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Text(
                              entry.key.toUpperCase(),
                              style:  TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: context.colors.surface, letterSpacing: 1),
                            ),
                          ),
                          ...entry.value.map((notif) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Dismissible(
                              key: Key(notif.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.red50, borderRadius: BorderRadius.circular(20)),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete_outline_rounded, color: AppTheme.red500),
                              ),
                              onDismissed: (_) => setState(() => _notifications.removeWhere((n) => n.id == notif.id)),
                              child: GestureDetector(
                                onTap: () => setState(() => notif.isRead = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: notif.isRead ? context.colors.cardBackground : const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: notif.isRead ? context.colors.border : AppTheme.orange200),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 10.2), blurRadius: 6, offset: const Offset(0, 2))],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: _getColor(notif.type), borderRadius: BorderRadius.circular(14)),
                                        child: Icon(_getIcon(notif.type), color: context.colors.cardBackground, size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    notif.title,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 13,
                                                      color: notif.isRead ? context.colors.textPrimary : AppTheme.slate900,
                                                    ),
                                                  ),
                                                ),
                                                if (!notif.isRead)
                                                  Container(
                                                    width: 8, height: 8,
                                                    margin: const EdgeInsets.only(top: 4),
                                                    decoration: const BoxDecoration(color: AppTheme.orange500, shape: BoxShape.circle),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              notif.message,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: notif.isRead ? context.colors.surface : context.colors.textPrimary,
                                                height: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time_rounded, size: 11, color: context.colors.textHint),
                                                const SizedBox(width: 4),
                                                Text(notif.time, style: TextStyle(fontSize: 11, color: context.colors.textHint, fontWeight: FontWeight.w700)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}