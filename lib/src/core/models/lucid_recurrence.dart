import 'package:flutter/foundation.dart';

/// L'unité d'une [LucidRecurrence].
enum LucidRecurrenceUnit { week, month, year }

/// Une règle de répétition par dates : « chaque mois le 5 », « un mercredi
/// sur deux », « chaque année le 29 février »…
///
/// ```dart
/// final loyer = LucidRecurrence(
///   unit: LucidRecurrenceUnit.month,
///   start: DateTime(2026, 1, 31),
/// );
/// loyer.occurrence(1); // 28 février 2026 : le mois n'a pas de 31
/// loyer.occurrence(2); // 31 mars 2026 : on ne garde pas le 28
/// loyer.between(DateTime(2026, 4, 1), DateTime(2026, 6, 30)); // 30/4, 31/5, 30/6
/// ```
///
/// Les dates sont des jours du calendrier, sans heure : [start] et [until]
/// sont ramenés à minuit, heure locale. Chaque échéance se calcule depuis
/// [start] et non depuis la précédente : un 31 ramené au 30 en novembre
/// redevient un 31 en décembre. Un jour qui manque au mois (29, 30, 31)
/// devient le dernier jour de ce mois.
@immutable
class LucidRecurrence {
  LucidRecurrence({
    required this.unit,
    this.interval = 1,
    required DateTime start,
    DateTime? until,
  }) : assert(interval >= 1, 'interval compte les unités : au moins 1'),
       start = _day(start),
       until = until == null ? null : _day(until);

  final LucidRecurrenceUnit unit;

  /// Toutes les combien d'unités : 1 pour chaque mois, 3 pour un trimestre.
  final int interval;

  /// Première échéance ; elle fixe aussi le jour (du mois, de la semaine).
  final DateTime start;

  /// Dernier jour possible, inclus ; `null` : sans fin.
  final DateTime? until;

  /// L'échéance numéro [index], la première étant 0 ; `null` après [until].
  DateTime? occurrence(int index) {
    assert(index >= 0, 'index commence à 0');
    final date = _at(index);
    final end = until;
    return end != null && date.isAfter(end) ? null : date;
  }

  /// La première échéance le jour [day] ou après ; `null` s'il n'y en a plus.
  DateTime? nextOnOrAfter(DateTime day) {
    final target = _day(day);
    if (!target.isAfter(start)) return occurrence(0);
    final index = switch (unit) {
      LucidRecurrenceUnit.week =>
        (_daysBetween(start, target) / (7 * interval)).ceil(),
      _ => () {
        // L'échéance du même mois peut tomber avant [day] : on prend alors la
        // suivante, qui est forcément dans un mois plus tardif.
        final months =
            (target.year - start.year) * 12 + target.month - start.month;
        final candidate = months ~/ _monthStep;
        return _at(candidate).isBefore(target) ? candidate + 1 : candidate;
      }(),
    };
    return occurrence(index);
  }

  /// Les échéances de [from] à [to], bornes comprises.
  List<DateTime> between(DateTime from, DateTime to) {
    final last = _day(to);
    final first = nextOnOrAfter(from);
    if (first == null || first.isAfter(last)) return const [];
    final dates = <DateTime>[];
    for (var index = indexOf(first)!; ; index++) {
      final date = occurrence(index);
      if (date == null || date.isAfter(last)) break;
      dates.add(date);
    }
    return dates;
  }

  /// Le rang de [date] si c'est une échéance de la règle, sinon `null`.
  int? indexOf(DateTime date) {
    final day = _day(date);
    if (day.isBefore(start)) return null;
    final next = nextOnOrAfter(day);
    if (next != day) return null;
    final index = switch (unit) {
      LucidRecurrenceUnit.week => _daysBetween(start, day) ~/ (7 * interval),
      _ =>
        ((day.year - start.year) * 12 + day.month - start.month) ~/ _monthStep,
    };
    return index;
  }

  LucidRecurrence copyWith({
    LucidRecurrenceUnit? unit,
    int? interval,
    DateTime? start,
    DateTime? until,
    bool clearUntil = false,
  }) => LucidRecurrence(
    unit: unit ?? this.unit,
    interval: interval ?? this.interval,
    start: start ?? this.start,
    until: clearUntil ? null : (until ?? this.until),
  );

  int get _monthStep =>
      unit == LucidRecurrenceUnit.year ? 12 * interval : interval;

  DateTime _at(int index) => switch (unit) {
    // Le constructeur de DateTime, et non `add(Duration)` : un changement
    // d'heure ne décale pas le jour.
    LucidRecurrenceUnit.week => DateTime(
      start.year,
      start.month,
      start.day + 7 * interval * index,
    ),
    _ => _clamped(start.year, start.month + _monthStep * index, start.day),
  };

  static DateTime _clamped(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDay ? lastDay : day);
  }

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Écart en jours entiers, insensible aux changements d'heure.
  static int _daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  @override
  bool operator ==(Object other) =>
      other is LucidRecurrence &&
      other.unit == unit &&
      other.interval == interval &&
      other.start == start &&
      other.until == until;

  @override
  int get hashCode => Object.hash(unit, interval, start, until);

  @override
  String toString() =>
      'LucidRecurrence(${unit.name} × $interval, '
      'dès ${start.toIso8601String().substring(0, 10)}'
      '${until == null ? '' : ', jusqu’au ${until!.toIso8601String().substring(0, 10)}'})';
}
