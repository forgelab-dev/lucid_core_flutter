import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Un seul widget de navigation qui se rend différemment selon [mode] :
/// bottom bar, rail latéral, drawer permanent, onglets dans l'app bar, ou
/// menu déroulant — au lieu de choisir/écrire chacun séparément à la main.
///
/// Avec [LucidNavMode.auto] (par défaut), le rendu s'adapte à la largeur
/// d'écran (via `context.screenSizeClass`, cf. `LucidBuildContextExtensions`) :
/// bottom bar en dessous de 600, rail entre 600 et 1024, drawer permanent
/// au-delà — un pattern de "shell" adaptatif courant sans dépendre d'un
/// package tiers.
class LucidNavigationManager extends StatelessWidget {
  const LucidNavigationManager({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.mode = LucidNavMode.auto,
    this.appBarTitle,
    this.actions = const [],
    this.floatingActionButton,
    this.extendedSidebar = true,
    this.drawerWidth = 240,
    this.transitionDuration = const Duration(milliseconds: 200),
  });

  final List<LucidNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  final LucidNavMode mode;
  final Widget? appBarTitle;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  /// Utilisé uniquement en [LucidNavMode.sidebar].
  final bool extendedSidebar;

  /// Utilisé uniquement en [LucidNavMode.drawer].
  final double drawerWidth;

  final Duration transitionDuration;

  LucidNavMode _resolveMode(BuildContext context) {
    if (mode != LucidNavMode.auto) return mode;

    switch (context.screenSizeClass) {
      case LucidScreenSize.extraSmall:
      case LucidScreenSize.small:
        return LucidNavMode.bottomBar;
      case LucidScreenSize.medium:
        return LucidNavMode.sidebar;
      case LucidScreenSize.large:
      case LucidScreenSize.extraLarge:
        return LucidNavMode.drawer;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_resolveMode(context)) {
      case LucidNavMode.bottomBar:
        return _bottomBarScaffold(context);
      case LucidNavMode.sidebar:
        return _railScaffold(context);
      case LucidNavMode.drawer:
        return _drawerScaffold(context);
      case LucidNavMode.appBar:
        return _appBarTabsScaffold(context);
      case LucidNavMode.menu:
        return _menuScaffold(context);
      case LucidNavMode.auto:
        return _bottomBarScaffold(context);
    }
  }

  Widget _animatedBody() {
    return AnimatedSwitcher(
      duration: transitionDuration,
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(key: ValueKey(selectedIndex), child: body),
    );
  }

  Widget _bottomBarScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: appBarTitle, actions: actions),
      body: _animatedBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [for (final d in destinations) _toNavigationDestination(d)],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _railScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: appBarTitle, actions: actions),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: extendedSidebar,
            labelType: extendedSidebar ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            destinations: [for (final d in destinations) _toRailDestination(d)],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _animatedBody()),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _drawerScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: appBarTitle, actions: actions),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: drawerWidth,
            child: Material(
              color: context.colors.surface,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (int i = 0; i < destinations.length; i++)
                    ListTile(
                      leading: Icon(i == selectedIndex ? (destinations[i].selectedIcon ?? destinations[i].icon) : destinations[i].icon),
                      title: Text(destinations[i].label),
                      selected: i == selectedIndex,
                      onTap: () => onDestinationSelected(i),
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _animatedBody()),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _appBarTabsScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SegmentedButton<int>(
              segments: [
                for (int i = 0; i < destinations.length; i++)
                  ButtonSegment(value: i, icon: Icon(destinations[i].icon), label: Text(destinations[i].label)),
              ],
              selected: {selectedIndex},
              onSelectionChanged: (selection) => onDestinationSelected(selection.first),
            ),
          ),
        ),
      ),
      body: _animatedBody(),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _menuScaffold(BuildContext context) {
    final current = destinations[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        actions: [
          PopupMenuButton<int>(
            initialValue: selectedIndex,
            onSelected: onDestinationSelected,
            icon: Icon(current.icon),
            tooltip: current.label,
            itemBuilder: (context) => [
              for (int i = 0; i < destinations.length; i++)
                PopupMenuItem(value: i, child: Row(children: [Icon(destinations[i].icon), const SizedBox(width: 12), Text(destinations[i].label)])),
            ],
          ),
          ...actions,
        ],
      ),
      body: _animatedBody(),
      floatingActionButton: floatingActionButton,
    );
  }

  NavigationDestination _toNavigationDestination(LucidNavDestination d) {
    return NavigationDestination(
      icon: Icon(d.icon),
      selectedIcon: d.selectedIcon != null ? Icon(d.selectedIcon) : null,
      label: d.label,
      tooltip: d.tooltip,
    );
  }

  NavigationRailDestination _toRailDestination(LucidNavDestination d) {
    return NavigationRailDestination(
      icon: Icon(d.icon),
      selectedIcon: d.selectedIcon != null ? Icon(d.selectedIcon) : null,
      label: Text(d.label),
    );
  }
}
