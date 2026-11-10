import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lib.dart';

/// Un écran avec un bouton qui affiche le message.
Widget _host(void Function(BuildContext) onPressed, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? LucidThemes.defaultLight.toThemeData(),
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => onPressed(context),
            child: const Text('Montrer'),
          ),
        ),
      ),
    ),
  );
}

final Finder _pill = find.byKey(LucidSnack.pillKey);

void main() {
  group('LucidSnack', () {
    testWidgets('une pastille compacte, ajustée à son texte', (tester) async {
      await tester.pumpWidget(
        _host(
          (c) => LucidSnack.show(
            c,
            message: 'Dépense enregistrée.',
            icon: Icons.check,
          ),
        ),
      );
      await tester.tap(find.text('Montrer'));
      await tester.pumpAndSettle();

      expect(find.text('Dépense enregistrée.'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      final size = tester.getSize(_pill);
      expect(size.height, lessThanOrEqualTo(48), reason: 'compacte');
      expect(
        size.width,
        lessThan(
          tester.view.physicalSize.width / tester.view.devicePixelRatio - 64,
        ),
        reason: 'pas un bandeau sur toute la largeur',
      );
      expect(
        find.byIcon(Icons.close),
        findsNothing,
        reason: 'pas de croix : il part seul',
      );
      expect(
        tester.getSize(find.text('Dépense enregistrée.')).height,
        lessThan(14 * 1.3 * 1.5),
        reason: 'une seule ligne',
      );
    });

    testWidgets('part seul, même avec une action', (tester) async {
      var undone = 0;
      await tester.pumpWidget(
        _host(
          (c) => LucidSnack.show(
            c,
            message: 'Opération supprimée.',
            actionLabel: 'Annuler',
            onAction: () => undone++,
          ),
        ),
      );
      await tester.tap(find.text('Montrer'));
      await tester.pumpAndSettle();
      expect(find.text('Annuler'), findsOneWidget);
      expect(
        tester.getSize(find.text('Opération supprimée.')).height,
        lessThan(14 * 1.3 * 1.5),
        reason: 'une seule ligne',
      );

      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(find.text('Opération supprimée.'), findsNothing);
      expect(undone, 0);
    });

    testWidgets('l’action s’exécute et ferme le message', (tester) async {
      var undone = 0;
      await tester.pumpWidget(
        _host(
          (c) => LucidSnack.show(
            c,
            message: 'Opération supprimée.',
            actionLabel: 'Annuler',
            onAction: () => undone++,
          ),
        ),
      );
      await tester.tap(find.text('Montrer'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(undone, 1);
      expect(find.text('Opération supprimée.'), findsNothing);
    });

    testWidgets('se chasse d’un glissement de côté', (tester) async {
      await tester.pumpWidget(
        _host((c) => LucidSnack.show(c, message: 'Profil exporté.')),
      );
      await tester.tap(find.text('Montrer'));
      await tester.pumpAndSettle();

      await tester.fling(_pill, const Offset(300, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Profil exporté.'), findsNothing);
    });

    testWidgets('un nouveau message remplace le précédent', (tester) async {
      var n = 0;
      await tester.pumpWidget(
        _host((c) => LucidSnack.show(c, message: 'Message ${++n}')),
      );
      await tester.tap(find.text('Montrer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Montrer'));
      await tester.pumpAndSettle();

      expect(find.text('Message 1'), findsNothing);
      expect(find.text('Message 2'), findsOneWidget);
    });

    testWidgets('prend ses couleurs dans le thème des messages', (
      tester,
    ) async {
      final theme = LucidThemes.defaultLight.toThemeData().copyWith(
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1E2A5A),
          contentTextStyle: TextStyle(color: Color(0xFFF1F5F9)),
          actionTextColor: Color(0xFF22D3EE),
        ),
      );
      await tester.pumpWidget(
        _host(
          (c) => LucidSnack.show(
            c,
            message: 'Supprimé.',
            actionLabel: 'Annuler',
            onAction: () {},
          ),
          theme: theme,
        ),
      );
      await tester.tap(find.text('Montrer'));
      await tester.pumpAndSettle();

      final box = tester.widget<DecoratedBox>(
        find.descendant(of: _pill, matching: find.byType(DecoratedBox)).first,
      );
      expect((box.decoration as BoxDecoration).color, const Color(0xFF1E2A5A));
      expect(
        tester.widget<Text>(find.text('Supprimé.')).style?.color,
        const Color(0xFFF1F5F9),
      );
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Annuler'),
      );
      expect(
        button.style?.foregroundColor?.resolve({}),
        const Color(0xFF22D3EE),
      );
    });

    testWidgets('à côté de la pastille, le toucher atteint l’écran dessous', (
      tester,
    ) async {
      var behind = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => behind++,
                child: Center(
                  child: TextButton(
                    onPressed: () =>
                        LucidSnack.show(context, message: 'Court.'),
                    child: const Text('Montrer'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Montrer'));
      await tester.pumpAndSettle();
      behind = 0;

      final pill = tester.getRect(_pill);
      await tester.tapAt(Offset(pill.left - 40, pill.center.dy));
      expect(
        behind,
        1,
        reason: 'le porteur transparent ne doit pas avaler le toucher',
      );
    });
  });
}
