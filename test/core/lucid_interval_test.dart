import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lib.dart';

void main() {
  late DateTime now;
  late List<int> steps;

  LucidIntervalController controllerFor(List<LucidIntervalStep> list) {
    steps = [];
    return LucidIntervalController(
      steps: list,
      clock: () => now,
      tickEvery: null,
      onStep: steps.add,
    );
  }

  void wait(int seconds) => now = now.add(Duration(seconds: seconds));

  setUp(() => now = DateTime(2026, 11, 12, 18));

  const circuit = [
    LucidIntervalStep.timed('Gainage', Duration(seconds: 40)),
    LucidIntervalStep.timed(
      'Repos',
      Duration(seconds: 20),
      kind: LucidIntervalKind.rest,
    ),
    LucidIntervalStep.counted('Pompes', 12),
    LucidIntervalStep.timed('Fente', Duration(seconds: 30)),
  ];

  test('une étape chronométrée passe seule à la suivante, au bon moment', () {
    final c = controllerFor(circuit)..start();
    expect(c.status, LucidIntervalStatus.running);
    expect(steps, [0]);

    wait(25);
    c.update();
    expect(c.index, 0);
    expect(c.remaining, const Duration(seconds: 15));
    expect(c.stepProgress, closeTo(25 / 40, 1e-9));

    wait(15);
    c.update();
    expect(c.current.label, 'Repos');
    expect(c.remaining, const Duration(seconds: 20));
  });

  test('une étape comptée attend « complete », sans limite de temps', () {
    final c = controllerFor(circuit)..start();
    wait(60);
    c.update();
    expect(c.current.label, 'Pompes');
    expect(c.remaining, isNull);
    expect(c.stepProgress, isNull);

    wait(300);
    c.update();
    expect(c.current.label, 'Pompes');

    c.complete();
    expect(c.current.label, 'Fente');
    expect(c.remaining, const Duration(seconds: 30));
    expect(c.next, isNull);
    expect(steps, [0, 1, 2, 3]);
  });

  test('après un long arrière-plan, la séance reprend où elle en serait', () {
    final c = controllerFor(circuit)..start();
    wait(55);
    c.update();
    // 40 s de gainage, puis 15 s sur les 20 de repos.
    expect(c.current.label, 'Repos');
    expect(c.remaining, const Duration(seconds: 5));
    expect(steps, [0, 1]);
  });

  test('la pause ne compte pas dans le temps écoulé', () {
    final c = controllerFor(circuit)..start();
    wait(10);
    c.pause();
    expect(c.status, LucidIntervalStatus.paused);
    wait(120);
    c.update();
    expect(c.elapsed, const Duration(seconds: 10));
    expect(c.remaining, const Duration(seconds: 30));

    c.resume();
    wait(5);
    c.update();
    expect(c.elapsed, const Duration(seconds: 15));
    expect(c.index, 0);
  });

  test('la dernière étape termine la séance et fige le temps actif', () {
    final c = controllerFor(circuit)..start();
    wait(60);
    c.update();
    wait(45);
    c.complete(); // pompes
    wait(31);
    c.update();
    expect(c.isFinished, isTrue);
    expect(steps.last, circuit.length);
    expect(c.elapsed, const Duration(seconds: 135));
    wait(600);
    expect(c.elapsed, const Duration(seconds: 135));
    expect(c.remaining, Duration.zero);
  });

  test('« complete » passe aussi une étape chronométrée, et ne fait rien avant le départ', () {
    final c = controllerFor(circuit);
    c.complete();
    expect(c.status, LucidIntervalStatus.ready);
    c.start();
    wait(3);
    c.complete();
    expect(c.current.label, 'Repos');
    expect(c.stepElapsed, Duration.zero);
  });

  testWidgets('le minuteur interne relit l’horloge tant que la séance tourne', (
    tester,
  ) async {
    var notified = 0;
    final c = LucidIntervalController(
      steps: const [LucidIntervalStep.timed('Gainage', Duration(seconds: 1))],
      clock: () => now,
    )..addListener(() => notified++);
    c.start();
    now = now.add(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 250));
    expect(c.isFinished, isTrue);
    final afterFinish = notified;
    await tester.pump(const Duration(seconds: 1));
    expect(notified, afterFinish);
    c.dispose();
  });
}
