import 'package:flutter/foundation.dart';

import '../constants/constants.dart' show LucidEnvironment, LucidEntriesMap;

class LucidEnvironmentConfig {
  final LucidEnvironment environment;
  final String apiBaseUrl;
  final String? apiVersion;
  final bool enableLogging;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final Duration apiTimeout;
  final Duration cacheTimeout;
  final LucidEntriesMap<bool> features;

  const LucidEnvironmentConfig._({
    required this.environment,
    required this.apiBaseUrl,
    this.apiVersion,
    required this.enableLogging,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.apiTimeout,
    required this.cacheTimeout,
    required this.features,
  });

  String get fullApiUrl => "$apiBaseUrl/${apiVersion ?? 'v1'}";

  static bool get _isStaging {
    return const String.fromEnvironment("FLUTTER_ENV") == "staging";
  }

  bool isFeatureEnabled(String feature) {
    return features[feature] ?? false;
  }

  factory LucidEnvironmentConfig.development({String? apiBaseUrl, String? apiVersion}) {
    return LucidEnvironmentConfig._(
      environment: LucidEnvironment.development,
      apiBaseUrl: apiBaseUrl ?? 'https://api-dev.lucidforge.com',
      apiVersion: apiVersion ?? 'v1',
      enableLogging: true,
      enableAnalytics: false,
      enableCrashReporting: false,
      apiTimeout: const Duration(seconds: 60),
      cacheTimeout: const Duration(minutes: 1),
      features: const {'debug_mode': true, 'mock_data': true, 'beta_features': true, 'performance_monitoring': true},
    );
  }

  factory LucidEnvironmentConfig.staging({String? apiBaseUrl, String? apiVersion}) {
    return LucidEnvironmentConfig._(
      environment: LucidEnvironment.staging,
      apiBaseUrl: apiBaseUrl ?? 'https://api-staging.lucidforge.com',
      apiVersion: apiVersion ?? 'v1',
      enableLogging: true,
      enableAnalytics: true,
      enableCrashReporting: true,
      apiTimeout: const Duration(seconds: 30),
      cacheTimeout: const Duration(minutes: 5),
      features: {'debug_mode': false, 'mock_data': false, 'beta_features': true, 'performance_monitoring': true},
    );
  }

  factory LucidEnvironmentConfig.production({String? apiBaseUrl, String? apiVersion}) {
    return LucidEnvironmentConfig._(
      environment: LucidEnvironment.production,
      apiBaseUrl: apiBaseUrl ?? 'https://api.lucidforge.com',
      apiVersion: apiVersion ?? 'v1',
      enableLogging: false,
      enableAnalytics: true,
      enableCrashReporting: true,
      apiTimeout: const Duration(seconds: 30),
      cacheTimeout: const Duration(minutes: 10),
      features: {'debug_mode': false, 'mock_data': false, 'beta_features': false, 'performance_monitoring': false},
    );
  }

  static LucidEnvironmentConfig get current {
    if (kDebugMode) {
      return LucidEnvironmentConfig.development();
    } else if (_isStaging) {
      return LucidEnvironmentConfig.staging();
    } else {
      return LucidEnvironmentConfig.production();
    }
  }

  @override
  String toString() {
    return 'LucidEnvironmentConfig('
        'environment: $environment, '
        'apiBaseUrl: $apiBaseUrl, '
        'enableLogging: $enableLogging'
        ')';
  }
}
