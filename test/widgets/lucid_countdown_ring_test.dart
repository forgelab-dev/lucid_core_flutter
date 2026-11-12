import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lib.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('montre son contenu au centre et se lit comme un tout', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const LucidCountdownRing(
          progress: 0.4,
          size: 120,
          semanticLabel: 'Gainage',
          semanticValue: '24 secondes restantes',
          child: Text('0:24'),
        ),
      ),
    );

    expect(find.text('0:24'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(LucidCountdownRing.paintKey)),
      const Size(120, 120),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Gainage'));
    expect(node.value, '24 secondes restantes');
    semantics.dispose();
  });

  testWidgets('accepte une part hors bornes ou invalide sans erreur', (
    tester,
  ) async {
    for (final progress in [-1.0, 0.0, 1.0, 3.0, double.nan]) {
      await tester.pumpWidget(
        host(LucidCountdownRing(progress: progress, size: 80)),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
