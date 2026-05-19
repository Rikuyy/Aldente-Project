import 'package:cook_cash/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  final VoidCallback onToggle;

  const ThemeToggle({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton(
      onPressed: onToggle,
      backgroundColor: isDark
          ? const Color(0xFFFB923C)
          : const Color(0xFFEA580C),
      foregroundColor: context.colors.cardBackground,
      elevation: 4,
      shape: const CircleBorder(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
        ),
      ),
    );
  }
}