import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'premium_carousel_controller.dart';
import 'premium_carousel_options.dart';

/// Generic, design-system-neutral carousel for reuse in unrelated Flutter apps.
///
/// Cards remain owned by the consuming feature through [itemBuilder]. The
/// package only manages paging, gesture handling, optional load-more slot,
/// and a theme-aware page indicator.
class PremiumCarouselSlider<T> extends StatelessWidget {
  const PremiumCarouselSlider({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.options = const PremiumCarouselOptions(),
    this.currentIndex = 0,
    this.controller,
    this.onPageChanged,
    this.hasMoreItems = false,
    this.loadingItemBuilder,
    this.onLoadMore,
    this.showIndicator = true,
    this.indicatorBuilder,
    this.emptyBuilder,
    this.disableGesture = false,
  }) : assert(
         !hasMoreItems || loadingItemBuilder != null,
         'loadingItemBuilder is required when hasMoreItems is true.',
       );

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final PremiumCarouselOptions options;
  final int currentIndex;
  final PremiumCarouselController? controller;
  final ValueChanged<int>? onPageChanged;

  /// Adds a final in-carousel slot that can trigger cursor pagination.
  final bool hasMoreItems;
  final WidgetBuilder? loadingItemBuilder;
  final VoidCallback? onLoadMore;

  final bool showIndicator;
  final Widget Function(BuildContext context, int current, int total)?
  indicatorBuilder;
  final WidgetBuilder? emptyBuilder;
  final bool disableGesture;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }

    final hasTrailingLoader = hasMoreItems && loadingItemBuilder != null;
    final itemCount = items.length + (hasTrailingLoader ? 1 : 0);
    final safeInitialPage = options.initialPage < items.length
        ? options.initialPage
        : 0;
    final safeCurrentIndex = currentIndex.clamp(0, items.length - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: itemCount,
          carouselController: controller?.carouselController,
          disableGesture: disableGesture || items.length < 2,
          options: CarouselOptions(
            height: options.height,
            aspectRatio: options.aspectRatio,
            viewportFraction: options.viewportFraction,
            initialPage: safeInitialPage,
            enableInfiniteScroll:
                options.enableInfiniteScroll && !hasTrailingLoader && items.length > 1,
            reverse: options.reverse,
            autoPlay: options.autoPlay && items.length > 1 && !hasTrailingLoader,
            autoPlayInterval: options.autoPlayInterval,
            autoPlayAnimationDuration: options.autoPlayAnimationDuration,
            autoPlayCurve: options.autoPlayCurve,
            enlargeCenterPage: options.enlargeCenterPage,
            enlargeFactor: options.enlargeFactor,
            scrollDirection: options.scrollDirection,
            padEnds: options.padEnds,
            pageSnapping: options.pageSnapping,
            onPageChanged: (index, reason) {
              if (index >= items.length) {
                onLoadMore?.call();
                return;
              }
              onPageChanged?.call(index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            if (index >= items.length) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: options.itemSpacing / 2,
                ),
                child: loadingItemBuilder!(context),
              );
            }
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: options.itemSpacing / 2,
              ),
              child: itemBuilder(context, items[index], index),
            );
          },
        ),
        if (showIndicator && items.length > 1) ...[
          const SizedBox(height: 12),
          indicatorBuilder?.call(context, safeCurrentIndex, items.length) ??
              _PremiumCarouselIndicator(
                itemCount: items.length,
                currentIndex: safeCurrentIndex,
              ),
        ],
      ],
    );
  }
}

class _PremiumCarouselIndicator extends StatelessWidget {
  const _PremiumCarouselIndicator({
    required this.itemCount,
    required this.currentIndex,
  });

  final int itemCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
