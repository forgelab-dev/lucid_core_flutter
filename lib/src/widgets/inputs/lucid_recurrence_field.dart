import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart' show LucidL10n, lookupLucidL10n;
import '../../core/models/lucid_recurrence.dart';

/// Une fréquence proposée par [LucidRecurrenceField] : « tous les 3 mois »
/// s'écrit `(unit: LucidRecurrenceUnit.month, interval: 3)`.
typedef LucidRecurrenceFrequency = ({LucidRecurrenceUnit unit, int interval});

/// Un choix à dessiner : une fréquence, la date de début, la fin.
@immutable
class LucidChoice {
  const LucidChoice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
}

/// Dessine un [LucidChoice] ; voir [LucidRecurrenceField.choiceBuilder].
typedef LucidChoiceBuilder =
    Widget Function(BuildContext context, LucidChoice choice);

/// Choisir comment une chose revient : la fréquence, le jour de départ, et
/// une fin éventuelle. Une phrase dit la règle en clair (« Le 31 de chaque
/// mois »), et prévient quand le jour manque à certains mois.
///
/// ```dart
/// LucidRecurrenceField(
///   value: _rule,
///   onChanged: (rule) => setState(() => _rule = rule),
/// )
/// ```
///
/// Les choix sont des [ChoiceChip] du thème ; une application qui a ses
/// propres pastilles les fournit par [choiceBuilder]. Les textes viennent de
/// [LucidL10n], en français si l'application ne l'a pas déclaré.
class LucidRecurrenceField extends StatelessWidget {
  const LucidRecurrenceField({
    super.key,
    required this.value,
    required this.onChanged,
    this.frequencies = defaultFrequencies,
    this.showStart = true,
    this.showUntil = true,
    this.firstDate,
    this.lastDate,
    this.choiceBuilder,
  });

  /// Chaque semaine, chaque mois, chaque trimestre, chaque année.
  static const List<LucidRecurrenceFrequency> defaultFrequencies = [
    (unit: LucidRecurrenceUnit.week, interval: 1),
    (unit: LucidRecurrenceUnit.month, interval: 1),
    (unit: LucidRecurrenceUnit.month, interval: 3),
    (unit: LucidRecurrenceUnit.year, interval: 1),
  ];

  final LucidRecurrence value;
  final ValueChanged<LucidRecurrence> onChanged;
  final List<LucidRecurrenceFrequency> frequencies;

  /// Propose de changer le jour de départ. À masquer quand il est imposé, par
  /// exemple par la date d'une opération qui devient la première échéance.
  final bool showStart;

  /// Propose « Sans fin » ou une date de fin.
  final bool showUntil;

  /// Bornes des calendriers ; par défaut un an avant le début, dix ans après.
  final DateTime? firstDate;
  final DateTime? lastDate;

  final LucidChoiceBuilder? choiceBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = LucidRecurrenceText._l10n(context);
    final locale = LucidRecurrenceText._locale(context);
    final theme = Theme.of(context);
    final build = choiceBuilder ?? _chip;
    final current = (unit: value.unit, interval: value.interval);
    final until = value.until;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in {...frequencies, current})
              build(
                context,
                LucidChoice(
                  label: LucidRecurrenceText.frequency(
                    context,
                    f.unit,
                    f.interval,
                  ),
                  selected: f == current,
                  onTap: () => onChanged(
                    value.copyWith(unit: f.unit, interval: f.interval),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          LucidRecurrenceText.summary(context, value),
          style: theme.textTheme.bodyLarge,
        ),
        if (value.unit != LucidRecurrenceUnit.week && value.start.day > 28)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              l10n.recurrenceMonthEndNote,
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (showStart || showUntil) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (showStart)
                build(
                  context,
                  LucidChoice(
                    label: l10n.recurrenceStartsOn(
                      DateFormat.MMMEd(locale).format(value.start),
                    ),
                    icon: Icons.event_outlined,
                    selected: false,
                    onTap: () => _pickStart(context),
                  ),
                ),
              if (showUntil) ...[
                build(
                  context,
                  LucidChoice(
                    label: l10n.recurrenceNoEnd,
                    selected: until == null,
                    onTap: () => onChanged(value.copyWith(clearUntil: true)),
                  ),
                ),
                build(
                  context,
                  LucidChoice(
                    label: until == null
                        ? l10n.recurrenceSetEnd
                        : l10n.recurrenceUntil(
                            DateFormat.yMMMd(locale).format(until),
                          ),
                    icon: Icons.event_busy_outlined,
                    selected: until != null,
                    onTap: () => _pickUntil(context),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  DateTime get _first =>
      firstDate ?? DateTime(value.start.year - 1, value.start.month);
  DateTime get _last => lastDate ?? DateTime(value.start.year + 10, 12, 31);

  Future<void> _pickStart(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value.start,
      firstDate: _first.isAfter(value.start) ? value.start : _first,
      lastDate: _last,
    );
    if (picked == null) return;
    final until = value.until;
    // Une fin placée avant le nouveau début n'a plus de sens.
    onChanged(
      value.copyWith(
        start: picked,
        clearUntil: until != null && until.isBefore(picked),
      ),
    );
  }

  Future<void> _pickUntil(BuildContext context) async {
    final start = value.start;
    final suggested =
        value.until ?? DateTime(start.year + 1, start.month, start.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: suggested.isAfter(_last) ? _last : suggested,
      firstDate: start,
      lastDate: _last,
    );
    if (picked == null) return;
    onChanged(value.copyWith(until: picked));
  }

  static Widget _chip(BuildContext context, LucidChoice choice) => ChoiceChip(
    label: Text(choice.label),
    avatar: choice.icon == null ? null : Icon(choice.icon, size: 18),
    selected: choice.selected,
    showCheckmark: false,
    onSelected: (_) => choice.onTap(),
  );
}

/// Les phrases d'une [LucidRecurrence], pour l'afficher ailleurs qu'en
/// saisie (une liste d'abonnements, un rappel…).
abstract final class LucidRecurrenceText {
  /// « Chaque mois », « Tous les 3 mois », « Toutes les 2 semaines »…
  static String frequency(
    BuildContext context,
    LucidRecurrenceUnit unit,
    int interval,
  ) {
    final l10n = _l10n(context);
    return switch ((unit, interval)) {
      (LucidRecurrenceUnit.week, 1) => l10n.recurrenceEveryWeek,
      (LucidRecurrenceUnit.week, final n) => l10n.recurrenceEveryNWeeks(n),
      (LucidRecurrenceUnit.month, 1) => l10n.recurrenceEveryMonth,
      (LucidRecurrenceUnit.month, final n) => l10n.recurrenceEveryNMonths(n),
      (LucidRecurrenceUnit.year, 1) => l10n.recurrenceEveryYear,
      (LucidRecurrenceUnit.year, final n) => l10n.recurrenceEveryNYears(n),
    };
  }

  /// La règle en clair : « Chaque mercredi », « Le 1er de chaque mois »,
  /// « Chaque année, le 5 novembre »…
  static String summary(BuildContext context, LucidRecurrence rule) {
    final l10n = _l10n(context);
    final locale = _locale(context);
    final n = rule.interval;
    final start = rule.start;
    switch (rule.unit) {
      case LucidRecurrenceUnit.week:
        final weekday = DateFormat.EEEE(locale).format(start);
        return n == 1
            ? l10n.recurrenceOnWeekday(weekday)
            : l10n.recurrenceOnWeekdayEveryN(weekday, n);
      case LucidRecurrenceUnit.month:
        final day = _dayOfMonth(start.day, locale);
        return n == 1
            ? l10n.recurrenceOnMonthDay(day)
            : l10n.recurrenceOnMonthDayEveryN(day, n);
      case LucidRecurrenceUnit.year:
        final date = DateFormat.MMMMd(locale).format(start);
        return n == 1
            ? l10n.recurrenceOnYearDay(date)
            : l10n.recurrenceOnYearDayEveryN(date, n);
    }
  }

  /// En français, le premier du mois s'écrit « 1er ».
  static String _dayOfMonth(int day, String locale) =>
      day == 1 && locale.startsWith('fr') ? '1er' : '$day';

  /// Les textes de l'application ; à défaut, ceux de sa langue si le paquet
  /// la connaît, sinon le français. Les dates suivent la même langue.
  static LucidL10n _l10n(BuildContext context) {
    final declared = LucidL10n.of(context);
    if (declared != null) return declared;
    final locale = Localizations.maybeLocaleOf(context);
    return locale != null && LucidL10n.delegate.isSupported(locale)
        ? lookupLucidL10n(locale)
        : lookupLucidL10n(const Locale('fr'));
  }

  static String _locale(BuildContext context) => _l10n(context).localeName;
}
