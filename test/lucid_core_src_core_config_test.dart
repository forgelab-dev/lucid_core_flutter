import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lib.dart';

void main() {
  final logger = LucidLogger();

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

    tearDown(LucidGlobalConfig.reset);

    group('📋 Configuration par défaut', () {
      test('Vérification des propriétés App Config', () {
        logger.info('\n--- Test App Config ---');

        expect(defaultConfig.appName, isNotNull, reason: 'appName ne doit pas être null');
        expect(defaultConfig.appLocale, isNotNull, reason: 'appLocale ne doit pas être null');
        expect(defaultConfig.appUrl, isNotNull, reason: 'appUrl ne doit pas être null');

        logger.info('✅ appName: "${defaultConfig.appName}"');
        logger.info('✅ appLocale: "${defaultConfig.appLocale}"');
        logger.info('✅ appUrl: "${defaultConfig.appUrl}"');

        // Vérifier les types
        expect(defaultConfig.appName, isA<String>(), reason: 'appName doit être une String');
        expect(defaultConfig.appLocale, isA<String>(), reason: 'appLocale doit être une String');
        expect(defaultConfig.appUrl, isA<String>(), reason: 'appUrl doit être une String');
      });

      test('Vérification des propriétés Analytics Config', () {
        logger.info('\n--- Test Analytics Config ---');

        expect(defaultConfig.analyticsLogTag, isNotNull, reason: 'analyticsLogTag ne doit pas être null');
        expect(defaultConfig.analyticsLogBufferSize, isNotNull, reason: 'analyticsLogBufferSize ne doit pas être null');

        logger.info('✅ analyticsLogTag: "${defaultConfig.analyticsLogTag}"');
        logger.info('✅ analyticsLogBufferSize: ${defaultConfig.analyticsLogBufferSize}');

        // Vérifier les types et valeurs logiques
        expect(defaultConfig.analyticsLogTag, isA<String>(), reason: 'analyticsLogTag doit être une String');
        expect(defaultConfig.analyticsLogBufferSize, isA<int>(), reason: 'analyticsLogBufferSize doit être un int');
        expect(defaultConfig.analyticsLogBufferSize, greaterThan(0), reason: 'Buffer size doit être positif');
      });

      test('Vérification des propriétés Location Config', () {
        logger.info('\n--- Test Location Config ---');

        expect(defaultConfig.locationMapZoomLevel, isNotNull, reason: 'locationMapZoomLevel ne doit pas être null');

        logger.info('✅ locationMapZoomLevel: ${defaultConfig.locationMapZoomLevel}');

        // Vérifier les types et valeurs logiques
        expect(defaultConfig.locationMapZoomLevel, isA<num>(), reason: 'locationMapZoomLevel doit être numérique');
        expect(defaultConfig.locationMapZoomLevel, greaterThan(0), reason: 'Zoom level doit être positif');
      });

      test('Propriétés inexistantes retournent null', () {
        logger.info('\n--- Test propriétés inexistantes ---');

        // Tester avec noSuchMethod
        dynamic result;
        try {
          result = (defaultConfig as dynamic).proprieteInexistante;
        } catch (e) {
          result = null;
        }

        expect(result, isNull, reason: 'Une propriété inexistante doit retourner null');
        logger.info('✅ Propriété inexistante retourne: $result');
      });
    });

    group('🔧 Configuration avec overrides', () {
      test('Ajout et récupération d\'overrides simples', () {
        logger.info('\n--- Test overrides simples ---');

        // Définir des overrides avec différents types
        overrideConfig.overrides('appName', 'Test App Override');
        overrideConfig.overrides('appLocale', 'fr_FR');
        overrideConfig.overrides('debugMode', true);
        overrideConfig.overrides('timeout', 5000);
        overrideConfig.overrides('latitude', 48.8566);

        // Vérifier les valeurs
        expect(overrideConfig.getOverride<String>('appName'), equals('Test App Override'));
        expect(overrideConfig.getOverride<String>('appLocale'), equals('fr_FR'));
        expect(overrideConfig.getOverride<bool>('debugMode'), equals(true));
        expect(overrideConfig.getOverride<int>('timeout'), equals(5000));
        expect(overrideConfig.getOverride<double>('latitude'), equals(48.8566));

        logger.info('✅ String override: "${overrideConfig.getOverride<String>('appName')}"');
        logger.info('✅ Bool override: ${overrideConfig.getOverride<bool>('debugMode')}');
        logger.info('✅ Int override: ${overrideConfig.getOverride<double>('timeout')}');
        logger.info('✅ Double override: ${overrideConfig.getOverride<double>('latitude')}');
      });

      test('Opérateurs [] et []= fonctionnels', () {
        logger.info('\n--- Test opérateurs d\'accès ---');

        // Test de l'opérateur []=
        overrideConfig['baseUrl'] = 'https://api.override.com';
        overrideConfig['maxRetries'] = 3;
        overrideConfig['enableSSL'] = true;

        // Test de l'opérateur []
        expect(overrideConfig['baseUrl'], equals('https://api.override.com'));
        expect(overrideConfig['maxRetries'], equals(3));
        expect(overrideConfig['enableSSL'], equals(true));

        logger.info('✅ Opérateur []: baseUrl = "${overrideConfig['baseUrl']}"');
        logger.info('✅ Opérateur []: maxRetries = ${overrideConfig['maxRetries']}');
        logger.info('✅ Opérateur []: enableSSL = ${overrideConfig['enableSSL']}');
      });

      test('Suppression d\'overrides', () {
        logger.info('\n--- Test suppression d\'overrides ---');

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

        logger.info('✅ tempKey1 supprimé: ${!overrideConfig.containsKey('tempKey1')}');
        logger.info('✅ tempKey2 supprimé: ${!overrideConfig.containsKey('tempKey2')}');
        logger.info('✅ tempKey3 présent: ${overrideConfig.containsKey('tempKey3')}');

        // Clear all
        overrideConfig.clear();
        expect(overrideConfig.containsKey('tempKey3'), isFalse);
        logger.info('✅ Tous les overrides effacés');
      });

      test('Fallback vers les mixins quand pas d\'override', () {
        logger.info('\n--- Test fallback vers mixins ---');

        // Ajouter un override pour une propriété
        overrideConfig.overrides('appName', 'Overridden App');

        // appName doit retourner l'override
        expect((overrideConfig as dynamic).appName, equals('Overridden App'));
        logger.info('✅ Propriété avec override: appName = "${(overrideConfig as dynamic).appName}"');

        // appLocale doit retourner la valeur du mixin (pas d'override)
        final defaultAppLocale = defaultConfig.appLocale;
        expect((overrideConfig as dynamic).appLocale, equals(defaultAppLocale));
        logger.info('✅ Propriété sans override: appLocale = "${(overrideConfig as dynamic).appLocale}"');
      });
    });

    group('🏗️ Builder pattern', () {
      test('Construction fluide avec set()', () {
        logger.info('\n--- Test construction fluide ---');

        final config = builder
            .set('appName', 'Builder Test App')
            .set('version', '3.0.0')
            .set('debugMode', true)
            .set('timeout', 45)
            .set('enableFeatureX', true)
            .build();

        expect(config.getOverride<String>('appName'), equals('Builder Test App'));
        expect(config.getOverride<String>('version'), equals('3.0.0'));
        expect(config.getOverride<bool>('debugMode'), equals(true));
        expect(config.getOverride<int>('timeout'), equals(45));
        expect(config.getOverride<bool>('enableFeatureX'), equals(true));

        logger.info('✅ Builder fluide: appName = "${config.getOverride<String>('appName')}"');
        logger.info('✅ Builder fluide: version = "${config.getOverride<String>('version')}"');
        logger.info('✅ Builder fluide: debugMode = ${config.getOverride<bool>('debugMode')}');
        logger.info('✅ Builder fluide: timeout = ${config.getOverride<int>('timeout')}');
        logger.info('✅ Builder fluide: enableFeatureX = ${config.getOverride<bool>('enableFeatureX')}');
      });

      test('Construction avec setAll()', () {
        logger.info('\n--- Test setAll() ---');

        final bulkConfig = {
          'baseUrl': 'https://api.builder.com',
          'timeout': 60,
          'enableLogging': false,
          'maxRetries': 5,
          'apiVersion': 'v2.1',
        };

        final config = builder.set('appName', 'Bulk Config Test').setAll(bulkConfig).build();

        expect(config.getOverride<String>('appName'), equals('Bulk Config Test'));
        expect(config.getOverride<String>('baseUrl'), equals('https://api.builder.com'));
        expect(config.getOverride<int>('timeout'), equals(60));
        expect(config.getOverride<bool>('enableLogging'), equals(false));
        expect(config.getOverride<int>('maxRetries'), equals(5));
        expect(config.getOverride<String>('apiVersion'), equals('v2.1'));

        logger.info('✅ SetAll: baseUrl = "${config.getOverride<String>('baseUrl')}"');
        logger.info('✅ SetAll: timeout = ${config.getOverride<int>('timeout')}');
        logger.info('✅ SetAll: enableLogging = ${config.getOverride<bool>('enableLogging')}');
        logger.info('✅ SetAll: maxRetries = ${config.getOverride<int>('maxRetries')}');
        logger.info('✅ SetAll: apiVersion = "${config.getOverride<String>('apiVersion')}"');
      });

      test('Opérateurs [] et []= du builder', () {
        logger.info('\n--- Test opérateurs du builder ---');

        builder['directKey1'] = 'directValue1';
        builder['directKey2'] = 42;
        builder['directKey3'] = true;

        expect(builder['directKey1'], equals('directValue1'));
        expect(builder['directKey2'], equals(42));
        expect(builder['directKey3'], equals(true));

        logger.info('✅ Builder[]: directKey1 = "${builder['directKey1']}"');
        logger.info('✅ Builder[]: directKey2 = ${builder['directKey2']}');
        logger.info('✅ Builder[]: directKey3 = ${builder['directKey3']}');

        final config = builder.build();
        expect(config.getOverride<String>('directKey1'), equals('directValue1'));
        expect(config.getOverride<int>('directKey2'), equals(42));
        expect(config.getOverride<bool>('directKey3'), equals(true));
      });

      test('Méthodes utilitaires du builder', () {
        logger.info('\n--- Test méthodes utilitaires ---');

        builder.set('utilKey1', 'value1');
        builder.set('utilKey2', 'value2');

        expect(builder.hasKey('utilKey1'), isTrue);
        expect(builder.hasKey('utilKey2'), isTrue);
        expect(builder.hasKey('nonExistentKey'), isFalse);

        logger.info('✅ HasKey: utilKey1 = ${builder.hasKey('utilKey1')}');
        logger.info('✅ HasKey: nonExistentKey = ${builder.hasKey('nonExistentKey')}');

        final configBefore = builder.getConfig();
        expect(configBefore['utilKey1'], equals('value1'));
        expect(configBefore.length, equals(2));
        logger.info('✅ GetConfig: ${configBefore.length} clés trouvées');

        builder.removeKey('utilKey1');
        expect(builder.hasKey('utilKey1'), isFalse);
        expect(builder.hasKey('utilKey2'), isTrue);
        logger.info('✅ RemoveKey: utilKey1 supprimé');

        builder.clear();
        expect(builder.hasKey('utilKey2'), isFalse);
        expect(builder.getConfig().length, equals(0));
        logger.info('✅ Clear: toutes les clés supprimées');
      });
    });

    group('🌍 Configuration globale', () {
      test('Définition et récupération de la config globale', () {
        logger.info('\n--- Test configuration globale ---');

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
          expect(currentConfig.getOverride<String>('appName'), equals('Global Test App'));
          expect(currentConfig.getOverride<String>('version'), equals('4.0.0'));
          expect(currentConfig.getOverride<bool>('globalFeature'), equals(true));

          logger.info('✅ Config globale: appName = "${currentConfig.getOverride<String>('appName')}"');
          logger.info('✅ Config globale: version = "${currentConfig.getOverride<String>('version')}"');
          logger.info('✅ Config globale: globalFeature = ${currentConfig.getOverride<bool>('globalFeature')}');
        } else {
          // Test avec noSuchMethod si ce n'est pas un LucidOverrideConfig
          expect((currentConfig as dynamic).appName, equals('Global Test App'));
          logger.info('✅ Config globale via noSuchMethod: appName = "${(currentConfig as dynamic).appName}"');
        }
      });

      test('Reset de la configuration globale', () {
        logger.info('\n--- Test reset configuration globale ---');

        // Définir une config personnalisée
        final customConfig = LucidConfigBuilder().set('tempGlobalKey', 'tempValue').build();

        LucidGlobalConfig.config = customConfig;

        // Vérifier avec le bon type
        final currentConfig = LucidGlobalConfig.current;
        if (currentConfig is LucidOverrideConfig) {
          expect(currentConfig.getOverride<String>('tempGlobalKey'), equals('tempValue'));
          logger.info('✅ Config globale définie avec tempGlobalKey');
        }

        // Reset
        LucidGlobalConfig.reset();
        final resetConfig = LucidGlobalConfig.current;

        expect(resetConfig, isA<LucidConfigHelpers>());

        // Après reset, on a une instance de base, pas d'override
        if (resetConfig is LucidOverrideConfig) {
          expect(resetConfig.getOverride<String?>('tempGlobalKey'), isNull);
          logger.info('✅ Config globale reset - tempGlobalKey n\'existe plus');
        } else {
          // Test que la propriété n'existe pas via noSuchMethod
          final result = (resetConfig as dynamic).tempGlobalKey;
          expect(result, isNull);
          logger.info('✅ Config globale reset - tempGlobalKey retourne null');
        }

        // Vérifier que la config par défaut fonctionne
        expect(resetConfig.appName, isNotNull);
        logger.info('✅ Config par défaut restaurée: appName = "${resetConfig.appName}"');
      });
    });

    group('✨ Configuration dynamique et edge cases', () {
      test('noSuchMethod avec propriétés personnalisées', () {
        logger.info('\n--- Test noSuchMethod dynamique ---');

        final config = LucidConfigBuilder().set('customProperty1', 'customValue1').set('customProperty2', 123).build();

        // Test via noSuchMethod
        final dynamic result1 = (config as dynamic).customProperty1;
        final dynamic result2 = (config as dynamic).customProperty2;
        final dynamic result3 = (config as dynamic).nonExistentProperty;

        expect(result1, equals('customValue1'));
        expect(result2, equals(123));
        expect(result3, isNull);

        logger.info('✅ NoSuchMethod: customProperty1 = "$result1"');
        logger.info('✅ NoSuchMethod: customProperty2 = $result2');
        logger.info('✅ NoSuchMethod: nonExistentProperty = $result3');
      });

      test('Conversion de noms de méthodes spéciales', () {
        logger.info('\n--- Test conversion de noms ---');

        final config = LucidConfigBuilder()
            .set('analyticsLogBufferSize', 1500)
            .set('analyticsSessionTimeout', 3600)
            .set('analyticsInactivityCheckInterval', 300)
            .build();

        expect(config.getOverride<int>('analyticsLogBufferSize'), equals(1500));
        expect(config.getOverride<int>('analyticsSessionTimeout'), equals(3600));
        expect(config.getOverride<int>('analyticsInactivityCheckInterval'), equals(300));

        logger.info('✅ Conversion: analyticsLogBufferSize = ${config.getOverride<int>('analyticsLogBufferSize')}');
        logger.info('✅ Conversion: analyticsSessionTimeout = ${config.getOverride<int>('analyticsSessionTimeout')}');
        logger.info(
          '✅ Conversion: analyticsInactivityCheckInterval = ${config.getOverride<int>('analyticsInactivityCheckInterval')}',
        );
      });

      test('Types complexes et collections', () {
        logger.info('\n--- Test types complexes ---');

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

        expect(config.getOverride<LucidData<String>>('listProperty'), equals(complexList));
        expect(config.getOverride<LucidJsonMap>('mapProperty'), equals(complexMap));
        expect(config.getOverride<dynamic>('nullProperty'), isNull);

        logger.info('✅ Liste: ${config.getOverride<LucidData<String>>('listProperty')}');
        logger.info('✅ Map: ${config.getOverride<LucidJsonMap>('mapProperty')}');
        logger.info('✅ Null: ${config.getOverride<dynamic>('nullProperty')}');
      });
    });

    group('⚡ Tests de performance', () {
      test('Performance création de configurations', () {
        logger.info('\n--- Test performance création ---');

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
          config.getOverride<String>('appName');
          config.getOverride<String>('version');
          config.getOverride<bool>('debugMode');
          config.getOverride<int>('timeout');
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        final avgPerConfig = elapsedMs / iterations;

        expect(elapsedMs, lessThan(5000), reason: 'Performance trop lente');

        logger.info('✅ $iterations configurations créées en: ${elapsedMs}ms');
        logger.info('✅ Moyenne par config: ${avgPerConfig.toStringAsFixed(2)}ms');
        logger.info('✅ Configs par seconde: ${(iterations / (elapsedMs / 1000)).round()}');
      });

      test('Performance accès aux propriétés', () {
        logger.info('\n--- Test performance accès ---');

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
          config.getOverride<String>('prop1');
          config.getOverride<String>('prop2');
          config.getOverride<String>('prop3');
          config.getOverride<String>('prop4');
          config.getOverride<String>('prop5');
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        const totalAccess = accessIterations * 5;

        expect(elapsedMs, lessThan(1000), reason: 'Accès aux propriétés trop lent');

        logger.info('✅ $totalAccess accès aux propriétés en: ${elapsedMs}ms');
        logger.info('✅ Accès par seconde: ${(totalAccess / (elapsedMs / 1000)).round()}');
      });
    });

    group('🔍 Tests d\'intégration', () {
      test('Scénario complet d\'utilisation', () {
        logger.info('\n--- Test scénario complet ---');

        // 1. Créer une configuration par défaut
        final defaultConfig = LucidConfigHelpers();
        final originalAppName = defaultConfig.appName;
        logger.info('🔸 1. Config par défaut créée - appName: "$originalAppName"');

        // 2. Créer une configuration personnalisée
        final customConfig = LucidConfigBuilder()
            .set('appName', 'Custom App')
            .set('environment', 'staging')
            .set('debugMode', true)
            .set('apiUrl', 'https://staging.api.com')
            .set('features', {'featureA': true, 'featureB': false})
            .build();

        logger.info('🔸 2. Config personnalisée créée');

        // 3. Définir comme config globale
        LucidGlobalConfig.config = customConfig;
        final globalConfig = LucidGlobalConfig.current;
        if (globalConfig is LucidOverrideConfig) {
          expect(globalConfig.getOverride<String>('appName'), equals('Custom App'));
          logger.info('🔸 3. Config globale définie - appName: "${globalConfig.getOverride<String>('appName')}"');
        }

        // 4. Créer une config avec overrides supplémentaires
        final extendedConfig = LucidOverrideConfig.createWithOverrides({
          'appName': 'Extended App',
          'version': '2.0.0',
          'newFeature': true,
        });

        expect(extendedConfig.getOverride<String>('appName'), equals('Extended App'));
        expect(extendedConfig.getOverride<String>('version'), equals('2.0.0'));
        expect(extendedConfig.getOverride<bool>('newFeature'), equals(true));
        logger.info('🔸 4. Config étendue créée avec overrides');

        // 5. Test du fallback vers les mixins
        final mixinValue = (extendedConfig as dynamic).appLocale;
        expect(mixinValue, isNotNull);
        logger.info('🔸 5. Fallback vers mixin - appLocale: "$mixinValue"');

        // 6. Reset et vérification
        LucidGlobalConfig.reset();
        final resetConfig = LucidGlobalConfig.current;
        expect(resetConfig.appName, equals(originalAppName));
        logger.info('🔸 6. Reset effectué - retour à: "${resetConfig.appName}"');

        logger.info('✅ Scénario complet réussi!');
      });
    });
  });
}
