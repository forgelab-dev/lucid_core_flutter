import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Informations sur l'appareil, disponibles sur toutes les plateformes
/// supportées par le plugin (Android, iOS, Web, Windows, Linux, macOS).
///
/// N'importe jamais `dart:io`: [defaultTargetPlatform]/[kIsWeb] fonctionnent
/// partout, y compris sur le web, contrairement à `Platform.isX`.
class LucidDeviceInfoUtils {
  const LucidDeviceInfoUtils._({
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

  static LucidDeviceInfoUtils? _instance;

  static Future<LucidDeviceInfoUtils> getInstance() async {
    if (_instance != null) return _instance!;

    final deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      return _instance = LucidDeviceInfoUtils._(
        platform: 'Web',
        osVersion: webInfo.platform ?? 'Unknown',
        model: webInfo.browserName.name,
        brand: webInfo.vendor ?? 'Unknown',
        isPhysicalDevice: true,
        deviceId: webInfo.userAgent ?? 'unknown',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final androidInfo = await deviceInfo.androidInfo;
        return _instance = LucidDeviceInfoUtils._(
          platform: 'Android',
          osVersion: 'Android ${androidInfo.version.release}',
          model: androidInfo.model,
          brand: androidInfo.brand,
          isPhysicalDevice: androidInfo.isPhysicalDevice,
          deviceId: androidInfo.id,
          androidInfo: androidInfo,
        );
      case TargetPlatform.iOS:
        final iosInfo = await deviceInfo.iosInfo;
        return _instance = LucidDeviceInfoUtils._(
          platform: 'iOS',
          osVersion: '${iosInfo.systemName} ${iosInfo.systemVersion}',
          model: iosInfo.model,
          brand: 'Apple',
          isPhysicalDevice: iosInfo.isPhysicalDevice,
          deviceId: iosInfo.identifierForVendor ?? 'unknown',
          iosInfo: iosInfo,
        );
      case TargetPlatform.windows:
        final windowsInfo = await deviceInfo.windowsInfo;
        return _instance = LucidDeviceInfoUtils._(
          platform: 'Windows',
          osVersion: windowsInfo.displayVersion,
          model: windowsInfo.productName,
          brand: 'Microsoft',
          isPhysicalDevice: true,
          deviceId: windowsInfo.deviceId,
        );
      case TargetPlatform.linux:
        final linuxInfo = await deviceInfo.linuxInfo;
        return _instance = LucidDeviceInfoUtils._(
          platform: 'Linux',
          osVersion: linuxInfo.version ?? linuxInfo.versionId ?? linuxInfo.prettyName,
          model: linuxInfo.prettyName,
          brand: linuxInfo.id,
          isPhysicalDevice: true,
          deviceId: linuxInfo.machineId ?? 'unknown',
        );
      case TargetPlatform.macOS:
        final macInfo = await deviceInfo.macOsInfo;
        return _instance = LucidDeviceInfoUtils._(
          platform: 'macOS',
          osVersion: '${macInfo.majorVersion}.${macInfo.minorVersion}.${macInfo.patchVersion} (${macInfo.osRelease})',
          model: macInfo.model,
          brand: 'Apple',
          isPhysicalDevice: true,
          deviceId: macInfo.systemGUID ?? 'unknown',
        );
      case TargetPlatform.fuchsia:
        return _instance = const LucidDeviceInfoUtils._(
          platform: 'Fuchsia',
          osVersion: 'Unknown',
          model: 'Unknown',
          brand: 'Unknown',
          isPhysicalDevice: true,
          deviceId: 'unknown',
        );
    }
  }

  String get fullOsVersion => '$platform $osVersion';

  String get deviceDescription => '$brand $model';

  bool get isEmulator => !isPhysicalDevice;

  bool get isAndroid => platform == 'Android';

  bool get isIOS => platform == 'iOS';

  @override
  String toString() {
    return 'LucidDeviceInfoUtils('
        'platform: $platform, '
        'model: $model, '
        'osVersion: $osVersion, '
        'isPhysical: $isPhysicalDevice'
        ')';
  }
}
