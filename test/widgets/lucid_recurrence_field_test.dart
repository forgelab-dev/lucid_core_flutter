import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lib.dart';
import 'package:material_ui/material_ui.dart';

/// Un hôte en français, avec un état pour suivre les changements.
class _Host extends StatefulWidget {
  const _Host({
    super.key,
    required this.initial,
    this.choiceBuilder,
    this.withL10n = true,
    this.showStart = true,
    this.showUntil = true,
  });

  final LucidRecurrence initial;
  final bool showStart;
  final bool showUntil;
  final LucidChoiceBuilder? choiceBuilder;
  final bool withL10n;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late LucidRecurrence rule = widget.initial;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: const Locale('fr'),
    supportedLocales: const [Locale('fr'), Locale('en')],
    localizationsDelegates: [
      if (widget.withL10n) LucidL10n.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(
      body: LucidRecurrenceField(
        value: rule,
        choiceBuilder: widget.choiceBuilder,
        showStart: widget.showStart,
        showUntil: widget.showUntil,
        onChanged: (next) => setState(() => rule = next),
      ),
    ),
  );
}

LucidRecurrence _ruleOf(WidgetTester tester) =>
    tester.state<_HostState>(find.byType(_Host)).rule;

final _fifth = LucidRecurrence(
  unit: LucidRecurrenceUnit.month,
  start: DateTime(2026, 11, 5),
);

void main() {
  testWidgets('dit la règle en clair, et la change d’un geste', (tester) async {
    await tester.pumpWidget(_Host(initial: _fifth));
    await tester.pumpAndSettle();

    expect(find.text('Le 5 de chaque mois'), findsOneWidget);
    expect(find.text('Dès le jeu. 5 nov.'), findsOneWidget);
    expect(find.text('Sans fin'), findsOneWidget);

    await tester.tap(find.text('Tous les 3 mois'));
    await tester.pump();
    expect(_ruleOf(tester).interval, 3);
    expect(find.text('Le 5, tous les 3 mois'), findsOneWidget);

    await tester.tap(find.text('Chaque semaine'));
    await tester.pump();
    expect(_ruleOf(tester).unit, LucidRecurrenceUnit.week);
    expect(find.text('Chaque jeudi'), findsOneWidget);

    await tester.tap(find.text('Chaque année'));
    await tester.pump();
    expect(find.text('Chaque année, le 5 novembre'), findsOneWidget);
  });

  testWidgets('le 1er, et les mois trop courts pour un 31', (tester) async {
    await tester.pumpWidget(
      _Host(initial: _fifth.copyWith(start: DateTime(2026, 12, 1))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Le 1er de chaque mois'), findsOneWidget);
    expect(find.text('Les mois plus courts : le dernier jour.'), findsNothing);

    await tester.pumpWidget(
      _Host(
        key: const ValueKey('31'),
        initial: _fifth.copyWith(start: DateTime(2026, 12, 31)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Les mois plus courts : le dernier jour.'),
      findsOneWidget,
    );
  });

  testWidgets('une fin se choisit au calendrier, et s’enlève', (tester) async {
    await tester.pumpWidget(_Host(initial: _fifth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choisir une fin'));
    await tester.pumpAndSettle();
    // Le calendrier propose un an plus tard : on valide.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(_ruleOf(tester).until, DateTime(2027, 11, 5));
    expect(find.text('Jusqu’au 5 nov. 2027'), findsOneWidget);

    await tester.tap(find.text('Sans fin'));
    await tester.pump();
    expect(_ruleOf(tester).until, isNull);
  });

  testWidgets('un nouveau début après la fin enlève la fin', (tester) async {
    await tester.pumpWidget(
      _Host(initial: _fifth.copyWith(until: DateTime(2026, 11, 20))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dès le jeu. 5 nov.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(_ruleOf(tester).start, DateTime(2026, 11, 25));
    expect(_ruleOf(tester).until, isNull);
  });

  testWidgets('l’application peut dessiner ses propres choix', (tester) async {
    await tester.pumpWidget(
      _Host(
        initial: _fifth,
        choiceBuilder: (context, choice) => TextButton(
          onPressed: choice.onTap,
          child: Text(choice.selected ? '[${choice.label}]' : choice.label),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('[Chaque mois]'), findsOneWidget);
  });

  testWidgets('une fréquence hors de la liste reste visible', (tester) async {
    await tester.pumpWidget(_Host(initial: _fifth.copyWith(interval: 2)));
    await tester.pumpAndSettle();
    expect(find.text('Tous les 2 mois'), findsOneWidget);
  });

  testWidgets('en français même sans LucidL10n déclaré', (tester) async {
    await tester.pumpWidget(_Host(initial: _fifth, withL10n: false));
    await tester.pumpAndSettle();
    expect(find.text('Le 5 de chaque mois'), findsOneWidget);
  });

  testWidgets('le début et la fin peuvent être imposés par l’application', (
    tester,
  ) async {
    await tester.pumpWidget(_Host(initial: _fifth, showStart: false));
    await tester.pumpAndSettle();
    expect(find.text('Dès le jeu. 5 nov.'), findsNothing);
    expect(find.text('Sans fin'), findsOneWidget);

    await tester.pumpWidget(
      _Host(
        key: const ValueKey('rien'),
        initial: _fifth,
        showStart: false,
        showUntil: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sans fin'), findsNothing);
    expect(find.text('Le 5 de chaque mois'), findsOneWidget);
  });
}
