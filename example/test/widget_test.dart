import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lucid_core_flutter.dart';
import 'package:lucid_core_flutter_example/main.dart';

/// Laisse la latence simulée et les éventuels rejeux s'écouler, sans recourir
/// à `pumpAndSettle` tant qu'un indicateur de progression tourne : celui-ci
/// s'anime indéfiniment et ferait expirer l'attente.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  for (int i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LucidCacheHelper.initialize(
      config: const LucidCacheManagerConfig(
        enableSecureStorage: false,
        enablePrefsStorage: false,
        autoMigration: false,
        memoryCacheConfig: LucidCacheConfig(
          encryptionEnabled: false,
          compressionEnabled: false,
          persistToDisk: false,
        ),
      ),
    );
  });

  testWidgets('affiche l\'état vide avant tout appel', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LucidExampleApp());
    await tester.pump();

    expect(find.text('Aucun appel pour le moment'), findsOneWidget);
    expect(find.text('LucidApiClient'), findsOneWidget);
  });

  testWidgets('le second appel identique est servi par le cache', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LucidExampleApp());
    await tester.pump();

    await tester.tap(find.text('Succès, puis cache'));
    await settle(tester);

    expect(find.text('Réponse reçue'), findsOneWidget);
    expect(find.text('servi par le réseau'), findsOneWidget);

    await tester.tap(find.text('Succès, puis cache'));
    await settle(tester);

    expect(find.text('servi par le cache'), findsOneWidget);
  });

  testWidgets('le scénario instable réussit après deux rejeux', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LucidExampleApp());
    await tester.pump();

    await tester.tap(find.text('Retry sur 5xx'));
    await settle(tester);

    expect(find.text('Réponse reçue'), findsOneWidget);
    // Trois passages réseau : deux 503 puis le succès.
    expect(find.text('3 passage(s)'), findsOneWidget);
  });

  testWidgets('un 404 échoue immédiatement, sans rejeu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LucidExampleApp());
    await tester.pump();

    await tester.tap(find.text('Introuvable (404)'));
    await settle(tester);

    expect(find.text('Requête en échec'), findsOneWidget);
    // Un seul passage : un 404 n'est pas transitoire, il n'est jamais rejoué.
    expect(find.text('1 passage(s)'), findsOneWidget);
    expect(find.text('statut 404'), findsOneWidget);
  });

  testWidgets('un 401 déclenche le rappel onUnauthorized', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LucidExampleApp());
    await tester.pump();

    await tester.tap(find.text('Jeton expiré (401)'));
    await settle(tester);

    expect(find.text('Requête en échec'), findsOneWidget);
    expect(find.text('onUnauthorized déclenché'), findsOneWidget);
  });
}
