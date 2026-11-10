import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart' show LucidL10n;
import '../../core/core.dart';
import '../../provider/provider.dart';

/// Point d'entrée d'une app LucidForge : câble en un seul endroit le thème
/// ([LucidThemeProvider]/[LucidThemeNotifier]) et les traductions communes
/// ([LucidL10n]), pour éviter de répéter ce boilerplate dans chaque projet.
///
/// ```dart
/// void main() {
///   runApp(LucidApp(title: 'Mon app', home: const HomeScreen()));
/// }
/// ```
///
/// Avec un routeur déclaratif (go_router…), utiliser [LucidApp.router] :
///
/// ```dart
/// runApp(LucidApp.router(title: 'Mon app', routerConfig: monRouteur));
/// ```
///
/// Reste indépendant : un projet qui préfère câbler son propre `MaterialApp`
/// peut ignorer ce widget et utiliser directement [LucidThemeProvider].
class LucidApp extends StatelessWidget {
  const LucidApp({
    super.key,
    required Widget this.home,
    this.title = '',
    this.themeNotifier,
    this.lightTheme,
    this.darkTheme,
    this.additionalLocalizationsDelegates = const [],
    this.additionalSupportedLocales = const [],
    this.navigatorKey,
    this.routes = const {},
    this.onGenerateRoute,
    this.builder,
    this.locale,
    this.themeAnimationDuration = const Duration(milliseconds: 250),
    this.debugShowCheckedModeBanner = false,
  }) : routerConfig = null;

  /// Application pilotée par un routeur ([RouterConfig] de go_router, par
  /// exemple) : même thème et mêmes traductions, `MaterialApp.router` dessous.
  /// La navigation (pages, clé, routes) appartient alors au routeur.
  const LucidApp.router({
    super.key,
    required RouterConfig<Object> this.routerConfig,
    this.title = '',
    this.themeNotifier,
    this.lightTheme,
    this.darkTheme,
    this.additionalLocalizationsDelegates = const [],
    this.additionalSupportedLocales = const [],
    this.builder,
    this.locale,
    this.themeAnimationDuration = const Duration(milliseconds: 250),
    this.debugShowCheckedModeBanner = false,
  }) : home = null,
       navigatorKey = null,
       routes = const {},
       onGenerateRoute = null;

  /// Écran d'accueil ; `null` avec [LucidApp.router].
  final Widget? home;

  /// Configuration du routeur ; `null` avec le constructeur par défaut.
  final RouterConfig<Object>? routerConfig;
  final String title;

  /// Notifieur de thème à utiliser ; par défaut, [LucidThemeHelper.instance]
  /// (partagé) via [LucidThemeProvider].
  final LucidThemeNotifier? themeNotifier;

  /// Surchargent le thème calculé par [themeNotifier] si fournis.
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;

  final List<LocalizationsDelegate<dynamic>> additionalLocalizationsDelegates;
  final List<Locale> additionalSupportedLocales;

  final GlobalKey<NavigatorState>? navigatorKey;
  final Map<String, WidgetBuilder> routes;
  final RouteFactory? onGenerateRoute;
  final TransitionBuilder? builder;

  /// Locale forcée (par défaut : celle du système, via [LucidL10n]).
  final Locale? locale;

  /// Durée de l'animation de transition de thème (clair ↔ sombre).
  final Duration themeAnimationDuration;

  final bool debugShowCheckedModeBanner;

  @override
  Widget build(BuildContext context) {
    return LucidThemeProvider(
      themeNotifier: themeNotifier,
      child: Builder(
        builder: (context) {
          final notifier = LucidThemeProvider.of(context);

          final theme = lightTheme ?? notifier.lightThemeData;
          final dark = darkTheme ?? notifier.darkThemeData;
          final themeMode = _toFlutterThemeMode(notifier.themeMode);
          final delegates = [...LucidL10n.localizationsDelegates, ...additionalLocalizationsDelegates];
          final locales = [...LucidL10n.supportedLocales, ...additionalSupportedLocales];

          final router = routerConfig;
          if (router != null) {
            return MaterialApp.router(
              title: title,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              theme: theme,
              darkTheme: dark,
              themeMode: themeMode,
              localizationsDelegates: delegates,
              supportedLocales: locales,
              locale: locale,
              themeAnimationDuration: themeAnimationDuration,
              routerConfig: router,
              builder: builder,
            );
          }

          return MaterialApp(
            title: title,
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            theme: theme,
            darkTheme: dark,
            themeMode: themeMode,
            localizationsDelegates: delegates,
            supportedLocales: locales,
            locale: locale,
            themeAnimationDuration: themeAnimationDuration,
            navigatorKey: navigatorKey,
            routes: routes,
            onGenerateRoute: onGenerateRoute,
            builder: builder,
            home: home,
          );
        },
      ),
    );
  }

  ThemeMode _toFlutterThemeMode(LucidThemeMode mode) {
    switch (mode) {
      case LucidThemeMode.light:
        return ThemeMode.light;
      case LucidThemeMode.dark:
        return ThemeMode.dark;
      case LucidThemeMode.system:
        return ThemeMode.system;
    }
  }
}
