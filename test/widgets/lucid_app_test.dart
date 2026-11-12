import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lucid_core_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Routeur minimal (une seule page), à la place de go_router.
class _OnePageDelegate extends RouterDelegate<Object> with ChangeNotifier {
  _OnePageDelegate(this.page);

  final Widget page;

  @override
  Widget build(BuildContext context) => Navigator(
    pages: [MaterialPage<void>(child: page)],
    onDidRemovePage: (_) {},
  );

  @override
  Future<bool> popRoute() => SynchronousFuture(false);

  @override
  Future<void> setNewRoutePath(Object configuration) => SynchronousFuture(null);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('LucidApp.router câble le thème et les traductions sous un routeur', (tester) async {
    final notifier = LucidThemeNotifier();
    addTearDown(notifier.dispose);
    late BuildContext captured;

    await tester.pumpWidget(
      LucidApp.router(
        themeNotifier: notifier,
        routerConfig: RouterConfig<Object>(
          routerDelegate: _OnePageDelegate(
            Builder(
              builder: (context) {
                captured = context;
                return const Text('Accueil routé');
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accueil routé'), findsOneWidget);
    expect(LucidThemeProvider.of(captured), same(notifier));
    expect(LucidL10n.of(captured), isNotNull);
    expect(Theme.of(captured).colorScheme.primary, notifier.lightThemeData.colorScheme.primary);
  });

  testWidgets('le constructeur par défaut garde son écran d’accueil', (tester) async {
    await tester.pumpWidget(const LucidApp(home: Text('Accueil')));
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsOneWidget);
  });
}
