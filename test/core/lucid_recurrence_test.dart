import 'package:flutter_test/flutter_test.dart';
import 'package:lucid_core_flutter/lucid_core_flutter.dart';

void main() {
  const month = LucidRecurrenceUnit.month;

  group('occurrence', () {
    test(
      'un 31 devient le dernier jour des mois plus courts, sans dériver',
      () {
        final rule = LucidRecurrence(unit: month, start: DateTime(2026, 1, 31));
        expect(
          [for (var i = 0; i < 4; i++) rule.occurrence(i)],
          [
            DateTime(2026, 1, 31),
            DateTime(2026, 2, 28),
            DateTime(2026, 3, 31),
            DateTime(2026, 4, 30),
          ],
        );
      },
    );

    test('chaque année le 29 février : le 28 les autres années', () {
      final rule = LucidRecurrence(
        unit: LucidRecurrenceUnit.year,
        start: DateTime(2028, 2, 29),
      );
      expect(rule.occurrence(1), DateTime(2029, 2, 28));
      expect(rule.occurrence(4), DateTime(2032, 2, 29));
    });

    test('un mercredi sur deux, même à travers un changement d’heure', () {
      final rule = LucidRecurrence(
        unit: LucidRecurrenceUnit.week,
        interval: 2,
        start: DateTime(2026, 3, 18, 22, 30),
      );
      expect(rule.start, DateTime(2026, 3, 18), reason: 'l’heure est oubliée');
      expect(rule.occurrence(1), DateTime(2026, 4, 1));
      expect(rule.occurrence(1)!.weekday, DateTime.wednesday);
    });

    test('rien après la date de fin', () {
      final rule = LucidRecurrence(
        unit: month,
        start: DateTime(2026, 1, 5),
        until: DateTime(2026, 3, 5),
      );
      expect(rule.occurrence(2), DateTime(2026, 3, 5));
      expect(rule.occurrence(3), isNull);
    });
  });

  group('nextOnOrAfter', () {
    final rule = LucidRecurrence(
      unit: month,
      interval: 3,
      start: DateTime(2026, 1, 15),
    );

    test('avant le début : la première échéance', () {
      expect(rule.nextOnOrAfter(DateTime(2025, 6, 1)), DateTime(2026, 1, 15));
    });

    test('le jour même compte', () {
      expect(
        rule.nextOnOrAfter(DateTime(2026, 4, 15, 18)),
        DateTime(2026, 4, 15),
      );
    });

    test('après l’échéance du mois : celle du trimestre suivant', () {
      expect(rule.nextOnOrAfter(DateTime(2026, 4, 16)), DateTime(2026, 7, 15));
      expect(rule.nextOnOrAfter(DateTime(2026, 5, 2)), DateTime(2026, 7, 15));
    });

    test('un 31 et un jour qui tombe dans un mois court', () {
      final end = LucidRecurrence(unit: month, start: DateTime(2026, 1, 31));
      expect(end.nextOnOrAfter(DateTime(2026, 2, 28)), DateTime(2026, 2, 28));
      expect(end.nextOnOrAfter(DateTime(2026, 3, 1)), DateTime(2026, 3, 31));
    });

    test('chaque semaine', () {
      final weekly = LucidRecurrence(
        unit: LucidRecurrenceUnit.week,
        start: DateTime(2026, 11, 2),
      );
      expect(
        weekly.nextOnOrAfter(DateTime(2026, 11, 11)),
        DateTime(2026, 11, 16),
      );
      expect(
        weekly.nextOnOrAfter(DateTime(2026, 11, 9)),
        DateTime(2026, 11, 9),
      );
    });

    test('plus rien une fois la fin passée', () {
      final ended = rule.copyWith(until: DateTime(2026, 5, 1));
      expect(ended.nextOnOrAfter(DateTime(2026, 4, 16)), isNull);
    });
  });

  group('between', () {
    test('les échéances d’une période, bornes comprises', () {
      final rule = LucidRecurrence(unit: month, start: DateTime(2026, 1, 31));
      expect(rule.between(DateTime(2026, 4, 1), DateTime(2026, 6, 30)), [
        DateTime(2026, 4, 30),
        DateTime(2026, 5, 31),
        DateTime(2026, 6, 30),
      ]);
    });

    test('vide quand aucune échéance ne tombe dedans', () {
      final rule = LucidRecurrence(
        unit: LucidRecurrenceUnit.year,
        start: DateTime(2026, 12, 25),
      );
      expect(
        rule.between(DateTime(2027, 1, 1), DateTime(2027, 11, 30)),
        isEmpty,
      );
    });

    test('s’arrête à la date de fin', () {
      final rule = LucidRecurrence(
        unit: LucidRecurrenceUnit.week,
        start: DateTime(2026, 11, 2),
        until: DateTime(2026, 11, 20),
      );
      expect(rule.between(DateTime(2026, 11, 1), DateTime(2026, 12, 31)), [
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 9),
        DateTime(2026, 11, 16),
      ]);
    });
  });

  group('indexOf', () {
    final rule = LucidRecurrence(unit: month, start: DateTime(2026, 1, 31));

    test('le rang d’une échéance', () {
      expect(rule.indexOf(DateTime(2026, 1, 31)), 0);
      expect(rule.indexOf(DateTime(2026, 2, 28)), 1);
      expect(rule.indexOf(DateTime(2026, 12, 31, 9)), 11);
    });

    test('null pour un jour qui n’en est pas une', () {
      expect(rule.indexOf(DateTime(2026, 2, 27)), isNull);
      expect(rule.indexOf(DateTime(2025, 12, 31)), isNull);
    });
  });

  test('copyWith et égalité', () {
    final rule = LucidRecurrence(
      unit: month,
      start: DateTime(2026, 1, 5),
      until: DateTime(2026, 6, 5),
    );
    expect(rule.copyWith(), rule);
    expect(rule.copyWith(clearUntil: true).until, isNull);
    expect(rule.copyWith(interval: 2), isNot(rule));
  });
}
