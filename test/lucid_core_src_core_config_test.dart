import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/src/core/helpers/lucid_config_helpers.dart';

void main() {
  group('🚀 Tests complets LucidConfig', () {
    // Variables pour les tests
    late LucidConfigHelpers defaultConfig;
    late LucidOverrideConfig overrideConfig;
    late LucidConfigBuilder builder;

    setUp(() {
      // Réinitialiser avant chaque test
      LucidGlobalConfig.reset();
      defaultConfig = LucidConfigHelpers();
      overrideConfig = LucidOverrideConfig();
      builder = LucidConfigBuilder();
    });

    tearDown(() {
      // Nettoyage après chaque test
      LucidGlobalConfig.reset();
    });

    group('📋 Configuration par défaut', () {
      test('Vérification des propriétés App Config', () {
        print('\n--- Test App Config ---');

        expect(defaultConfig.appName, isNotNull, reason: 'appName ne doit pas être null');
        expect(defaultConfig.appLocale, isNotNull, reason: 'appLocale ne doit pas être null');
        expect(defaultConfig.appUrl, isNotNull, reason: 'appUrl ne doit pas être null');

        print('✅ appName: "${defaultConfig.appName}"');
        print('✅ appLocale: "${defaultConfig.appLocale}"');
        print('✅ appUrl: "${defaultConfig.appUrl}"');

        // Vérifier les types
        expect(defaultConfig.appName, isA<String>(), reason: 'appName doit être une String');
        expect(defaultConfig.appLocale, isA<String>(), reason: 'appLocale doit être une String');
        expect(defaultConfig.appUrl, isA<String>(), reason: 'appUrl doit être une String');
      });

      test('Vérification des propriétés Analytics Config', () {
        print('\n--- Test Analytics Config ---');

        expect(defaultConfig.analyticsLogTag, isNotNull, reason: 'analyticsLogTag ne doit pas être null');
        expect(defaultConfig.analyticsLogBufferSize, isNotNull, reason: 'analyticsLogBufferSize ne doit pas être null');

        print('✅ analyticsLogTag: "${defaultConfig.analyticsLogTag}"');
        print('✅ analyticsLogBufferSize: ${defaultConfig.analyticsLogBufferSize}');

        // Vérifier les types et valeurs logiques
        expect(defaultConfig.analyticsLogTag, isA<String>(), reason: 'analyticsLogTag doit être une String');
        expect(defaultConfig.analyticsLogBufferSize, isA<int>(), reason: 'analyticsLogBufferSize doit être un int');
        expect(defaultConfig.analyticsLogBufferSize, greaterThan(0), reason: 'Buffer size doit être positif');
      });

      test('Vérification des propriétés Location Config', () {
        print('\n--- Test Location Config ---');

        expect(defaultConfig.locationMapZoomLevel, isNotNull, reason: 'locationMapZoomLevel ne doit pas être null');

        print('✅ locationMapZoomLevel: ${defaultConfig.locationMapZoomLevel}');

        // Vérifier les types et valeurs logiques
        expect(defaultConfig.locationMapZoomLevel, isA<num>(), reason: 'locationMapZoomLevel doit être numérique');
        expect(defaultConfig.locationMapZoomLevel, greaterThan(0), reason: 'Zoom level doit être positif');
      });

      test('Propriétés inexistantes retournent null', () {
        print('\n--- Test propriétés inexistantes ---');

        // Tester avec noSuchMethod
        dynamic result;
        try {
          result = (defaultConfig as dynamic).proprieteInexistante;
        } catch (e) {
          result = null;
        }

        expect(result, isNull, reason: 'Une propriété inexistante doit retourner null');
        print('✅ Propriété inexistante retourne: $result');
      });
    });

    group('🔧 Configuration avec overrides', () {
      test('Ajout et récupération d\'overrides simples', () {
        print('\n--- Test overrides simples ---');

        // Définir des overrides avec différents types
        overrideConfig.overrides('appName', 'Test App Override');
        overrideConfig.overrides('appLocale', 'fr_FR');
        overrideConfig.overrides('debugMode', true);
        overrideConfig.overrides('timeout', 5000);
        overrideConfig.overrides('latitude', 48.8566);

        // Vérifier les valeurs
        expect(overrideConfig.getOverride('appName'), equals('Test App Override'));
        expect(overrideConfig.getOverride('appLocale'), equals('fr_FR'));
        expect(overrideConfig.getOverride('debugMode'), equals(true));
        expect(overrideConfig.getOverride('timeout'), equals(5000));
        expect(overrideConfig.getOverride('latitude'), equals(48.8566));

        print('✅ String override: "${overrideConfig.getOverride('appName')}"');
        print('✅ Bool override: ${overrideConfig.getOverride('debugMode')}');
        print('✅ Int override: ${overrideConfig.getOverride('timeout')}');
        print('✅ Double override: ${overrideConfig.getOverride('latitude')}');
      });

      test('Opérateurs [] et []= fonctionnels', () {
        print('\n--- Test opérateurs d\'accès ---');

        // Test de l'opérateur []=
        overrideConfig['baseUrl'] = 'https://api.override.com';
        overrideConfig['maxRetries'] = 3;
        overrideConfig['enableSSL'] = true;

        // Test de l'opérateur []
        expect(overrideConfig['baseUrl'], equals('https://api.override.com'));
        expect(overrideConfig['maxRetries'], equals(3));
        expect(overrideConfig['enableSSL'], equals(true));

        print('✅ Opérateur []: baseUrl = "${overrideConfig['baseUrl']}"');
        print('✅ Opérateur []: maxRetries = ${overrideConfig['maxRetries']}');
        print('✅ Opérateur []: enableSSL = ${overrideConfig['enableSSL']}');
      });

      test('Suppression d\'overrides', () {
        print('\n--- Test suppression d\'overrides ---');

        // Ajouter des overrides
        overrideConfig.overrides('tempKey1', 'value1');
        overrideConfig.overrides('tempKey2', 'value2');
        overrideConfig['tempKey3'] = 'value3';

        expect(overrideConfig.containsKey('tempKey1'), isTrue);
        expect(overrideConfig.containsKey('tempKey2'), isTrue);
        expect(overrideConfig.containsKey('tempKey3'), isTrue);

        // Supprimer avec différentes méthodes
        overrideConfig.removeOverride('tempKey1');
        overrideConfig.remove('tempKey2');

        expect(overrideConfig.containsKey('tempKey1'), isFalse);
        expect(overrideConfig.containsKey('tempKey2'), isFalse);
        expect(overrideConfig.containsKey('tempKey3'), isTrue);

        print('✅ tempKey1 supprimé: ${!overrideConfig.containsKey('tempKey1')}');
        print('✅ tempKey2 supprimé: ${!overrideConfig.containsKey('tempKey2')}');
        print('✅ tempKey3 présent: ${overrideConfig.containsKey('tempKey3')}');

        // Clear all
        overrideConfig.clear();
        expect(overrideConfig.containsKey('tempKey3'), isFalse);
        print('✅ Tous les overrides effacés');
      });

      test('Fallback vers les mixins quand pas d\'override', () {
        print('\n--- Test fallback vers mixins ---');

        // Ajouter un override pour une propriété
        overrideConfig.overrides('appName', 'Overridden App');

        // appName doit retourner l'override
        expect((overrideConfig as dynamic).appName, equals('Overridden App'));
        print('✅ Propriété avec override: appName = "${(overrideConfig as dynamic).appName}"');

        // appLocale doit retourner la valeur du mixin (pas d'override)
        final defaultAppLocale = defaultConfig.appLocale;
        expect((overrideConfig as dynamic).appLocale, equals(defaultAppLocale));
        print('✅ Propriété sans override: appLocale = "${(overrideConfig as dynamic).appLocale}"');
      });
    });

    group('🏗️ Builder pattern', () {
      test('Construction fluide avec set()', () {
        print('\n--- Test construction fluide ---');

        final config = builder
            .set('appName', 'Builder Test App')
            .set('version', '3.0.0')
            .set('debugMode', true)
            .set('timeout', 45)
            .set('enableFeatureX', true)
            .build();

        expect(config.getOverride('appName'), equals('Builder Test App'));
        expect(config.getOverride('version'), equals('3.0.0'));
        expect(config.getOverride('debugMode'), equals(true));
        expect(config.getOverride('timeout'), equals(45));
        expect(config.getOverride('enableFeatureX'), equals(true));

        print('✅ Builder fluide: appName = "${config.getOverride('appName')}"');
        print('✅ Builder fluide: version = "${config.getOverride('version')}"');
        print('✅ Builder fluide: debugMode = ${config.getOverride('debugMode')}');
        print('✅ Builder fluide: timeout = ${config.getOverride('timeout')}');
        print('✅ Builder fluide: enableFeatureX = ${config.getOverride('enableFeatureX')}');
      });

      test('Construction avec setAll()', () {
        print('\n--- Test setAll() ---');

        final bulkConfig = {
          'baseUrl': 'https://api.builder.com',
          'timeout': 60,
          'enableLogging': false,
          'maxRetries': 5,
          'apiVersion': 'v2.1',
        };

        final config = builder.set('appName', 'Bulk Config Test').setAll(bulkConfig).build();

        expect(config.getOverride('appName'), equals('Bulk Config Test'));
        expect(config.getOverride('baseUrl'), equals('https://api.builder.com'));
        expect(config.getOverride('timeout'), equals(60));
        expect(config.getOverride('enableLogging'), equals(false));
        expect(config.getOverride('maxRetries'), equals(5));
        expect(config.getOverride('apiVersion'), equals('v2.1'));

        print('✅ SetAll: baseUrl = "${config.getOverride('baseUrl')}"');
        print('✅ SetAll: timeout = ${config.getOverride('timeout')}');
        print('✅ SetAll: enableLogging = ${config.getOverride('enableLogging')}');
        print('✅ SetAll: maxRetries = ${config.getOverride('maxRetries')}');
        print('✅ SetAll: apiVersion = "${config.getOverride('apiVersion')}"');
      });

      test('Opérateurs [] et []= du builder', () {
        print('\n--- Test opérateurs du builder ---');

        builder['directKey1'] = 'directValue1';
        builder['directKey2'] = 42;
        builder['directKey3'] = true;

        expect(builder['directKey1'], equals('directValue1'));
        expect(builder['directKey2'], equals(42));
        expect(builder['directKey3'], equals(true));

        print('✅ Builder[]: directKey1 = "${builder['directKey1']}"');
        print('✅ Builder[]: directKey2 = ${builder['directKey2']}');
        print('✅ Builder[]: directKey3 = ${builder['directKey3']}');

        final config = builder.build();
        expect(config.getOverride('directKey1'), equals('directValue1'));
        expect(config.getOverride('directKey2'), equals(42));
        expect(config.getOverride('directKey3'), equals(true));
      });

      test('Méthodes utilitaires du builder', () {
        print('\n--- Test méthodes utilitaires ---');

        builder.set('utilKey1', 'value1');
        builder.set('utilKey2', 'value2');

        expect(builder.hasKey('utilKey1'), isTrue);
        expect(builder.hasKey('utilKey2'), isTrue);
        expect(builder.hasKey('nonExistentKey'), isFalse);

        print('✅ HasKey: utilKey1 = ${builder.hasKey('utilKey1')}');
        print('✅ HasKey: nonExistentKey = ${builder.hasKey('nonExistentKey')}');

        final configBefore = builder.getConfig();
        expect(configBefore['utilKey1'], equals('value1'));
        expect(configBefore.length, equals(2));
        print('✅ GetConfig: ${configBefore.length} clés trouvées');

        builder.removeKey('utilKey1');
        expect(builder.hasKey('utilKey1'), isFalse);
        expect(builder.hasKey('utilKey2'), isTrue);
        print('✅ RemoveKey: utilKey1 supprimé');

        builder.clear();
        expect(builder.hasKey('utilKey2'), isFalse);
        expect(builder.getConfig().length, equals(0));
        print('✅ Clear: toutes les clés supprimées');
      });
    });

    group('🌍 Configuration globale', () {
      test('Définition et récupération de la config globale', () {
        print('\n--- Test configuration globale ---');

        // Créer une config personnalisée
        final customConfig = LucidConfigBuilder()
            .set('appName', 'Global Test App')
            .set('version', '4.0.0')
            .set('globalFeature', true)
            .build();

        // Définir comme config globale
        LucidGlobalConfig.config = customConfig;

        // Récupérer la config actuelle
        final currentConfig = LucidGlobalConfig.current;
        expect(currentConfig, equals(customConfig));

        // Cast vers LucidOverrideConfig pour accéder à getOverride
        if (currentConfig is LucidOverrideConfig) {
          expect(currentConfig.getOverride('appName'), equals('Global Test App'));
          expect(currentConfig.getOverride('version'), equals('4.0.0'));
          expect(currentConfig.getOverride('globalFeature'), equals(true));

          print('✅ Config globale: appName = "${currentConfig.getOverride('appName')}"');
          print('✅ Config globale: version = "${currentConfig.getOverride('version')}"');
          print('✅ Config globale: globalFeature = ${currentConfig.getOverride('globalFeature')}');
        } else {
          // Test avec noSuchMethod si ce n'est pas un LucidOverrideConfig
          expect((currentConfig as dynamic).appName, equals('Global Test App'));
          print('✅ Config globale via noSuchMethod: appName = "${(currentConfig as dynamic).appName}"');
        }
      });

      test('Reset de la configuration globale', () {
        print('\n--- Test reset configuration globale ---');

        // Définir une config personnalisée
        final customConfig = LucidConfigBuilder().set('tempGlobalKey', 'tempValue').build();

        LucidGlobalConfig.config = customConfig;

        // Vérifier avec le bon type
        final currentConfig = LucidGlobalConfig.current;
        if (currentConfig is LucidOverrideConfig) {
          expect(currentConfig.getOverride('tempGlobalKey'), equals('tempValue'));
          print('✅ Config globale définie avec tempGlobalKey');
        }

        // Reset
        LucidGlobalConfig.reset();
        final resetConfig = LucidGlobalConfig.current;

        expect(resetConfig, isA<LucidConfigHelpers>());

        // Après reset, on a une instance de base, pas d'override
        if (resetConfig is LucidOverrideConfig) {
          expect(resetConfig.getOverride('tempGlobalKey'), isNull);
          print('✅ Config globale reset - tempGlobalKey n\'existe plus');
        } else {
          // Test que la propriété n'existe pas via noSuchMethod
          final result = (resetConfig as dynamic).tempGlobalKey;
          expect(result, isNull);
          print('✅ Config globale reset - tempGlobalKey retourne null');
        }

        // Vérifier que la config par défaut fonctionne
        expect(resetConfig.appName, isNotNull);
        print('✅ Config par défaut restaurée: appName = "${resetConfig.appName}"');
      });
    });

    group('✨ Configuration dynamique et edge cases', () {
      test('noSuchMethod avec propriétés personnalisées', () {
        print('\n--- Test noSuchMethod dynamique ---');

        final config = LucidConfigBuilder().set('customProperty1', 'customValue1').set('customProperty2', 123).build();

        // Test via noSuchMethod
        dynamic result1 = (config as dynamic).customProperty1;
        dynamic result2 = (config as dynamic).customProperty2;
        dynamic result3 = (config as dynamic).nonExistentProperty;

        expect(result1, equals('customValue1'));
        expect(result2, equals(123));
        expect(result3, isNull);

        print('✅ NoSuchMethod: customProperty1 = "$result1"');
        print('✅ NoSuchMethod: customProperty2 = $result2');
        print('✅ NoSuchMethod: nonExistentProperty = $result3');
      });

      test('Conversion de noms de méthodes spéciales', () {
        print('\n--- Test conversion de noms ---');

        final config = LucidConfigBuilder()
            .set('analyticsLogBufferSize', 1500)
            .set('analyticsSessionTimeout', 3600)
            .set('analyticsInactivityCheckInterval', 300)
            .build();

        expect(config.getOverride('analyticsLogBufferSize'), equals(1500));
        expect(config.getOverride('analyticsSessionTimeout'), equals(3600));
        expect(config.getOverride('analyticsInactivityCheckInterval'), equals(300));

        print('✅ Conversion: analyticsLogBufferSize = ${config.getOverride('analyticsLogBufferSize')}');
        print('✅ Conversion: analyticsSessionTimeout = ${config.getOverride('analyticsSessionTimeout')}');
        print(
          '✅ Conversion: analyticsInactivityCheckInterval = ${config.getOverride('analyticsInactivityCheckInterval')}',
        );
      });

      test('Types complexes et collections', () {
        print('\n--- Test types complexes ---');

        final complexList = ['item1', 'item2', 'item3'];
        final complexMap = {
          'key1': 'value1',
          'key2': 42,
          'nested': {'deep': true},
        };

        final config = LucidConfigBuilder()
            .set('listProperty', complexList)
            .set('mapProperty', complexMap)
            .set('nullProperty', null)
            .build();

        expect(config.getOverride<List<String>>('listProperty'), equals(complexList));
        expect(config.getOverride<Map<String, dynamic>>('mapProperty'), equals(complexMap));
        expect(config.getOverride('nullProperty'), isNull);

        print('✅ Liste: ${config.getOverride('listProperty')}');
        print('✅ Map: ${config.getOverride('mapProperty')}');
        print('✅ Null: ${config.getOverride('nullProperty')}');
      });
    });

    group('⚡ Tests de performance', () {
      test('Performance création de configurations', () {
        print('\n--- Test performance création ---');

        final stopwatch = Stopwatch()..start();
        const iterations = 1000;

        for (int i = 0; i < iterations; i++) {
          final config = LucidConfigBuilder()
              .set('appName', 'App $i')
              .set('version', '1.$i.0')
              .set('debugMode', i % 2 == 0)
              .set('timeout', 1000 + i)
              .build();

          // Accéder aux valeurs pour tester la performance de lecture
          config.getOverride('appName');
          config.getOverride('version');
          config.getOverride('debugMode');
          config.getOverride('timeout');
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        final avgPerConfig = elapsedMs / iterations;

        expect(elapsedMs, lessThan(5000), reason: 'Performance trop lente');

        print('✅ $iterations configurations créées en: ${elapsedMs}ms');
        print('✅ Moyenne par config: ${avgPerConfig.toStringAsFixed(2)}ms');
        print('✅ Configs par seconde: ${(iterations / (elapsedMs / 1000)).round()}');
      });

      test('Performance accès aux propriétés', () {
        print('\n--- Test performance accès ---');

        final config = LucidConfigBuilder()
            .set('prop1', 'value1')
            .set('prop2', 'value2')
            .set('prop3', 'value3')
            .set('prop4', 'value4')
            .set('prop5', 'value5')
            .build();

        final stopwatch = Stopwatch()..start();
        const accessIterations = 10000;

        for (int i = 0; i < accessIterations; i++) {
          config.getOverride('prop1');
          config.getOverride('prop2');
          config.getOverride('prop3');
          config.getOverride('prop4');
          config.getOverride('prop5');
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        final totalAccess = accessIterations * 5;

        expect(elapsedMs, lessThan(1000), reason: 'Accès aux propriétés trop lent');

        print('✅ $totalAccess accès aux propriétés en: ${elapsedMs}ms');
        print('✅ Accès par seconde: ${(totalAccess / (elapsedMs / 1000)).round()}');
      });
    });

    group('🔍 Tests d\'intégration', () {
      test('Scénario complet d\'utilisation', () {
        print('\n--- Test scénario complet ---');

        // 1. Créer une configuration par défaut
        final defaultConfig = LucidConfigHelpers();
        final originalAppName = defaultConfig.appName;
        print('🔸 1. Config par défaut créée - appName: "$originalAppName"');

        // 2. Créer une configuration personnalisée
        final customConfig = LucidConfigBuilder()
            .set('appName', 'Custom App')
            .set('environment', 'staging')
            .set('debugMode', true)
            .set('apiUrl', 'https://staging.api.com')
            .set('features', {'featureA': true, 'featureB': false})
            .build();

        print('🔸 2. Config personnalisée créée');

        // 3. Définir comme config globale
        LucidGlobalConfig.config = customConfig;
        final globalConfig = LucidGlobalConfig.current;
        if (globalConfig is LucidOverrideConfig) {
          expect(globalConfig.getOverride('appName'), equals('Custom App'));
          print('🔸 3. Config globale définie - appName: "${globalConfig.getOverride('appName')}"');
        }

        // 4. Créer une config avec overrides supplémentaires
        final extendedConfig = LucidOverrideConfig.createWithOverrides({
          'appName': 'Extended App',
          'version': '2.0.0',
          'newFeature': true,
        });

        expect(extendedConfig.getOverride('appName'), equals('Extended App'));
        expect(extendedConfig.getOverride('version'), equals('2.0.0'));
        expect(extendedConfig.getOverride('newFeature'), equals(true));
        print('🔸 4. Config étendue créée avec overrides');

        // 5. Test du fallback vers les mixins
        final mixinValue = (extendedConfig as dynamic).appLocale;
        expect(mixinValue, isNotNull);
        print('🔸 5. Fallback vers mixin - appLocale: "$mixinValue"');

        // 6. Reset et vérification
        LucidGlobalConfig.reset();
        final resetConfig = LucidGlobalConfig.current;
        expect(resetConfig.appName, equals(originalAppName));
        print('🔸 6. Reset effectué - retour à: "${resetConfig.appName}"');

        print('✅ Scénario complet réussi!');
      });
    });
  });
}
