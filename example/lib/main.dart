import 'package:flutter/material.dart';
import 'package:lucid_core_flutter/lucid_core_flutter.dart';

import 'demo_page.dart';
import 'demo_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cache en mémoire uniquement : la démonstration doit tourner sur les six
  // plateformes sans dépendre du trousseau système ni du disque. Une vraie
  // application garde les valeurs par défaut (stockage sécurisé, persistance).
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

  runApp(const LucidExampleApp());
}

class LucidExampleApp extends StatelessWidget {
  const LucidExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lucid_core_flutter · démonstration',
      debugShowCheckedModeBanner: false,
      theme: DemoTokens.theme(),
      home: const DemoPage(),
    );
  }
}
