import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart' show LucidL10n;
import '../../core/core.dart';

/// Le seul bouton à utiliser dans un projet LucidForge : un point unique pour
/// styliser/faire évoluer l'apparence des boutons (thème, état de
/// chargement, icône) au lieu de le refaire à chaque écran.
class LucidButton extends StatelessWidget {
  const LucidButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = LucidButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final LucidButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  /// Si vrai, prend toute la largeur disponible.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    // Pendant le chargement, on garde `onPressed` non-null (no-op) pour
    // conserver le fond actif : un bouton disabled griserait le fond et
    // rendrait le spinner (couleur du fond actif) quasi invisible.
    final effectiveOnPressed = isLoading ? () {} : onPressed;

    // Micro-interaction : le label et le spinner se croisent en fondu + léger
    // zoom (200 ms, charte « Or sur Nuit ») au lieu d'un simple swap.
    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: isLoading ? _buildSpinner(context) : _buildLabel(),
    );

    final button = switch (variant) {
      LucidButtonVariant.primary => ElevatedButton(onPressed: effectiveOnPressed, child: content),
      LucidButtonVariant.secondary => FilledButton.tonal(onPressed: effectiveOnPressed, child: content),
      LucidButtonVariant.outlined => OutlinedButton(onPressed: effectiveOnPressed, child: content),
      LucidButtonVariant.text => TextButton(onPressed: effectiveOnPressed, child: content),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildLabel() {
    if (icon == null) return Text(label, key: const ValueKey('label'));

    return Row(
      key: const ValueKey('label'),
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
    );
  }

  Widget _buildSpinner(BuildContext context) {
    return SizedBox(
      key: const ValueKey('loading'),
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: _foreground(context)),
    );
  }

  Color _foreground(BuildContext context) {
    final colors = context.colors;
    switch (variant) {
      case LucidButtonVariant.primary:
        return colors.onPrimary;
      case LucidButtonVariant.secondary:
        return colors.onSecondaryContainer;
      case LucidButtonVariant.outlined:
      case LucidButtonVariant.text:
        return colors.primary;
    }
  }
}

/// Raccourci pour un [LucidButton] dont le libellé est "Réessayer"
/// (traduit via [LucidL10n]).
class LucidRetryButton extends StatelessWidget {
  const LucidRetryButton({super.key, required this.onPressed, this.variant = LucidButtonVariant.secondary});

  final VoidCallback onPressed;
  final LucidButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return LucidButton(
      label: LucidL10n.of(context)?.retry ?? 'Réessayer',
      icon: Icons.refresh,
      variant: variant,
      onPressed: onPressed,
    );
  }
}
