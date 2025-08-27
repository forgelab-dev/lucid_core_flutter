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

  static LucidAppTheme getCurrentTheme(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return instance.getCurrentTheme(brightness);
  }

  static bool isDarkMode(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final currentTheme = instance.getCurrentTheme(brightness);
    return currentTheme.brightness == Brightness.dark;
  }
}
