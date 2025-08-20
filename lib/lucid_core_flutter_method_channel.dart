import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'lucid_core_flutter_platform_interface.dart';

/// An implementation of [LucidCoreFlutterPlatform] that uses method channels.
class MethodChannelLucidCoreFlutter extends LucidCoreFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('lucid_core_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
