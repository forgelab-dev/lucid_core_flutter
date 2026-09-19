import 'package:flutter/material.dart';

/// Direction visuelle : console d'atelier. Fond sombre, une seule couleur
/// d'accent (l'orange de la forge), le reste en niveaux de gris froids.
/// Les charges utiles JSON sont en chasse fixe, le texte d'interface en
/// proportionnelle — le contraste entre les deux familles porte la lecture.
abstract final class DemoTokens {
  const DemoTokens._();

  // Surfaces, de la plus profonde à la plus proche.
  static const Color canvas = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color raised = Color(0xFF1C2430);
  static const Color line = Color(0xFF2A323D);

  // Accent unique.
  static const Color accent = Color(0xFFFF7A1A);

  // Couleurs d'état.
  static const Color ok = Color(0xFF3FB950);
  static const Color warn = Color(0xFFD29922);
  static const Color danger = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // Texte.
  static const Color textHigh = Color(0xFFE6EDF3);
  static const Color textMid = Color(0xFFADBAC7);
  static const Color textLow = Color(0xFF768390);

  // Rythme d'espacement : multiples de 4.
  static const double gapXs = 4;
  static const double gapSm = 8;
  static const double gapMd = 16;
  static const double gapLg = 24;
  static const double gapXl = 32;

  static const double radius = 10;

  /// Famille à chasse fixe de la plateforme, pour les charges utiles.
  static const String mono = 'monospace';

  static ThemeData theme() {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ).copyWith(
          surface: canvas,
          primary: accent,
          onPrimary: canvas,
          error: danger,
          outline: line,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: textHigh,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: textHigh,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: textMid, fontSize: 14, height: 1.45),
        bodySmall: TextStyle(color: textLow, fontSize: 12.5, height: 1.4),
        labelLarge: TextStyle(
          color: textHigh,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          foregroundColor: textHigh,
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
