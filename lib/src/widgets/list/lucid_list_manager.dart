import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../feedback/lucid_empty_state.dart';

/// Un seul widget pour afficher une collection : selon [mode], il se rend en
/// liste, grille ou carrousel — au lieu de choisir entre `ListView`,
/// `GridView` et `PageView` à chaque écran.
///
/// Gère aussi, de façon optionnelle et indépendante les unes des autres :
/// pull-to-refresh ([onRefresh]), pagination infinie ([onLoadMore]), état
/// vide ([emptyBuilder]) avec transition animée, et lecture automatique pour
/// le carrousel ([autoPlay]).
///
/// Reste performant sur de grandes listes : s'appuie systématiquement sur les
/// constructeurs `.builder` (`ListView.builder`, `GridView.builder`,
/// `PageView.builder`), qui ne construisent que les items visibles.
class LucidListManager<T> extends StatefulWidget {
  const LucidListManager({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.mode = LucidListMode.list,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.physics,
    this.controller,
    this.separatorBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.childAspectRatio = 1,
    this.viewportFraction = 0.86,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.onPageChanged,
    this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreThreshold = 200,
    this.emptyBuilder,
    this.loadingMoreBuilder,
    this.transitionDuration = const Duration(milliseconds: 250),
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final LucidListMode mode;

  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  /// Utilisé uniquement en [LucidListMode.list].
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Utilisés uniquement en [LucidListMode.grid].
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  /// Utilisés uniquement en [LucidListMode.carousel].
  final double viewportFraction;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final ValueChanged<int>? onPageChanged;

  /// Si fourni, enveloppe le contenu dans un [RefreshIndicator].
  final Future<void> Function()? onRefresh;

  /// Appelé quand le scroll approche de la fin, pour la pagination infinie.
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  /// Distance (en pixels) avant la fin du scroll à partir de laquelle
  /// [onLoadMore] est déclenché.
  final double loadMoreThreshold;

  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? loadingMoreBuilder;

  final Duration transitionDuration;

  @override
  State<LucidListManager<T>> createState() => _LucidListManagerState<T>();
}

class _LucidListManagerState<T> extends State<LucidListManager<T>> {
  late ScrollController _scrollController;
  PageController? _pageController;
  Timer? _autoPlayTimer;
  bool _loadMoreTriggered = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();

    if (widget.mode == LucidListMode.carousel) {
      _pageController = PageController(viewportFraction: widget.viewportFraction);
      _maybeStartAutoPlay();
    } else {
      _scrollController.addListener(_handleScroll);
    }
  }

  @override
  void didUpdateWidget(covariant LucidListManager<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoPlay != oldWidget.autoPlay || widget.mode != oldWidget.mode) {
      _autoPlayTimer?.cancel();
      _maybeStartAutoPlay();
    }
  }

  void _maybeStartAutoPlay() {
    if (widget.mode != LucidListMode.carousel || !widget.autoPlay || widget.items.length < 2) return;

    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      final controller = _pageController;
      if (controller == null || !controller.hasClients) return;

      final next = (controller.page ?? 0).round() + 1;
      controller.animateToPage(
        next % widget.items.length,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _handleScroll() {
    if (widget.onLoadMore == null || !widget.hasMore || widget.isLoadingMore) return;
    if (!_scrollController.hasClients) return;

    final remaining = _scrollController.position.maxScrollExtent - _scrollController.position.pixels;
    if (remaining <= widget.loadMoreThreshold && !_loadMoreTriggered) {
      _loadMoreTriggered = true;
      widget.onLoadMore!().whenComplete(() => _loadMoreTriggered = false);
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    if (widget.controller == null) _scrollController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedSwitcher(
      duration: widget.transitionDuration,
      child: widget.items.isEmpty ? _buildEmpty(context) : _buildContent(context),
    );

    if (widget.onRefresh == null) return content;
    return RefreshIndicator(onRefresh: widget.onRefresh!, child: content);
  }

  Widget _buildEmpty(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('empty'),
      child: widget.emptyBuilder?.call(context) ?? const LucidEmptyState(),
    );
  }

  Widget _buildContent(BuildContext context) {
    return KeyedSubtree(key: const ValueKey('content'), child: _buildForMode(context));
  }

  Widget _buildForMode(BuildContext context) {
    switch (widget.mode) {
      case LucidListMode.list:
        return _buildList(context);
      case LucidListMode.grid:
        return _buildGrid(context);
      case LucidListMode.carousel:
        return _buildCarousel(context);
    }
  }

  Widget _buildList(BuildContext context) {
    final itemCount = widget.items.length + (widget.isLoadingMore ? 1 : 0);

    Widget buildAt(BuildContext context, int index) {
      if (index >= widget.items.length) {
        return widget.loadingMoreBuilder?.call(context) ?? const _LucidDefaultLoadingMore();
      }
      return widget.itemBuilder(context, widget.items[index], index);
    }

    if (widget.separatorBuilder != null) {
      return ListView.separated(
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        padding: widget.padding,
        physics: widget.physics,
        itemCount: itemCount,
        separatorBuilder: widget.separatorBuilder!,
        itemBuilder: buildAt,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      physics: widget.physics,
      itemCount: itemCount,
      itemBuilder: buildAt,
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      physics: widget.physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) => widget.itemBuilder(context, widget.items[index], index),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: widget.scrollDirection,
      onPageChanged: widget.onPageChanged,
      itemCount: widget.items.length,
      itemBuilder: (context, index) => widget.itemBuilder(context, widget.items[index], index),
    );
  }
}

class _LucidDefaultLoadingMore extends StatelessWidget {
  const _LucidDefaultLoadingMore();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }
}
