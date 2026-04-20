import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, String>> _notifications = [
    {'title': 'Reminder Memasak', 'message': 'Waktunya masak Mie Nyemek Telur Pedas!', 'time': '10 menit lalu', 'type': 'recipe'},
    {'title': 'Stok Hampir Habis', 'message': 'Telur tersisa 2 butir. Jangan lupa belanja!', 'time': '1 jam lalu', 'type': 'shopping'},
    {'title': 'Peringatan Budget', 'message': 'Budget mingguan tersisa Rp50.000', 'time': '3 jam lalu', 'type': 'budget'},
    {'title': 'Tips dari CookBot', 'message': 'Simpan sisa sayuran di wadah kedap udara!', 'time': '5 jam lalu', 'type': 'tip'},
  ];

  Color _getColor(String type) {
    switch (type) {
      case 'recipe': return AppTheme.orange500;
      case 'shopping': return AppTheme.blue500;
      case 'budget': return AppTheme.red500;
      default: return AppTheme.purple600;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'recipe': return Icons.restaurant_menu_rounded;
      case 'shopping': return Icons.shopping_cart_rounded;
      case 'budget': return Icons.trending_down_rounded;
      default: return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 20, right: 20, bottom: 12,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.slate50, borderRadius: BorderRadius.circular(50)),
                    child: const Icon(Icons.chevron_left, size: 24, color: AppTheme.slate800),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Notifikasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.slate800, letterSpacing: -0.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.slate100),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.slate100),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: _getColor(notif['type']!), borderRadius: BorderRadius.circular(14)),
                          child: Icon(_getIcon(notif['type']!), color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif['title']!,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.slate900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif['message']!,
                                style: const TextStyle(fontSize: 12, color: AppTheme.slate700, fontWeight: FontWeight.w500, height: 1.5),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 11, color: AppTheme.slate400),
                                  const SizedBox(width: 4),
                                  Text(notif['time']!, style: const TextStyle(fontSize: 11, color: AppTheme.slate400, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
