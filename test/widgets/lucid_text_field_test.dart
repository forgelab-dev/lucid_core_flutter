import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lucid_core_flutter.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget field) {
  return tester.pumpWidget(MaterialApp(home: Scaffold(body: Form(child: field))));
}

TextField _inner(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField));

void main() {
  testWidgets('affiche une aide sous le champ', (tester) async {
    await _pump(tester, const LucidTextField(label: 'Solde', helperText: 'Ce qu’il y a sur le compte aujourd’hui.'));

    expect(find.text('Ce qu’il y a sur le compte aujourd’hui.'), findsOneWidget);
  });

  testWidgets('transmet la majuscule automatique au clavier', (tester) async {
    await _pump(tester, const LucidTextField(label: 'Note', textCapitalization: TextCapitalization.sentences));

    expect(_inner(tester).textCapitalization, TextCapitalization.sentences);
  });

  testWidgets('sans majuscule automatique par défaut, et jamais pour un email', (tester) async {
    await _pump(tester, const LucidTextField(label: 'Nom'));
    expect(_inner(tester).textCapitalization, TextCapitalization.none);

    await _pump(tester, const LucidTextField.email());
    expect(_inner(tester).textCapitalization, TextCapitalization.none);
  });

  testWidgets('le champ mot de passe accepte une erreur venue du serveur, et une aide', (tester) async {
    await _pump(
      tester,
      const LucidTextField.password(errorText: 'Mot de passe incorrect', helperText: '12 caractères au moins'),
    );

    expect(find.text('Mot de passe incorrect'), findsOneWidget);
    expect(find.text('12 caractères au moins'), findsNothing, reason: 'l’erreur remplace l’aide');
  });

  testWidgets('le champ email accepte une erreur venue du serveur', (tester) async {
    await _pump(tester, const LucidTextField.email(errorText: 'Adresse déjà utilisée'));

    expect(find.text('Adresse déjà utilisée'), findsOneWidget);
  });
}
