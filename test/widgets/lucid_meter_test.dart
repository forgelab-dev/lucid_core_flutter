import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lib.dart';

const _primary = Color(0xFF0A6A9E);
const _error = Color(0xFFD14343);

Widget _host(Widget child, {LucidPrivacyController? privacy}) {
  final body = Scaffold(
    body: Center(child: SizedBox(width: 200, child: child)),
  );
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
      ).copyWith(primary: _primary, error: _error),
    ),
    home: privacy == null
        ? body
        : LucidPrivacyScope(controller: privacy, child: body),
  );
}

double _widthFactor(WidgetTester tester, Key key) =>
    tester.widget<FractionallySizedBox>(find.byKey(key)).widthFactor!;

Color _colorOf(WidgetTester tester, Key key) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: find.byKey(key), matching: find.byType(DecoratedBox)),
  );
  return (box.decoration as BoxDecoration).color!;
}

void main() {
  group('LucidMeter.levelOf', () {
    test('normal sous le seuil, alerte à partir du seuil, dépassé au-delà', () {
      expect(LucidMeter.levelOf(79, 100), LucidMeterLevel.normal);
      expect(LucidMeter.levelOf(80, 100), LucidMeterLevel.warning);
      expect(LucidMeter.levelOf(100, 100), LucidMeterLevel.warning);
      expect(LucidMeter.levelOf(101, 100), LucidMeterLevel.over);
      expect(
        LucidMeter.levelOf(50, 100, warningAt: 0.5),
        LucidMeterLevel.warning,
      );
    });
  });

  group('LucidMeter', () {
    testWidgets('la barre suit la part atteinte, aux couleurs du thème', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const LucidMeter(value: 30, max: 120)));
      await tester.pumpAndSettle();

      expect(_widthFactor(tester, LucidMeter.valueKey), closeTo(0.25, 1e-9));
      expect(_colorOf(tester, LucidMeter.valueKey), _primary);
      expect(find.byKey(LucidMeter.projectedKey), findsNothing);
    });

    testWidgets('au-delà du maximum, la barre est pleine et prend la couleur '
        'd’erreur', (tester) async {
      await tester.pumpWidget(_host(const LucidMeter(value: 150, max: 100)));
      await tester.pumpAndSettle();

      expect(_widthFactor(tester, LucidMeter.valueKey), 1);
      expect(_colorOf(tester, LucidMeter.valueKey), _error);
    });

    testWidgets('la prévision prolonge la barre en plus clair, colorée selon '
        'son propre niveau', (tester) async {
      await tester.pumpWidget(
        _host(const LucidMeter(value: 40, max: 100, projected: 130)),
      );
      await tester.pumpAndSettle();

      expect(_widthFactor(tester, LucidMeter.valueKey), closeTo(0.4, 1e-9));
      // Plafonnée au maximum, mais en couleur de dépassement.
      expect(_widthFactor(tester, LucidMeter.projectedKey), 1);
      expect(
        _colorOf(tester, LucidMeter.projectedKey),
        _error.withValues(alpha: 0.18),
      );
    });

    testWidgets('une prévision sous la valeur ne s’affiche pas', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const LucidMeter(value: 60, max: 100, projected: 50)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(LucidMeter.projectedKey), findsNothing);
    });

    testWidgets('les couleurs se choisissent', (tester) async {
      await tester.pumpWidget(
        _host(
          const LucidMeter(
            value: 85,
            max: 100,
            warningColor: Color(0xFFE0A100),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_colorOf(tester, LucidMeter.valueKey), const Color(0xFFE0A100));
    });

    testWidgets('le lecteur d’écran lit le nom et la valeur donnés', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const LucidMeter(
            value: 45000,
            max: 60000,
            semanticLabel: 'Courses',
            semanticValue: '45 000 F sur 60 000 F',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Courses'), findsOneWidget);
      final node = tester.getSemantics(find.bySemanticsLabel('Courses'));
      expect(node.value, '45 000 F sur 60 000 F');
      semantics.dispose();
    });

    testWidgets('montants masqués : le lecteur d’écran ne lit que la part', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const LucidMeter(
            value: 45000,
            max: 60000,
            semanticLabel: 'Courses',
            semanticValue: '45 000 F sur 60 000 F',
          ),
          privacy: LucidPrivacyController(hidden: true),
        ),
      );
      await tester.pumpAndSettle();

      final node = tester.getSemantics(find.bySemanticsLabel('Courses'));
      expect(node.value, contains('75'));
      expect(node.value, isNot(contains('45 000')));
      semantics.dispose();
    });
  });
}
