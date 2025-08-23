import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LucidAppInfoUtils {
  const LucidAppInfoUtils._({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildSignature,
    required this.installerStore,
  });

  final String appName;

  final String packageName;

  final String version;

  final String buildNumber;

  final String buildSignature;

  final String? installerStore;

  static LucidAppInfoUtils? _instance;

  static Future<LucidAppInfoUtils> getInstance() async {
    if (_instance != null) return _instance!;

    final packageInfo = await PackageInfo.fromPlatform();

    _instance = LucidAppInfoUtils._(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildSignature: packageInfo.buildSignature,
      installerStore: packageInfo.installerStore,
    );

    return _instance!;
  }

  String get fullVersion => '$version+$buildNumber';

  String get displayVersion => 'v$version ($buildNumber)';

  bool get isFromPlayStore => installerStore == 'com.android.vending';

  bool get isFromAppStore => installerStore == 'com.apple';

  bool get isDebugBuild => buildSignature.isEmpty || kDebugMode;

  @override
  String toString() {
    return 'LucidAppInfo('
        'appName: $appName, '
        'version: $fullVersion, '
        'packageName: $packageName'
        ')';
  }
}
