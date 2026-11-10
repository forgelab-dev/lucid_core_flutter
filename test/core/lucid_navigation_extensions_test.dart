import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Comme une application go_router : on masque la navigation, pas le reste.
import 'package:lucid_core_flutter/lucid_core_flutter.dart' hide LucidNavigationExtensions;

/// Imite go_router, qui déclare aussi `push` et `pop` sur BuildContext.
extension _RouterLike on BuildContext {
  String push(String location) => location;

  String pop() => 'routeur';
}

void main() {
  testWidgets('une app go_router garde les raccourcis de thème et d’écran', (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    );

    // Compile seulement si push/pop ne viennent plus de LucidBuildContextExtensions.
    expect(captured.push('/depenses'), '/depenses');
    expect(captured.pop(), 'routeur');
    expect(captured.colors, Theme.of(captured).colorScheme);
    expect(captured.screenWidth, greaterThan(0));
  });
}
