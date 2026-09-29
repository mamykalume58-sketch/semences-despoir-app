import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Charte graphique reprise de css/style.css (site web).
class AppColors {
  AppColors._();
  static const vert = Color(0xFF0B6B3A);
  static const vertFonce = Color(0xFF063B2A);
  static const vertClair = Color(0xFFEAF7EF);
  static const or = Color(0xFFFFC107);
  static const grisClair = Color(0xFFF6F8F7);
  static const texte = Color(0xFF17221D);
  static const texteSecondaire = Color(0xFF66736C);
  static const bordure = Color(0xFFE3EAE6);
  static const erreur = Color(0xFFD93025);
}

class AppText {
  AppText._();
  static const h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.vertFonce);
  static const h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.vertFonce);
  static const h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.texte);
  static const body = TextStyle(fontSize: 14, height: 1.55, color: AppColors.texteSecondaire);
  static const small = TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.texteSecondaire);
  static const eyebrow = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1, color: AppColors.vert);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.vert,
      primary: AppColors.vert,
      secondary: AppColors.or,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
  );
  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.texte, displayColor: AppColors.texte),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.vertFonce,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.vertFonce),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.vertClair,
      surfaceTintColor: Colors.transparent,
      height: 68,
    ),
  );
}
