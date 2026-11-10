import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lucid_core_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Compte les changements de luminosité reçus par un widget ordinaire.
class _BrightnessSpy with WidgetsBindingObserver {
  int changes = 0;

  @override
  void didChangePlatformBrightness() => changes++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'les autres observateurs reçoivent toujours le passage clair/sombre',
    (tester) async {
      final spy = _BrightnessSpy();
      tester.binding.addObserver(spy);
      addTearDown(() => tester.binding.removeObserver(spy));
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final notifier = LucidThemeNotifier();
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      expect(
        spy.changes,
        1,
        reason: 'le notifier ne doit pas confisquer le rappel de Flutter',
      );

      notifier.dispose();
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      expect(spy.changes, 2, reason: 'ni le couper en se libérant');
    },
  );

  testWidgets('en mode système, le notifier prévient ses écouteurs', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    final notifier = LucidThemeNotifier();
    addTearDown(notifier.dispose);
    await tester.pump();

    var notified = 0;
    notifier.addListener(() => notified++);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;

    expect(notified, 1);
    expect(
      notifier.getCurrentTheme(Brightness.dark),
      notifier.currentDarkTheme,
    );
  });
}
