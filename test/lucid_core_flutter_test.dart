import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lucid_core_flutter.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLucidCoreFlutterPlatform with MockPlatformInterfaceMixin implements LucidCoreFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LucidCoreFlutterPlatform initialPlatform = LucidCoreFlutterPlatform.instance;

  test('$MethodChannelLucidCoreFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLucidCoreFlutter>());
  });

  test('getPlatformVersion', () async {
    final LucidCoreFlutter lucidCoreFlutterPlugin = LucidCoreFlutter();
    final MockLucidCoreFlutterPlatform fakePlatform = MockLucidCoreFlutterPlatform();
    LucidCoreFlutterPlatform.instance = fakePlatform;

    expect(await lucidCoreFlutterPlugin.getPlatformVersion(), '42');
  });
}
