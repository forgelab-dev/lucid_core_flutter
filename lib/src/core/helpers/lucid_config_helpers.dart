import 'package:flutter/material.dart';

import '../../mixins/lucid_constant_mixins.dart';

class LucidConfigHelpers
    with
        LucidAppConfigMixin,
        LucidNetworkConfigMixin,
        LucidStorageConfigMixin,
        LucidSecurityConfigMixin,
        LucidUIConfigMixin,
        LucidPaginationConfigMixin,
        LucidDTConfigMixin,
        LucidMediaConfigMixin,
        LucidLocationConfigMixin,
        LucidAnalyticsConfigMixin,
        LucidConfigMixin {
  static final LucidConfigHelpers _instance = LucidConfigHelpers._internal();

  factory LucidConfigHelpers() => _instance;

  LucidConfigHelpers._internal();
}

class LucidGlobalConfig {
  static LucidConfigHelpers _instance = LucidConfigHelpers();

  /// Définir une configuration personnalisée globalement
  static set config(LucidConfigHelpers config) {
    _instance = config;
  }

  /// Obtenir la configuration actuelle
  static LucidConfigHelpers get current => _instance;

  /// Réinitialiser à la configuration par défaut
  static void reset() {
    _instance = LucidConfigHelpers();
  }
}

class LucidOverrideConfig extends LucidConfigHelpers {
  LucidOverrideConfig() : super._internal();

  final Map<String, dynamic> _overrides = {};

  /// Override une valeur spécifique
  void overrides<T>(String key, T value) {
    _overrides[key] = value;
  }

  /// Récupérer un override avec typage sûr
  T? getOverride<T>(String key) {
    final value = _overrides[key];
    if (value is T) return value;
    return null;
  }

  void removeOverride(String key) {
    _overrides.remove(key);
  }

  void clearOverrides() {
    _overrides.clear();
  }

  /// Constructeur pour créer avec des overrides
  static LucidOverrideConfig createWithOverrides(Map<String, dynamic> overrides) {
    final config = LucidOverrideConfig();
    config._overrides.addAll(overrides);
    return config;
  }

  /// Ajouter plusieurs overrides
  void addAll(Map<String, dynamic> overrides) {
    _overrides.addAll(overrides);
  }

  /// Opérateur d'accès par index
  dynamic operator [](String key) {
    return getOverride<dynamic>(key);
  }

  /// Opérateur d'assignation par index
  void operator []=(String key, dynamic value) {
    overrides(key, value);
  }

  /// Vérifier si une clé existe
  bool containsKey(String key) {
    return _overrides.containsKey(key);
  }

  /// Supprimer une clé
  dynamic remove(String key) {
    return _overrides.remove(key);
  }

  /// Vider tous les overrides
  void clear() {
    _overrides.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Extraire le nom de la méthode/propriété
    final methodName = invocation.memberName.toString().replaceAll('Symbol("', '').replaceAll('")', '');

    // Si c'est un getter
    if (invocation.isGetter) {
      // D'abord vérifier si on a un override
      final override = getOverride<dynamic>(methodName);
      if (override != null) {
        return override;
      }

      // Sinon, déléguer au parent (les mixins)
      // Le parent LucidConfigHelpers va automatiquement utiliser les mixins
      try {
        return super.noSuchMethod(invocation);
      } catch (e) {
        // Si le parent ne peut pas gérer, retourner null
        return null;
      }
    }

    // Pour les autres types d'invocations, déléguer au parent
    return super.noSuchMethod(invocation);
  }
}

class LucidConfigBuilder {
  final Map<String, dynamic> _config = {};

  /// Méthode générique pour setter n'importe quelle propriété
  LucidConfigBuilder set<T>(String key, T value) {
    _config[key] = value;
    return this;
  }

  /// Getter générique pour récupérer une valeur
  T? get<T>(String key) {
    final value = _config[key];
    return value is T ? value : null;
  }

  /// Méthode pour setter plusieurs valeurs à la fois
  LucidConfigBuilder setAll(Map<String, dynamic> config) {
    _config.addAll(config);
    return this;
  }

  /// Opérateur d'accès par index
  dynamic operator [](String key) {
    return _config[key];
  }

  /// Opérateur d'assignation par index
  void operator []=(String key, dynamic value) {
    _config[key] = value;
  }

  /// Convertit certains noms de méthodes en clés de config spécifiques
  String _convertMethodNameToConfigKey(String methodName) {
    switch (methodName) {
      case 'bufferSize':
        return 'analyticsLogBufferSize';
      case 'sessionTimeout':
        return 'analyticsSessionTimeout';
      case 'inactivityCheck':
        return 'analyticsInactivityCheckInterval';
      default:
        return methodName;
    }
  }

  /// Intercepter les appels de méthodes dynamiques
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = invocation.memberName.toString().replaceAll('Symbol("', '').replaceAll('")', '');

    if (invocation.isMethod && invocation.positionalArguments.length == 1) {
      // C'est un setter fluide de type: builder.appName("value")
      final value = invocation.positionalArguments.first;
      final configKey = _convertMethodNameToConfigKey(methodName);
      _config[configKey] = value;
      return this;
    }

    if (invocation.isGetter) {
      // C'est un getter de type: builder.appName
      final configKey = _convertMethodNameToConfigKey(methodName);
      return _config[configKey];
    }

    // Fallback sur le comportement par défaut
    return super.noSuchMethod(invocation);
  }

  /// Construction de l'objet final
  LucidOverrideConfig build() {
    return LucidOverrideConfig.createWithOverrides(_config);
  }

  /// Méthodes utilitaires pour inspection
  Map<String, dynamic> getConfig() => Map.unmodifiable(_config);

  bool hasKey(String key) => _config.containsKey(key);

  void removeKey(String key) => _config.remove(key);

  void clear() => _config.clear();

  @override
  String toString() => 'LucidConfigBuilder($_config)';
}

class LucidConfigProvider extends InheritedWidget {
  final LucidConfigHelpers config;

  const LucidConfigProvider({super.key, required this.config, required super.child});

  static LucidConfigHelpers? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LucidConfigProvider>()?.config;
  }

  @override
  bool updateShouldNotify(LucidConfigProvider oldWidget) {
    return config != oldWidget.config;
  }
}

extension LucidConfigExtension on BuildContext {
  /// Accès à la configuration via le provider ou global
  LucidConfigHelpers get lucidConfig {
    return LucidConfigProvider.of(this) ?? LucidGlobalConfig.current;
  }

  /// Accès rapide aux configurations spécifiques
  LucidAppConfigMixin get appConfig => lucidConfig;

  LucidNetworkConfigMixin get networkConfig => lucidConfig;

  LucidStorageConfigMixin get storageConfig => lucidConfig;

  LucidSecurityConfigMixin get securityConfig => lucidConfig;

  LucidUIConfigMixin get uiConfig => lucidConfig;

  LucidPaginationConfigMixin get paginationConfig => lucidConfig;

  LucidDTConfigMixin get dateTimeConfig => lucidConfig;

  LucidMediaConfigMixin get mediaConfig => lucidConfig;

  LucidLocationConfigMixin get locationConfig => lucidConfig;

  LucidAnalyticsConfigMixin get analyticsConfig => lucidConfig;
}
