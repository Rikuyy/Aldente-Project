import 'package:flutter/material.dart';

class AppTheme {
  static const white = Color.fromARGB(255, 255, 255, 255);

  static const orange50 = Color(0xFFFFF7ED);
  static const orange100 = Color(0xFFFFEDD5);
  static const orange200 = Color(0xFFFED7AA);
  static const orange300 = Color(0xFFFDBA74);
  static const orange400 = Color(0xFFFB923C);
  static const orange500 = Color(0xFFF97316);
  static const orange600 = Color(0xFFEA580C);
  static const orange700 = Color(0xFFC2410C);

  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);

  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);

  static const red50 = Color(0xFFFFF1F2);
  static const red100 = Color(0xFFFFE4E6);
  static const red200 = Color(0xFFFECDD3);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);

  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue500 = Color(0xFF3B82F6);
  static const blue700 = Color(0xFF1D4ED8);

  static const purple50 = Color(0xFFFAF5FF);
  static const purple100 = Color(0xFFF3E8FF);
  static const purple200 = Color(0xFFE9D5FF);
  static const purple600 = Color(0xFF9333EA);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: orange600,
        secondary: orange500,
        surface: Colors.white,
      ),
      fontFamily: 'SF Pro Display',
      scaffoldBackgroundColor: slate50,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: slate800,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: orange600,
        unselectedItemColor: slate400,
        type: BottomNavigationBarType.fixed,
      ),
      extensions: const [AppColors.light],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: orange400,
        secondary: orange500,
        surface: slate800,
        onSurface: slate100,
      ),
      fontFamily: 'SF Pro Display',
      scaffoldBackgroundColor: slate900,
      appBarTheme: const AppBarTheme(
        backgroundColor: slate800,
        foregroundColor: slate100,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: slate800,
        selectedItemColor: orange400,
        unselectedItemColor: slate500,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: const CardThemeData(color: slate800),
      dividerColor: slate700,
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: slate800,
        filled: true,
      ),
      extensions: const [AppColors.dark],
    );
  }
}

class AppColors extends ThemeExtension<AppColors> {
  final Color surface;
  final Color surfaceSecondary;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color cardBackground;
  final Color inputFill;
  final Color chipBackground;  
final Color chipText;

  const AppColors({
    required this.surface,
    required this.surfaceSecondary,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.cardBackground,
    required this.inputFill,
    required this.chipBackground,
    required this.chipText,
  });

  @override
  AppColors copyWith({
    Color? surface,
    Color? surfaceSecondary,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? cardBackground,
    Color? inputFill,
    Color? chipBackground,
    Color? chipText,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      cardBackground: cardBackground ?? this.cardBackground,
      inputFill: inputFill ?? this.inputFill, 
      chipBackground: chipBackground ?? this.chipBackground, 
      chipText: chipText ?? this.chipText,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) => this;

  static const light = AppColors(
    surface: AppTheme.slate50,
    surfaceSecondary: Colors.white,
    border: AppTheme.slate100,
    textPrimary: AppTheme.slate800,
    textSecondary: AppTheme.slate500,
    textHint: AppTheme.slate400,
    cardBackground: Colors.white,
    inputFill: AppTheme.slate50,
    chipBackground: AppTheme.slate100,
chipText: AppTheme.slate600,
    
  );

  static const dark = AppColors(
    surface: AppTheme.slate900,
    surfaceSecondary: AppTheme.slate800,
    border: AppTheme.slate700,
    textPrimary: AppTheme.slate100,
    textSecondary: AppTheme.slate400,
    textHint: AppTheme.slate600,
    cardBackground: AppTheme.slate800,
    inputFill: AppTheme.slate800,
    chipBackground: AppTheme.slate700,
chipText: AppTheme.slate300,
  );
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}