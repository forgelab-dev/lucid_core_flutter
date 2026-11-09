import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lucid_core_flutter.dart';

void main() {
  testWidgets('context.push et context.pop restent disponibles sans go_router', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => context.push<void>(
              Builder(
                builder: (inner) => TextButton(onPressed: () => inner.pop<void>(), child: const Text('Fermer')),
              ),
            ),
            child: const Text('Ouvrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Fermer'), findsOneWidget);

    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    expect(find.text('Ouvrir'), findsOneWidget);
  });
}
