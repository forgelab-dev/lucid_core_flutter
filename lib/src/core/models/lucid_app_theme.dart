import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';

class LucidAppTheme {
  const LucidAppTheme({
    required this.name,
    required this.mode,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.onError,
    this.brightness = Brightness.light,
    this.accent,
    this.disabled,
    this.hint,
    this.divider,
    this.shadow,
    this.cardColor,
    this.scaffoldBackgroundColor,
    this.appBarElevation = 0,
    this.cardElevation = 1,
    this.elevatedButtonElevation = 1,
    this.outlinedButtonElevation = 0,
    this.textButtonElevation = 0,
    this.borderRadius = 8.0,
    this.cardBorderRadius = 12.0,
  });

  final String name;
  final LucidThemeMode mode;
  final Color primary, secondary, background, surface, error;
  final Color onPrimary, onSecondary, onBackground, onSurface, onError;
  final Brightness brightness;
  final Color? accent, disabled, hint, divider, shadow, cardColor, scaffoldBackgroundColor;
  final double appBarElevation, cardElevation, elevatedButtonElevation;
  final double outlinedButtonElevation, textButtonElevation;
  final double borderRadius, cardBorderRadius;

  ThemeData toThemeData() {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: onError,
      surface: surface,
      onSurface: onSurface,
      primaryContainer: primary.withValues(alpha: 0.1),
      onPrimaryContainer: primary,
      secondaryContainer: secondary.withValues(alpha: 0.1),
      onSecondaryContainer: secondary,
      tertiary: accent ?? secondary,
      onTertiary: onSecondary,
      tertiaryContainer: (accent ?? secondary).withValues(alpha: 0.1),
      onTertiaryContainer: accent ?? secondary,
      errorContainer: error.withValues(alpha: 0.1),
      onErrorContainer: error,
      outline: onSurface.withValues(alpha: 0.2),
      outlineVariant: onSurface.withValues(alpha: 0.1),
      surfaceContainerHighest: surface,
      onSurfaceVariant: onSurface.withValues(alpha: 0.8),
      inverseSurface: onSurface,
      onInverseSurface: surface,
      inversePrimary: primary.withValues(alpha: 0.8),
      shadow: shadow ?? Colors.black.withValues(alpha: 0.2),
      scrim: Colors.black.withValues(alpha: 0.5),
      surfaceTint: primary.withValues(alpha: 0.05),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? background,
      cardColor: cardColor ?? surface,
      dividerColor: divider ?? colorScheme.outline,
      disabledColor: disabled ?? colorScheme.onSurface.withValues(alpha: 0.38),
      hintColor: hint ?? colorScheme.onSurface.withValues(alpha: 0.6),
      shadowColor: colorScheme.shadow,

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: appBarElevation,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(color: onSurface, fontSize: 20, fontWeight: FontWeight.w500),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: elevatedButtonElevation,
          shadowColor: colorScheme.shadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          elevation: outlinedButtonElevation,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          elevation: textButtonElevation,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: error, width: 2),
        ),
        filled: false,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: cardElevation,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardBorderRadius)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: primary, fontSize: 12);
          }
          return TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12);
        }),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.3);
          }
          return colorScheme.outline.withValues(alpha: 0.3);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return null;
        }),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withValues(alpha: 0.3),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.1),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withValues(alpha: 0.3),
        circularTrackColor: primary.withValues(alpha: 0.3),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardBorderRadius)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        elevation: 16,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(cardBorderRadius))),
      ),
    );
  }

  LucidAppTheme copyWith({
    String? name,
    LucidThemeMode? mode,
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? error,
    Color? onPrimary,
    Color? onSecondary,
    Color? onBackground,
    Color? onSurface,
    Color? onError,
    Brightness? brightness,
    Color? accent,
    Color? disabled,
    Color? hint,
    Color? divider,
    Color? shadow,
    Color? cardColor,
    Color? scaffoldBackgroundColor,
    double? appBarElevation,
    double? cardElevation,
    double? elevatedButtonElevation,
    double? outlinedButtonElevation,
    double? textButtonElevation,
    double? borderRadius,
    double? cardBorderRadius,
  }) {
    return LucidAppTheme(
      name: name ?? this.name,
      mode: mode ?? this.mode,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      error: error ?? this.error,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      onError: onError ?? this.onError,
      brightness: brightness ?? this.brightness,
      accent: accent ?? this.accent,
      disabled: disabled ?? this.disabled,
      hint: hint ?? this.hint,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      cardColor: cardColor ?? this.cardColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      appBarElevation: appBarElevation ?? this.appBarElevation,
      cardElevation: cardElevation ?? this.cardElevation,
      elevatedButtonElevation: elevatedButtonElevation ?? this.elevatedButtonElevation,
      outlinedButtonElevation: outlinedButtonElevation ?? this.outlinedButtonElevation,
      textButtonElevation: textButtonElevation ?? this.textButtonElevation,
      borderRadius: borderRadius ?? this.borderRadius,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mode': mode.name,
      'primary': primary.toARGB32(),
      'secondary': secondary.toARGB32(),
      'background': background.toARGB32(),
      'surface': surface.toARGB32(),
      'error': error.toARGB32(),
      'onPrimary': onPrimary.toARGB32(),
      'onSecondary': onSecondary.toARGB32(),
      'onBackground': onBackground.toARGB32(),
      'onSurface': onSurface.toARGB32(),
      'onError': onError.toARGB32(),
      'brightness': brightness.name,
      'accent': accent?.toARGB32(),
      'disabled': disabled?.toARGB32(),
      'hint': hint?.toARGB32(),
      'divider': divider?.toARGB32(),
      'shadow': shadow?.toARGB32(),
      'cardColor': cardColor?.toARGB32(),
      'scaffoldBackgroundColor': scaffoldBackgroundColor?.toARGB32(),
      'appBarElevation': appBarElevation,
      'cardElevation': cardElevation,
      'elevatedButtonElevation': elevatedButtonElevation,
      'outlinedButtonElevation': outlinedButtonElevation,
      'textButtonElevation': textButtonElevation,
      'borderRadius': borderRadius,
      'cardBorderRadius': cardBorderRadius,
    };
  }

  factory LucidAppTheme.fromJson(Map<String, dynamic> json) {
    return LucidAppTheme(
      name: json['name'] as String,
      mode: LucidThemeMode.values.firstWhere((m) => m.name == json['mode'], orElse: () => LucidThemeMode.system),
      primary: Color(json['primary'] as int),
      secondary: Color(json['secondary'] as int),
      background: Color(json['background'] as int),
      surface: Color(json['surface'] as int),
      error: Color(json['error'] as int),
      onPrimary: Color(json['onPrimary'] as int),
      onSecondary: Color(json['onSecondary'] as int),
      onBackground: Color(json['onBackground'] as int),
      onSurface: Color(json['onSurface'] as int),
      onError: Color(json['onError'] as int),
      brightness: Brightness.values.firstWhere((b) => b.name == json['brightness'], orElse: () => Brightness.light),
      accent: json['accent'] != null ? Color(json['accent'] as int) : null,
      disabled: json['disabled'] != null ? Color(json['disabled'] as int) : null,
      hint: json['hint'] != null ? Color(json['hint'] as int) : null,
      divider: json['divider'] != null ? Color(json['divider'] as int) : null,
      shadow: json['shadow'] != null ? Color(json['shadow'] as int) : null,
      cardColor: json['cardColor'] != null ? Color(json['cardColor'] as int) : null,
      scaffoldBackgroundColor: json['scaffoldBackgroundColor'] != null
          ? Color(json['scaffoldBackgroundColor'] as int)
          : null,
      appBarElevation: (json['appBarElevation'] as num?)?.toDouble() ?? 0,
      cardElevation: (json['cardElevation'] as num?)?.toDouble() ?? 1,
      elevatedButtonElevation: (json['elevatedButtonElevation'] as num?)?.toDouble() ?? 1,
      outlinedButtonElevation: (json['outlinedButtonElevation'] as num?)?.toDouble() ?? 0,
      textButtonElevation: (json['textButtonElevation'] as num?)?.toDouble() ?? 0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 8.0,
      cardBorderRadius: (json['cardBorderRadius'] as num?)?.toDouble() ?? 12.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LucidAppTheme &&
        other.name == name &&
        other.mode == mode &&
        other.primary == primary &&
        other.secondary == secondary &&
        other.background == background &&
        other.surface == surface &&
        other.brightness == brightness;
  }

  @override
  int get hashCode {
    return Object.hash(name, mode, primary, secondary, background, surface, brightness);
  }

  @override
  String toString() {
    return 'LucidAppTheme(name: $name, mode: $mode, brightness: $brightness)';
  }
}
