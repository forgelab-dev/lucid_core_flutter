import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart' show LucidL10n;

/// Montants masqués ou visibles. L'application crée le contrôleur, choisit
/// l'état de départ et, si elle veut retenir le choix, écoute ses changements.
class LucidPrivacyController extends ValueNotifier<bool> {
  LucidPrivacyController({bool hidden = false}) : super(hidden);

  bool get hidden => value;
  set hidden(bool hidden) => value = hidden;

  void toggle() => value = !value;
}

/// Partage un [LucidPrivacyController] avec tout ce qu'elle contient : un seul
/// œil masque d'un coup tous les [LucidPrivateText] de la zone.
class LucidPrivacyScope extends InheritedNotifier<LucidPrivacyController> {
  const LucidPrivacyScope({
    super.key,
    required LucidPrivacyController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Le contrôleur de la zone, ou `null` hors de toute zone.
  static LucidPrivacyController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LucidPrivacyScope>()?.notifier;

  /// Les montants sont-ils masqués ici ? `false` hors de toute zone.
  static bool isHidden(BuildContext context) =>
      maybeOf(context)?.hidden ?? false;
}

/// Un texte sensible (montant, solde) remplacé par [mask] quand la zone est
/// en mode masqué. Le lecteur d'écran annonce alors « Montant masqué » au
/// lieu de lire la valeur.
class LucidPrivateText extends StatelessWidget {
  const LucidPrivateText(
    this.text, {
    super.key,
    this.style,
    this.mask = '•••••',
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;

  /// Ce qui s'affiche à la place de [text]. Garder l'unité (« ••• F CFA »)
  /// aide à reconnaître la ligne sans dévoiler la valeur.
  final String mask;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final hidden = LucidPrivacyScope.isHidden(context);
    final label = LucidL10n.of(context)?.hiddenValue ?? 'Montant masqué';
    final shown = hidden
        ? Semantics(
            key: const ValueKey('hidden'),
            label: label,
            excludeSemantics: true,
            child: Text(
              mask,
              style: style,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
            ),
          )
        : Text(
            text,
            key: const ValueKey('shown'),
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      // Le nouveau texte s'aligne comme l'ancien, sans saut de mise en page.
      layoutBuilder: (current, previous) => Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [...previous, ?current],
      ),
      child: shown,
    );
  }
}

/// L'œil qui masque ou affiche les montants de la zone. Sans zone autour, il
/// ne s'affiche pas.
class LucidPrivacyToggle extends StatelessWidget {
  const LucidPrivacyToggle({super.key, this.color, this.iconSize});

  final Color? color;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final controller = LucidPrivacyScope.maybeOf(context);
    if (controller == null) return const SizedBox.shrink();
    final l10n = LucidL10n.of(context);
    final hidden = controller.hidden;

    return IconButton(
      onPressed: controller.toggle,
      color: color,
      iconSize: iconSize,
      tooltip: hidden
          ? (l10n?.showValues ?? 'Afficher les montants')
          : (l10n?.hideValues ?? 'Masquer les montants'),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: Icon(
          hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          key: ValueKey(hidden),
        ),
      ),
    );
  }
}
