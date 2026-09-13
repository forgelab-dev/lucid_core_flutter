import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart' show LucidL10n;
import '../../core/core.dart';

/// L'état vide générique : une seule définition, réutilisée partout où une
/// liste/collection peut être vide ([LucidListManager] y compris), pour ne
/// jamais dupliquer ce texte ou ce visuel d'un écran à l'autre.
///
/// Le texte par défaut vient de [LucidL10n] (`noResults`) ; il se dégrade
/// proprement en français si le widget est utilisé sans [LucidApp]/délégués
/// de localisation installés.
class LucidEmptyState extends StatelessWidget {
  const LucidEmptyState({super.key, this.icon = Icons.inbox_outlined, this.title, this.message, this.action});

  final IconData icon;
  final String? title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final l10n = LucidL10n.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title ?? l10n?.noResults ?? 'Aucun résultat',
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
