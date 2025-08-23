import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';

class LucidDeviceInfo {
  const LucidDeviceInfo._({
    required this.platform,
    required this.osVersion,
    required this.model,
    required this.brand,
    required this.isPhysicalDevice,
    required this.deviceId,
    this.androidInfo,
    this.iosInfo,
  });

  final String platform;

  final String osVersion;

  final String model;

  final String brand;

  final bool isPhysicalDevice;

  final String deviceId;

  final AndroidDeviceInfo? androidInfo;

  final IosDeviceInfo? iosInfo;

  static LucidDeviceInfo? _instance;

  static Future<LucidDeviceInfo> getInstance() async {
    if (_instance != null) return _instance!;

    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _instance = LucidDeviceInfo._(
        platform: 'Android',
        osVersion: 'Android ${androidInfo.version.release}',
        model: androidInfo.model,
        brand: androidInfo.brand,
        isPhysicalDevice: androidInfo.isPhysicalDevice,
        deviceId: androidInfo.id,
        androidInfo: androidInfo,
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _instance = LucidDeviceInfo._(
        platform: 'iOS',
        osVersion: '${iosInfo.systemName} ${iosInfo.systemVersion}',
        model: iosInfo.model,
        brand: 'Apple',
        isPhysicalDevice: iosInfo.isPhysicalDevice,
        deviceId: iosInfo.identifierForVendor ?? 'unknown',
        iosInfo: iosInfo,
      );
    } else {
      _instance = const LucidDeviceInfo._(
        platform: 'Unknown',
        osVersion: 'Unknown',
        model: 'Unknown',
        brand: 'Unknown',
        isPhysicalDevice: true,
        deviceId: 'unknown',
      );
    }

    return _instance!;
  }

  String get fullOsVersion => '$platform $osVersion';

  String get deviceDescription => '$brand $model';

  bool get isEmulator => !isPhysicalDevice;

  bool get isAndroid => platform == 'Android';

  bool get isIOS => platform == 'iOS';

  @override
  String toString() {
    return 'LucidDeviceInfo('
        'platform: $platform, '
        'model: $model, '
        'osVersion: $osVersion, '
        'isPhysical: $isPhysicalDevice'
        ')';
  }
}
