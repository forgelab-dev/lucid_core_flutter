import 'dart:io';

import 'package:flutter/foundation.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import 'lucid_app_info_utils.dart';
import 'lucid_device_info_utils.dart';

class LucidSystemInfoUtils {
  LucidSystemInfoUtils._();

  static Future<LucidJsonMap> getSystemInfo() async {
    final appInfo = await LucidAppInfoUtils.getInstance();
    final deviceInfo = await LucidDeviceInfoUtils.getInstance();
    final envConfig = LucidEnvironmentConfig.current;

    return {
      'app_name': appInfo.appName,
      'app_version': appInfo.fullVersion,
      'package_name': appInfo.packageName,
      'is_debug': appInfo.isDebugBuild,

      'platform': deviceInfo.platform,
      'os_version': deviceInfo.osVersion,
      'device_model': deviceInfo.model,
      'device_brand': deviceInfo.brand,
      'is_physical_device': deviceInfo.isPhysicalDevice,
      'device_id': deviceInfo.deviceId,

      'environment': envConfig.environment.name,
      'api_url': envConfig.apiBaseUrl,
      'logging_enabled': envConfig.enableLogging,
      'analytics_enabled': envConfig.enableAnalytics,

      'dart_version': Platform.version,
      'is_debug_mode': kDebugMode,
      'is_profile_mode': kProfileMode,
      'is_release_mode': kReleaseMode,

      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Future<String> getUserAgent() async {
    final appInfo = await LucidAppInfoUtils.getInstance();
    final deviceInfo = await LucidDeviceInfoUtils.getInstance();

    return '${appInfo.appName}/${appInfo.version} '
        '(${deviceInfo.platform}; ${deviceInfo.osVersion}; ${deviceInfo.model})';
  }

  static Future<String> getInstallationId() async {
    final deviceInfo = await LucidDeviceInfoUtils.getInstance();
    final appInfo = await LucidAppInfoUtils.getInstance();

    final data = '${deviceInfo.deviceId}_${appInfo.packageName}_${appInfo.version}';
    return data.hashCode.toString();
  }
}
