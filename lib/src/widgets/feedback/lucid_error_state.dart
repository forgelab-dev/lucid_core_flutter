import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart' show LucidL10n;
import '../../core/core.dart';
import '../buttons/lucid_button.dart';

/// L'état d'erreur générique : une seule définition, réutilisée partout où
/// un chargement peut échouer, pour ne jamais dupliquer ce texte ou ce
/// visuel d'un écran à l'autre.
///
/// Les textes par défaut viennent de [LucidL10n] (`somethingWentWrong`,
/// `tryAgainLater`) ; ils se dégradent proprement en français si le widget
/// est utilisé sans [LucidApp]/délégués de localisation installés.
class LucidErrorState extends StatelessWidget {
  const LucidErrorState({super.key, this.icon = Icons.error_outline, this.title, this.message, this.onRetry});

  final IconData icon;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  /// Construit un [LucidErrorState] à partir d'une [LucidAbstractException]
  /// déjà levée par un service (API, auth, storage...), pour ne pas
  /// reformuler son message à la main à chaque écran.
  factory LucidErrorState.fromException(LucidAbstractException exception, {VoidCallback? onRetry}) {
    return LucidErrorState(message: exception.message, onRetry: onRetry);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LucidL10n.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              title ?? l10n?.somethingWentWrong ?? 'Une erreur est survenue',
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? l10n?.tryAgainLater ?? 'Veuillez réessayer plus tard',
              style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[const SizedBox(height: 24), LucidRetryButton(onPressed: onRetry!)],
          ],
        ),
      ),
    );
  }
}
