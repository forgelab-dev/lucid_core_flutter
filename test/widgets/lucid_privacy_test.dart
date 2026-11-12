import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lib.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child, {LucidPrivacyController? controller}) {
  final body = Scaffold(body: Center(child: child));
  return MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: [
      LucidL10n.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: LucidL10n.supportedLocales,
    home: controller == null
        ? body
        : LucidPrivacyScope(controller: controller, child: body),
  );
}

void main() {
  group('LucidPrivacy', () {
    testWidgets('un montant visible par défaut', (tester) async {
      await tester.pumpWidget(
        _host(
          const LucidPrivateText('79 522 F CFA'),
          controller: LucidPrivacyController(),
        ),
      );
      expect(find.text('79 522 F CFA'), findsOneWidget);
    });

    testWidgets('l’œil masque et remontre tous les montants de la zone', (
      tester,
    ) async {
      final controller = LucidPrivacyController();
      await tester.pumpWidget(
        _host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LucidPrivacyToggle(),
              LucidPrivateText('21 938'),
              LucidPrivateText('35 000'),
            ],
          ),
          controller: controller,
        ),
      );

      await tester.tap(find.byTooltip('Masquer les montants'));
      await tester.pumpAndSettle();
      expect(controller.hidden, isTrue);
      expect(find.text('21 938'), findsNothing);
      expect(find.text('35 000'), findsNothing);
      expect(find.text('•••••'), findsNWidgets(2));

      await tester.tap(find.byTooltip('Afficher les montants'));
      await tester.pumpAndSettle();
      expect(find.text('21 938'), findsOneWidget);
    });

    testWidgets(
      'le masque se choisit, et le lecteur d’écran ne lit pas le montant',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _host(
            const LucidPrivateText('-2 500 F CFA', mask: '••• F CFA'),
            controller: LucidPrivacyController(hidden: true),
          ),
        );
        expect(find.text('••• F CFA'), findsOneWidget);
        expect(find.bySemanticsLabel('Montant masqué'), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp('2 500')), findsNothing);
        handle.dispose();
      },
    );

    testWidgets('l’application retient le choix en écoutant le contrôleur', (
      tester,
    ) async {
      final controller = LucidPrivacyController();
      final listened = <bool>[];
      controller.addListener(() => listened.add(controller.hidden));
      await tester.pumpWidget(
        _host(const LucidPrivacyToggle(), controller: controller),
      );

      await tester.tap(find.byType(LucidPrivacyToggle));
      await tester.pump();
      expect(listened, [true]);
    });

    testWidgets('sans zone de confidentialité, le texte reste lisible', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const LucidPrivateText('1 000')));
      expect(find.text('1 000'), findsOneWidget);
    });
  });
}
