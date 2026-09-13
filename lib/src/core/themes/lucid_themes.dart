import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/models.dart';

class LucidThemes {
  LucidThemes._();

  // Couleurs issues de la charte graphique LucidForge Africa
  // (docs/LFA_Charte_Graphique.docx) :
  // #020617 Navy — Primaire, #0F172A Navy — Texte, #334155 Navy — Texte secondaire,
  // #D4A017 Or — Accent, #64748B Gris — Discret, #94A3B8 Gris clair — Discret (fond sombre),
  // #F8FAFC Blanc cassé, #FFFFFF Blanc.
  static const LucidAppTheme defaultLight = LucidAppTheme(
    name: 'LucidForge Light',
    mode: LucidThemeMode.light,
    primary: Color(0xFF020617),
    secondary: Color(0xFFD4A017),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFDC2626),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF020617),
    onBackground: Color(0xFF0F172A),
    onSurface: Color(0xFF0F172A),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.light,
    accent: Color(0xFFD4A017),
    hint: Color(0xFF64748B),
    borderRadius: 16,
    cardBorderRadius: 16,
    gradientStart: Color(0xFFF8FAFC),
    gradientEnd: Color(0xFFEDF2F8),
    softShadow: Color(0x1F000000),
  );

  static const LucidAppTheme defaultDark = LucidAppTheme(
    name: 'LucidForge Dark',
    mode: LucidThemeMode.dark,
    primary: Color(0xFFD4A017),
    secondary: Color(0xFFD4A017),
    background: Color(0xFF020617),
    surface: Color(0xFF0F172A),
    error: Color(0xFFEF4444),
    onPrimary: Color(0xFF020617),
    onSecondary: Color(0xFF020617),
    onBackground: Color(0xFFF8FAFC),
    onSurface: Color(0xFFF8FAFC),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.dark,
    accent: Color(0xFFD4A017),
    hint: Color(0xFF94A3B8),
    scaffoldBackgroundColor: Color(0xFF020617),
    cardColor: Color(0xFF0F172A),
    borderRadius: 16,
    cardBorderRadius: 16,
    gradientStart: Color(0xFF020617),
    gradientEnd: Color(0xFF0B1B3A),
    softShadow: Color(0x66000000),
  );

  static const LucidAppTheme oceanBlue = LucidAppTheme(
    name: 'Ocean Blue',
    mode: LucidThemeMode.light,
    primary: Color(0xFF006064),
    secondary: Color(0xFF4DD0E1),
    background: Color(0xFFF0F9FF),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFD32F2F),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFF263238),
    onSurface: Color(0xFF263238),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );

  static const LucidAppTheme forestGreen = LucidAppTheme(
    name: 'Forest Green',
    mode: LucidThemeMode.light,
    primary: Color(0xFF2E7D32),
    secondary: Color(0xFF66BB6A),
    background: Color(0xFFF1F8E9),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFD32F2F),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFF1B5E20),
    onSurface: Color(0xFF1B5E20),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );

  static const LucidAppTheme purpleDeep = LucidAppTheme(
    name: 'Purple Deep',
    mode: LucidThemeMode.dark,
    primary: Color(0xFFBB86FC),
    secondary: Color(0xFF03DAC6),
    background: Color(0xFF1A0E27),
    surface: Color(0xFF2D1B42),
    error: Color(0xFFCF6679),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFFE1E2E1),
    onSurface: Color(0xFFE1E2E1),
    onError: Color(0xFF000000),
    brightness: Brightness.dark,
  );

  static const LucidAppTheme beninFlag = LucidAppTheme(
    name: 'Bénin Flag',
    mode: LucidThemeMode.light,
    primary: Color(0xFF009639),
    secondary: Color(0xFFFCD116),
    background: Color(0xFFFFFAF0),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFE8112D),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFF1A4A00),
    onSurface: Color(0xFF1A4A00),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFFFFAF0),
    cardColor: Color(0xFFFFFFFF),
  );

  static const LucidAppTheme beninFlagDark = LucidAppTheme(
    name: 'Bénin Flag Dark',
    mode: LucidThemeMode.dark,
    primary: Color(0xFF4CAF50),
    secondary: Color(0xFFFFD54F),
    background: Color(0xFF0D1B0D),
    surface: Color(0xFF1A2E1A),
    error: Color(0xFFEF5350),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFFE8F5E8),
    onSurface: Color(0xFFE8F5E8),
    onError: Color(0xFF000000),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF0D1B0D),
    cardColor: Color(0xFF1A2E1A),
  );

  static const LucidAppTheme sunsetGlow = LucidAppTheme(
    name: 'Sunset Glow',
    mode: LucidThemeMode.light,
    primary: Color(0xFFFF6B35),
    secondary: Color(0xFFF7931E),
    background: Color(0xFFFFF5F0),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFD32F2F),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFF5D2E00),
    onSurface: Color(0xFF5D2E00),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );

  static const LucidAppTheme midnightBlue = LucidAppTheme(
    name: 'Midnight Blue',
    mode: LucidThemeMode.dark,
    primary: Color(0xFF82B1FF),
    secondary: Color(0xFF448AFF),
    background: Color(0xFF0A0E27),
    surface: Color(0xFF1A1F3A),
    error: Color(0xFFFF6B6B),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFFFFFFFF),
    onBackground: Color(0xFFE3F2FD),
    onSurface: Color(0xFFE3F2FD),
    onError: Color(0xFF000000),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF0A0E27),
    cardColor: Color(0xFF1A1F3A),
  );

  static const LucidAppTheme roseGold = LucidAppTheme(
    name: 'Rose Gold',
    mode: LucidThemeMode.light,
    primary: Color(0xFFE91E63),
    secondary: Color(0xFFFF9800),
    background: Color(0xFFFFF0F5),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFD32F2F),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFF880E4F),
    onSurface: Color(0xFF880E4F),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );

  static const LucidAppTheme arcticBlue = LucidAppTheme(
    name: 'Arctic Blue',
    mode: LucidThemeMode.dark,
    primary: Color(0xFF00E5FF),
    secondary: Color(0xFF1DE9B6),
    background: Color(0xFF0B1426),
    surface: Color(0xFF1A2332),
    error: Color(0xFFFF5722),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFFE0F7FA),
    onSurface: Color(0xFFE0F7FA),
    onError: Color(0xFF000000),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF0B1426),
    cardColor: Color(0xFF1A2332),
  );

  static const LucidAppTheme warmEarth = LucidAppTheme(
    name: 'Warm Earth',
    mode: LucidThemeMode.light,
    primary: Color(0xFF8D6E63),
    secondary: Color(0xFFFF8A65),
    background: Color(0xFFFAF7F0),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFD32F2F),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF000000),
    onBackground: Color(0xFF3E2723),
    onSurface: Color(0xFF3E2723),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );

  static List<LucidAppTheme> get allThemes => [
    defaultLight,
    defaultDark,
    oceanBlue,
    forestGreen,
    purpleDeep,
    beninFlag,
    beninFlagDark,
    sunsetGlow,
    midnightBlue,
    roseGold,
    arcticBlue,
    warmEarth,
  ];

  static List<LucidAppTheme> get lightThemes =>
      allThemes.where((theme) => theme.brightness == Brightness.light).toList();

  static List<LucidAppTheme> get darkThemes => allThemes.where((theme) => theme.brightness == Brightness.dark).toList();

  static LucidAppTheme getThemeByName(String name) {
    return allThemes.firstWhere((theme) => theme.name == name, orElse: () => defaultLight);
  }
}
