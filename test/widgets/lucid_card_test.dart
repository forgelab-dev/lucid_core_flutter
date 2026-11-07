import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lib.dart';

Widget _host(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LucidThemes.defaultLight.toThemeData(),
    home: Scaffold(body: Center(child: child)),
  );
}

RoundedRectangleBorder _shapeOf(WidgetTester tester) {
  final material = tester.widget<Material>(
    find.descendant(of: find.byType(LucidCard), matching: find.byType(Material)).first,
  );
  return material.shape! as RoundedRectangleBorder;
}

/// Le nœud sémantique unique de la carte (fusion du bouton et de son texte).
final Finder _cardSemantics = find.descendant(of: find.byType(LucidCard), matching: find.byType(MergeSemantics));

void main() {
  group('LucidCard', () {
    testWidgets('affiche son contenu sans réagir au toucher', (tester) async {
      await tester.pumpWidget(_host(const LucidCard(child: Text('Solde du mois'))));

      expect(find.text('Solde du mois'), findsOneWidget);
      expect(find.descendant(of: find.byType(LucidCard), matching: find.byType(InkWell)), findsNothing);
    });

    testWidgets('prend le rayon de la forme du cardTheme', (tester) async {
      final theme = ThemeData(
        cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
      );
      await tester.pumpWidget(_host(const LucidCard(child: Text('x')), theme: theme));

      expect(_shapeOf(tester).borderRadius, BorderRadius.circular(24));
    });

    testWidgets('sans forme arrondie dans le thème, garde le rayon par défaut', (tester) async {
      await tester.pumpWidget(_host(const LucidCard(child: Text('x')), theme: ThemeData()));

      expect(_shapeOf(tester).borderRadius, BorderRadius.circular(LucidCard.defaultRadius));
    });

    testWidgets('selected remplace le filet par un trait primary de 2 px', (tester) async {
      final theme = LucidThemes.defaultLight.toThemeData();
      await tester.pumpWidget(_host(const LucidCard(selected: true, child: Text('x')), theme: theme));

      final side = _shapeOf(tester).side;
      expect(side.color, theme.colorScheme.primary);
      expect(side.width, 2);
    });

    testWidgets('suit le thème sombre comme le clair', (tester) async {
      final light = LucidThemes.defaultLight.toThemeData();
      final dark = LucidThemes.defaultDark.toThemeData();

      await tester.pumpWidget(_host(const LucidCard(child: Text('x')), theme: light));
      expect(_shapeOf(tester).side.color, light.colorScheme.outlineVariant);

      await tester.pumpWidget(_host(const LucidCard(child: Text('x')), theme: dark));
      await tester.pumpAndSettle();
      expect(_shapeOf(tester).side.color, dark.colorScheme.outlineVariant);
      expect(light.colorScheme.outlineVariant, isNot(dark.colorScheme.outlineVariant));
    });
  });

  group('LucidCard.interactive', () {
    testWidgets('appelle onTap et onLongPress', (tester) async {
      var taps = 0;
      var longPresses = 0;
      await tester.pumpWidget(
        _host(
          LucidCard.interactive(onTap: () => taps++, onLongPress: () => longPresses++, child: const Text('Profil')),
        ),
      );

      await tester.tap(find.text('Profil'));
      await tester.longPress(find.text('Profil'));

      expect(taps, 1);
      expect(longPresses, 1);
    });

    testWidgets('se présente comme un bouton aux lecteurs d’écran', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(LucidCard.interactive(onTap: () {}, semanticLabel: 'Ouvrir le profil Ama', child: const Text('Ama'))),
      );

      expect(
        tester.getSemantics(_cardSemantics),
        matchesSemantics(
          label: 'Ouvrir le profil Ama',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasSelectedState: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('sans onTap ni onLongPress, s’affiche désactivée', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const LucidCard.interactive(onTap: null, child: Text('Bientôt'))));

      final opacity = tester.widget<Opacity>(
        find.descendant(of: find.byType(LucidCard), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, LucidCard.disabledOpacity);
      expect(
        tester.getSemantics(_cardSemantics),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasSelectedState: true,
          label: 'Bientôt',
        ),
      );
      handle.dispose();
    });

    testWidgets('reçoit le focus clavier', (tester) async {
      await tester.pumpWidget(_host(LucidCard.interactive(onTap: () {}, child: const Text('x'))));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final focused = FocusManager.instance.primaryFocus?.context;
      expect(focused?.findAncestorWidgetOfExactType<LucidCard>(), isNotNull);
    });
  });
}
