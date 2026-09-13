import 'package:flutter/widgets.dart';

/// Une destination de navigation, rendue par [LucidNavigationManager] comme
/// item de bottom bar, rail, drawer ou menu selon le mode résolu.
class LucidNavDestination {
  const LucidNavDestination({required this.icon, required this.label, this.selectedIcon, this.tooltip});

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? tooltip;
}
