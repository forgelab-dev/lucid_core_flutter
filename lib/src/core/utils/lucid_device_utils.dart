import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class LucidDeviceUtils {
  LucidDeviceUtils._();

  static bool get isPortrait {
    final data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
    return data.orientation == Orientation.portrait;
  }

  static bool get isLandscape {
    final data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
    return data.orientation == Orientation.landscape;
  }

  static double get pixelRatio {
    final data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
    return data.devicePixelRatio;
  }

  static EdgeInsets get safeAreaPadding {
    final data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
    return data.padding;
  }

  static bool get hasNotch {
    final padding = safeAreaPadding;
    return padding.top > 20;
  }

  static Future<void> setPortraitOrientation() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  static Future<void> setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  static Future<void> setAutoOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static Future<void> vibrate({Duration duration = const Duration(milliseconds: 100)}) async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: duration.inMilliseconds);
    }
  }

  static Future<void> vibratePattern(List<int> pattern) async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(pattern: pattern);
    }
  }

  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  static void enableFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  static void disableFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
