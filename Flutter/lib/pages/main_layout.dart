import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/app/consultation')) return 1;
    if (loc.startsWith('/app/finance')) return 2;
    if (loc.startsWith('/app/inventory')) return 3;
    if (loc.startsWith('/app/todo')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.slate50,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded,        label: 'Beranda',  isActive: idx == 0, onTap: () => context.go('/app/home')),
                _NavItem(icon: Icons.chat_bubble_rounded, label: 'Chat',     isActive: idx == 1, onTap: () => context.go('/app/consultation')),
                _NavItem(icon: Icons.pie_chart_rounded,   label: 'Keuangan', isActive: idx == 2, onTap: () => context.go('/app/finance')),
                _NavItem(icon: Icons.inventory_2_rounded, label: 'Stok',     isActive: idx == 3, onTap: () => context.go('/app/inventory')),
                _NavItem(icon: Icons.checklist_rounded,   label: 'To-Do',    isActive: idx == 4, onTap: () => context.go('/app/todo')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.orange50 : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? AppTheme.orange600 : AppTheme.slate400),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: isActive ? AppTheme.orange600 : AppTheme.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
