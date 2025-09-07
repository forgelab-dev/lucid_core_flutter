import 'dart:async';

import 'package:flutter/material.dart';

import '../../functions/functions.dart';
import '../constants/constants.dart';
import '../helpers/helpers.dart';
import '../models/models.dart';
import 'lucid_themes.dart';

class LucidThemeNotifier extends ChangeNotifier {
  LucidThemeNotifier() {
    _loadSavedTheme();
    _setupSystemThemeListener();
  }

  LucidThemeMode _themeMode = LucidThemeMode.system;
  LucidAppTheme _currentLightTheme = LucidThemes.defaultLight;
  LucidAppTheme _currentDarkTheme = LucidThemes.defaultDark;
  LucidAppTheme? _customTheme;

  bool _isLoading = false;
  String? _error;
  Brightness? _lastSystemBrightness;

  final logger = LucidLogger();

  // Getters
  LucidThemeMode get themeMode => _themeMode;

  LucidAppTheme get currentLightTheme => _currentLightTheme;

  LucidAppTheme get currentDarkTheme => _currentDarkTheme;

  LucidAppTheme? get customTheme => _customTheme;

  bool get isLoading => _isLoading;

  String? get error => _error;

  ThemeData get lightThemeData => _currentLightTheme.toThemeData();

  ThemeData get darkThemeData => _currentDarkTheme.toThemeData();

  bool get isSystemMode => _themeMode == LucidThemeMode.system;

  bool get isLightMode => _themeMode == LucidThemeMode.light;

  bool get isDarkMode => _themeMode == LucidThemeMode.dark;

  LucidAppTheme getCurrentTheme(Brightness systemBrightness) {
    if (_customTheme != null) return _customTheme!;
    switch (_themeMode) {
      case LucidThemeMode.light:
        return _currentLightTheme;
      case LucidThemeMode.dark:
        return _currentDarkTheme;
      case LucidThemeMode.system:
        return systemBrightness == Brightness.dark ? _currentDarkTheme : _currentLightTheme;
    }
  }

  // ===========================================================================
  // GESTION DES THÈMES
  // ===========================================================================

  Future<void> setThemeMode(LucidThemeMode mode) async {
    if (_themeMode == mode) return;

    _setLoading = true;
    _clearError();

    try {
      _themeMode = mode;
      await _saveThemeToCache();
      if (mode == LucidThemeMode.system) {
        _setupSystemThemeListener();
      }
      logger.warn('Mode de thème changé vers: ${mode.displayName}');
    } catch (e) {
      _setError = 'Erreur lors du changement de mode de thème: $e';
      logger.warn('Erreur setThemeMode: $e', tag: 'THEME_ERROR');
    }

    _setLoading = false;
    notifyListeners();
  }

  Future<void> setLightTheme(LucidAppTheme theme) async {
    if (_currentLightTheme.name == theme.name) return;

    _setLoading = true;
    _clearError();

    try {
      _currentLightTheme = theme;
      await _saveThemeToCache();
      logger.warn('Thème clair changé vers: ${theme.name}');
    } catch (e) {
      _setError = 'Erreur lors du changement de thème clair: $e';
    }

    _setLoading = false;
    notifyListeners();
  }

  Future<void> setDarkTheme(LucidAppTheme theme) async {
    if (_currentDarkTheme.name == theme.name) return;

    _setLoading = true;
    _clearError();

    try {
      _currentDarkTheme = theme;
      await _saveThemeToCache();
      logger.warn('Thème sombre changé vers: ${theme.name}');
    } catch (e) {
      _setError = 'Erreur lors du changement de thème sombre: $e';
    }

    _setLoading = false;
    notifyListeners();
  }

  Future<void> setCustomTheme(LucidAppTheme? theme) async {
    _setLoading = true;
    _clearError();

    try {
      _customTheme = theme;
      await _saveThemeToCache();
      logger.warn('Thème personnalisé ${theme != null ? 'appliqué: ${theme.name}' : 'supprimé'}');
    } catch (e) {
      _setError = 'Erreur lors de l\'application du thème personnalisé: $e';
    }

    _setLoading = false;
    notifyListeners();
  }

  Future<void> resetToDefault() async {
    _setLoading = true;
    _clearError();

    try {
      _themeMode = LucidThemeMode.system;
      _currentLightTheme = LucidThemes.defaultLight;
      _currentDarkTheme = LucidThemes.defaultDark;
      _customTheme = null;

      await _saveThemeToCache();
      _setupSystemThemeListener();
      logger.warn('Thèmes réinitialisés aux valeurs par défaut');
    } catch (e) {
      _setError = 'Erreur lors de la réinitialisation: $e';
    }

    _setLoading = false;
    notifyListeners();
  }

  // ===========================================================================
  // SYSTÈME THEME LISTENER
  // ===========================================================================

  void _setupSystemThemeListener() {
    _cleanupSystemThemeListener();
    if (_themeMode != LucidThemeMode.system) return;

    try {
      _lastSystemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

      WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = _checkSystemBrightnessChange;

      logger.warn('Listener du thème système configuré');
    } catch (e) {
      logger.warn('Erreur lors de la configuration du listener système: $e', tag: 'THEME_ERROR');
    }
  }

  void _checkSystemBrightnessChange() {
    try {
      final currentBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

      if (_lastSystemBrightness != currentBrightness) {
        _lastSystemBrightness = currentBrightness;

        if (_themeMode == LucidThemeMode.system) {
          logger.warn('Changement de luminosité système détecté: ${currentBrightness.name}');
          notifyListeners();
        }
      }
    } catch (e) {
      logger.warn('Erreur lors de la vérification de la luminosité: $e', tag: 'THEME_ERROR');
    }
  }

  void _cleanupSystemThemeListener() {
    // Plus besoin de Stream ni Timer.
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = null;
  }

  void checkSystemBrightness() => _checkSystemBrightnessChange();

  // ===========================================================================
  // MÉTHODES PRIVÉES
  // ===========================================================================

  set _setLoading(bool loading) {
    _isLoading = loading;
  }

  set _setError(String? error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _loadSavedTheme() async {
    try {
      final savedMode = await LucidCacheHelper.preferences.getCustomSetting<String>('theme_mode');
      if (savedMode != null) {
        _themeMode = LucidThemeMode.values.firstWhere(
          (mode) => mode.name == savedMode,
          orElse: () => LucidThemeMode.system,
        );
      }

      final savedLightTheme = await LucidCacheHelper.preferences.getCustomSetting<LucidJsonMap>('light_theme');
      if (savedLightTheme != null) {
        _currentLightTheme = LucidAppTheme.fromJson(savedLightTheme);
      }

      final savedDarkTheme = await LucidCacheHelper.preferences.getCustomSetting<LucidJsonMap>('dark_theme');
      if (savedDarkTheme != null) {
        _currentDarkTheme = LucidAppTheme.fromJson(savedDarkTheme);
      }

      final savedCustomTheme = await LucidCacheHelper.preferences.getCustomSetting<LucidJsonMap>('custom_theme');
      if (savedCustomTheme != null) {
        _customTheme = LucidAppTheme.fromJson(savedCustomTheme);
      }

      logger.warn('Thèmes chargés depuis le cache');
    } catch (e) {
      logger.warn('Erreur lors du chargement des thèmes: $e', tag: 'THEME_ERROR');
      _setError = 'Erreur lors du chargement des thèmes sauvegardés';
    }

    notifyListeners();
  }

  Future<void> _saveThemeToCache() async {
    try {
      await LucidCacheHelper.preferences.setCustomSetting('theme_mode', _themeMode.name);
      await LucidCacheHelper.preferences.setCustomSetting('light_theme', _currentLightTheme.toJson());
      await LucidCacheHelper.preferences.setCustomSetting('dark_theme', _currentDarkTheme.toJson());

      if (_customTheme != null) {
        await LucidCacheHelper.preferences.setCustomSetting('custom_theme', _customTheme!.toJson());
      } else {
        await LucidCacheHelper.preferences.setCustomSetting('custom_theme', null);
      }

      logger.warn('Thèmes sauvegardés dans le cache');
    } catch (e) {
      logger.warn('Erreur lors de la sauvegarde des thèmes: $e', tag: 'THEME_ERROR');
      throw Exception('Impossible de sauvegarder les préférences de thème');
    }
  }

  @override
  void dispose() {
    _cleanupSystemThemeListener();
    logger.warn('LucidThemeNotifier dispose');
    super.dispose();
  }
}
