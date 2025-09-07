import 'package:flutter/material.dart';

import '../../mixins/mixins.dart'
    show
        LucidAnalyticsConfigMixin,
        LucidAppConfigMixin,
        LucidConfigMixin,
        LucidDTConfigMixin,
        LucidLocationConfigMixin,
        LucidMediaConfigMixin,
        LucidNetworkConfigMixin,
        LucidPaginationConfigMixin,
        LucidSecurityConfigMixin,
        LucidStorageConfigMixin,
        LucidUIConfigMixin;
import '../constants/constants.dart';

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

  static set config(LucidConfigHelpers config) {
    _instance = config;
  }

  static LucidConfigHelpers get current => _instance;

  static void reset() {
    _instance = LucidConfigHelpers();
  }
}

class LucidOverrideConfig extends LucidConfigHelpers {
  LucidOverrideConfig() : super._internal();

  final LucidJsonMap _overrides = {};

  void overrides<T>(String key, T value) {
    _overrides[key] = value;
  }

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

  static LucidOverrideConfig createWithOverrides(LucidJsonMap overrides) {
    final config = LucidOverrideConfig();
    config._overrides.addAll(overrides);
    return config;
  }

  void addAll(LucidJsonMap overrides) {
    _overrides.addAll(overrides);
  }

  dynamic operator [](String key) {
    return getOverride<dynamic>(key);
  }

  void operator []=(String key, dynamic value) {
    overrides(key, value);
  }

  bool containsKey(String key) {
    return _overrides.containsKey(key);
  }

  dynamic remove(String key) {
    return _overrides.remove(key);
  }

  void clear() {
    _overrides.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = invocation.memberName.toString().replaceAll('Symbol("', '').replaceAll('")', '');

    if (invocation.isGetter) {
      final override = getOverride<dynamic>(methodName);
      if (override != null) {
        return override;
      }

      try {
        return super.noSuchMethod(invocation);
      } catch (e) {
        return null;
      }
    }

    return super.noSuchMethod(invocation);
  }
}

class LucidConfigBuilder {
  final LucidJsonMap _config = {};

  LucidConfigBuilder set<T>(String key, T value) {
    _config[key] = value;
    return this;
  }

  T? get<T>(String key) {
    final value = _config[key];
    return value is T ? value : null;
  }

  LucidConfigBuilder setAll(LucidJsonMap config) {
    _config.addAll(config);
    return this;
  }

  dynamic operator [](String key) {
    return _config[key];
  }

  void operator []=(String key, dynamic value) {
    _config[key] = value;
  }

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

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = invocation.memberName.toString().replaceAll('Symbol("', '').replaceAll('")', '');

    if (invocation.isMethod && invocation.positionalArguments.length == 1) {
      final value = invocation.positionalArguments.first;
      final configKey = _convertMethodNameToConfigKey(methodName);
      _config[configKey] = value;
      return this;
    }

    if (invocation.isGetter) {
      final configKey = _convertMethodNameToConfigKey(methodName);
      return _config[configKey];
    }

    return super.noSuchMethod(invocation);
  }

  LucidOverrideConfig build() {
    return LucidOverrideConfig.createWithOverrides(_config);
  }

  LucidJsonMap getConfig() => Map.unmodifiable(_config);

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
  LucidConfigHelpers get lucidConfig {
    return LucidConfigProvider.of(this) ?? LucidGlobalConfig.current;
  }

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
