import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../themes/themes.dart';

class LucidThemeHelper {
  LucidThemeHelper._();

  static LucidThemeNotifier? _instance;

  static LucidThemeNotifier get instance {
    _instance ??= LucidThemeNotifier();
    return _instance!;
  }

  static void initialize() {
    _instance = LucidThemeNotifier();
  }

  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }

  // Méthodes de commodité
  static Future<void> setThemeMode(LucidThemeMode mode) async {
    await instance.setThemeMode(mode);
  }

  static Future<void> setLightTheme(LucidAppTheme theme) async {
    await instance.setLightTheme(theme);
  }

  static Future<void> setDarkTheme(LucidAppTheme theme) async {
    await instance.setDarkTheme(theme);
  }

  static Future<void> toggleThemeMode() async {
    final current = instance.themeMode;
    LucidThemeMode newMode;

    switch (current) {
      case LucidThemeMode.light:
        newMode = LucidThemeMode.dark;
        break;
      case LucidThemeMode.dark:
        newMode = LucidThemeMode.system;
        break;
      case LucidThemeMode.system:
        newMode = LucidThemeMode.light;
        break;
    }

    await setThemeMode(newMode);
  }

  /// Utilise toujours le notifieur global ([instance]), donc ne reflète pas
  /// un `LucidThemeProvider(themeNotifier: ...)` personnalisé plus bas dans
  /// l'arbre. À l'intérieur d'un widget, préférer `context.currentTheme`
  /// (extension `LucidBuildContextExtensions`), qui lit le vrai notifieur du
  /// `LucidThemeProvider` ambiant.
  static LucidAppTheme getCurrentTheme(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return instance.getCurrentTheme(brightness);
  }

  /// Voir la note de [getCurrentTheme] : préférer `context.isDarkTheme` à
  /// l'intérieur d'un widget.
  static bool isDarkMode(BuildContext context) {
    return getCurrentTheme(context).brightness == Brightness.dark;
  }
}
