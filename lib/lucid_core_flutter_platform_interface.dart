import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'lucid_core_flutter_method_channel.dart';

abstract class LucidCoreFlutterPlatform extends PlatformInterface {
  /// Constructs a LucidCoreFlutterPlatform.
  LucidCoreFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static LucidCoreFlutterPlatform _instance = MethodChannelLucidCoreFlutter();

  /// The default instance of [LucidCoreFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelLucidCoreFlutter].
  static LucidCoreFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LucidCoreFlutterPlatform] when
  /// they register themselves.
  static set instance(LucidCoreFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
