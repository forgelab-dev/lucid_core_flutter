import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Une action déclenchée en glissant une ligne : son icône, son libellé et sa
/// couleur s'affichent sous la ligne pendant le geste.
@immutable
class LucidSwipeAction {
  const LucidSwipeAction({
    required this.icon,
    required this.label,
    required this.onTriggered,
    this.color,
    this.removesItem = false,
    this.threshold = 0.35,
  }) : assert(
         threshold > 0 && threshold < 1,
         'threshold est une fraction de la largeur, entre 0 et 1',
       );

  final IconData icon;

  /// Affiché pendant le geste, et nom de l'action pour les lecteurs d'écran.
  final String label;

  /// Appelé une fois le geste abouti.
  final VoidCallback onTriggered;

  /// Couleur de l'icône, du libellé et de la teinte de fond ; par défaut la
  /// couleur primaire du thème.
  final Color? color;

  /// `true` : la ligne sort de la liste (supprimer, archiver). `false` : elle
  /// revient à sa place (modifier, ouvrir).
  final bool removesItem;

  /// Part de la largeur à parcourir pour déclencher l'action. Une action qui
  /// retire la ligne gagne à demander un geste plus franc.
  final double threshold;
}

/// Rend une ligne de liste glissable vers un côté, vers l'autre, ou les deux.
///
/// [startAction] se déclenche en glissant depuis le bord de départ (vers la
/// droite en français), [endAction] depuis le bord de fin (vers la gauche).
///
/// Une action qui retire la ligne la fait disparaître aussitôt, sans attendre
/// que la liste soit reconstruite : l'application peut supprimer en base de
/// façon asynchrone, puis proposer « Annuler ». Donnez à chaque ligne une clé
/// propre ([ValueKey] de son identifiant) : une ligne restaurée revient alors
/// comme une ligne neuve.
///
/// Le geste n'est qu'un raccourci : les actions sont aussi proposées aux
/// lecteurs d'écran, et la ligne doit rester ouvrable d'un simple toucher.
class LucidSwipeActions extends StatefulWidget {
  const LucidSwipeActions({
    super.key,
    required this.child,
    this.startAction,
    this.endAction,
    this.borderRadius,
  }) : assert(startAction != null || endAction != null, 'au moins une action');

  final Widget child;
  final LucidSwipeAction? startAction;
  final LucidSwipeAction? endAction;

  /// Arrondi de l'indication sous la ligne ; par défaut 12.
  final BorderRadius? borderRadius;

  @override
  State<LucidSwipeActions> createState() => _LucidSwipeActionsState();
}

class _LucidSwipeActionsState extends State<LucidSwipeActions> {
  // Clé propre à cet état : la ligne peut être reconstruite sans relancer le geste.
  final Key _dismissibleKey = UniqueKey();
  bool _removed = false;
  bool _reached = false;

  LucidSwipeAction? _actionFor(DismissDirection direction) =>
      switch (direction) {
        DismissDirection.startToEnd => widget.startAction,
        DismissDirection.endToStart => widget.endAction,
        _ => null,
      };

  DismissDirection get _direction =>
      switch ((widget.startAction, widget.endAction)) {
        (_?, _?) => DismissDirection.horizontal,
        (_?, null) => DismissDirection.startToEnd,
        _ => DismissDirection.endToStart,
      };

  void _trigger(LucidSwipeAction action) {
    if (action.removesItem) setState(() => _removed = true);
    action.onTriggered();
  }

  @override
  Widget build(BuildContext context) {
    // Un Dismissible écarté doit quitter l'arbre tout de suite.
    if (_removed) return const SizedBox.shrink();

    final start = widget.startAction;
    final end = widget.endAction;
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return Semantics(
      customSemanticsActions: {
        if (start != null)
          CustomSemanticsAction(label: start.label): () => _trigger(start),
        if (end != null)
          CustomSemanticsAction(label: end.label): () => _trigger(end),
      },
      child: Dismissible(
        key: _dismissibleKey,
        direction: _direction,
        dismissThresholds: {
          if (start != null) DismissDirection.startToEnd: start.threshold,
          if (end != null) DismissDirection.endToStart: end.threshold,
        },
        // Sans action de départ, Dismissible prendrait `background` pour la fin.
        background: _SwipeHint(
          action: start ?? end!,
          alignment: start != null
              ? AlignmentDirectional.centerStart
              : AlignmentDirectional.centerEnd,
          reached: _reached,
          radius: radius,
        ),
        secondaryBackground: start != null && end != null
            ? _SwipeHint(
                action: end,
                alignment: AlignmentDirectional.centerEnd,
                reached: _reached,
                radius: radius,
              )
            : null,
        onUpdate: (details) {
          if (details.reached != _reached) {
            if (details.reached) HapticFeedback.selectionClick();
            setState(() => _reached = details.reached);
          }
        },
        confirmDismiss: (direction) async {
          final action = _actionFor(direction);
          if (action == null) return false;
          if (action.removesItem) return true;
          action.onTriggered();
          return false;
        },
        onDismissed: (direction) {
          final action = _actionFor(direction);
          if (action != null) _trigger(action);
        },
        child: widget.child,
      ),
    );
  }
}

/// Ce qui apparaît sous la ligne : une teinte de la couleur de l'action, qui se
/// fonce quand le geste a assez couru pour déclencher.
class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.action,
    required this.alignment,
    required this.reached,
    required this.radius,
  });

  final LucidSwipeAction action;
  final AlignmentDirectional alignment;
  final bool reached;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = action.color ?? theme.colorScheme.primary;
    final atStart = alignment == AlignmentDirectional.centerStart;
    final parts = [
      Icon(action.icon, color: color, size: 22),
      const SizedBox(width: 8),
      Text(
        action.label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: color.withValues(alpha: reached ? 0.24 : 0.12),
        borderRadius: radius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: atStart ? parts : parts.reversed.toList(),
        ),
      ),
    );
  }
}
