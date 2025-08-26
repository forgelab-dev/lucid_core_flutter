import 'lucid_core_flutter_platform_interface.dart';

export 'lib.dart';

class LucidCoreFlutter {
  Future<String?> getPlatformVersion() {
    return LucidCoreFlutterPlatform.instance.getPlatformVersion();
  }
}
