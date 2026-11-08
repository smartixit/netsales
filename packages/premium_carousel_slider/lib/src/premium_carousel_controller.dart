import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

/// Programmatic controls for [PremiumCarouselSlider].
///
/// Keep one controller in the owner's state controller and reuse it while the
/// carousel is mounted. The wrapper deliberately exposes no GetX dependency.
class PremiumCarouselController {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  CarouselSliderController get carouselController => _carouselController;

  Future<void> nextPage({
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeOutCubic,
  }) {
    return _carouselController.nextPage(duration: duration, curve: curve);
  }

  Future<void> previousPage({
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeOutCubic,
  }) {
    return _carouselController.previousPage(duration: duration, curve: curve);
  }

  Future<void> animateToPage(
    int page, {
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeOutCubic,
  }) {
    return _carouselController.animateToPage(
      page,
      duration: duration,
      curve: curve,
    );
  }

  void jumpToPage(int page) {
    _carouselController.jumpToPage(page);
  }

  void startAutoPlay() => _carouselController.startAutoPlay();

  void stopAutoPlay() => _carouselController.stopAutoPlay();
}
