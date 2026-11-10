import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lib.dart';

/// Une liste de lignes glissables : supprimer (vers la droite) retire la ligne,
/// modifier (vers la gauche) la laisse en place.
class _Host extends StatefulWidget {
  const _Host({required this.log});

  final List<String> log;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final List<String> _items = ['Transport', 'Alimentation'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: LucidThemes.defaultLight.toThemeData(),
      home: Scaffold(
        body: ListView(
          children: [
            for (final item in _items)
              LucidSwipeActions(
                key: ValueKey(item),
                startAction: LucidSwipeAction(
                  icon: Icons.delete_outline,
                  label: 'Supprimer',
                  removesItem: true,
                  onTriggered: () {
                    widget.log.add('supprimer $item');
                    // Comme une base de données : la liste se met à jour plus tard.
                    Future<void>.delayed(const Duration(milliseconds: 50), () {
                      if (mounted) setState(() => _items.remove(item));
                    });
                  },
                ),
                endAction: LucidSwipeAction(
                  icon: Icons.edit_outlined,
                  label: 'Modifier',
                  onTriggered: () => widget.log.add('modifier $item'),
                ),
                child: ListTile(title: Text(item)),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('LucidSwipeActions', () {
    testWidgets(
      'vers la droite : l’action qui retire la ligne, sans attendre la liste',
      (tester) async {
        final log = <String>[];
        await tester.pumpWidget(_Host(log: log));

        await tester.fling(find.text('Transport'), const Offset(400, 0), 1000);
        await tester.pumpAndSettle();
        expect(log, ['supprimer Transport']);
        expect(find.text('Transport'), findsNothing);
        expect(
          tester.takeException(),
          isNull,
          reason: 'la ligne glissée quitte l’arbre aussitôt',
        );
        expect(find.text('Alimentation'), findsOneWidget);

        // La liste rattrape ensuite la suppression.
        await tester.pump(const Duration(milliseconds: 60));
        expect(find.text('Transport'), findsNothing);
      },
    );

    testWidgets('vers la gauche : l’action qui laisse la ligne en place', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(_Host(log: log));

      await tester.fling(find.text('Transport'), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(log, ['modifier Transport']);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('un petit glissement ne déclenche rien', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_Host(log: log));

      await tester.drag(find.text('Transport'), const Offset(40, 0));
      await tester.pumpAndSettle();
      expect(log, isEmpty);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets(
      'l’indication de l’action apparaît sous la ligne pendant le geste',
      (tester) async {
        await tester.pumpWidget(const _Host(log: []));

        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Transport')),
        );
        await gesture.moveBy(const Offset(30, 0));
        await gesture.moveBy(const Offset(120, 0));
        await tester.pump();
        expect(find.text('Supprimer'), findsOneWidget);
        expect(find.text('Modifier'), findsNothing);
        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'sans glisser : les actions restent accessibles au lecteur d’écran',
      (tester) async {
        final handle = tester.ensureSemantics();
        final log = <String>[];
        await tester.pumpWidget(_Host(log: log));

        final semantics = tester.getSemantics(find.text('Alimentation'));
        final owner = semantics.owner!;
        final ids = semantics.getSemanticsData().customSemanticsActionIds!;
        expect(ids, hasLength(2));
        for (final id in ids) {
          owner.performAction(semantics.id, SemanticsAction.customAction, id);
        }
        await tester.pumpAndSettle();
        expect(
          log,
          unorderedEquals(['supprimer Alimentation', 'modifier Alimentation']),
        );
        await tester.pump(const Duration(milliseconds: 60));
        handle.dispose();
      },
    );

    testWidgets('un seul côté : l’autre sens ne bouge pas', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LucidSwipeActions(
              endAction: LucidSwipeAction(
                icon: Icons.edit,
                label: 'Modifier',
                onTriggered: () => log.add('modifier'),
              ),
              child: const ListTile(title: Text('Ligne')),
            ),
          ),
        ),
      );

      await tester.fling(find.text('Ligne'), const Offset(400, 0), 1000);
      await tester.pumpAndSettle();
      expect(log, isEmpty);
      expect(find.text('Ligne'), findsOneWidget);
    });
  });
}
