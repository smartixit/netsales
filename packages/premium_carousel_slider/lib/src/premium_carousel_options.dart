import 'package:flutter/widgets.dart';

/// Presentation options shared by all consumers of the reusable carousel.
class PremiumCarouselOptions {
  const PremiumCarouselOptions({
    this.height = 190,
    this.aspectRatio = 16 / 9,
    this.viewportFraction = 0.88,
    this.itemSpacing = 8,
    this.initialPage = 0,
    this.enableInfiniteScroll = false,
    this.reverse = false,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 700),
    this.autoPlayCurve = Curves.easeInOutCubic,
    this.enlargeCenterPage = false,
    this.enlargeFactor = 0.12,
    this.scrollDirection = Axis.horizontal,
    this.padEnds = true,
    this.pageSnapping = true,
  })  : assert(height == null || height > 0),
        assert(aspectRatio > 0),
        assert(viewportFraction > 0 && viewportFraction <= 1),
        assert(itemSpacing >= 0),
        assert(initialPage >= 0),
        assert(enlargeFactor >= 0 && enlargeFactor <= 1);

  final double? height;
  final double aspectRatio;
  final double viewportFraction;
  final double itemSpacing;
  final int initialPage;
  final bool enableInfiniteScroll;
  final bool reverse;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;
  final Curve autoPlayCurve;
  final bool enlargeCenterPage;
  final double enlargeFactor;
  final Axis scrollDirection;
  final bool padEnds;
  final bool pageSnapping;
}
