import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/carousels/custom_carousel_indicators.dart';

export 'package:netsales/widgets/carousels/custom_carousel_card.dart';
export 'package:netsales/widgets/carousels/custom_carousel_indicators.dart';

/// ودجت كاروسيل عامة ومستقلة وقابلة لإعادة الاستخدام بالكامل (CustomCarouselSlider)
/// مبنية على أساسات Flutter الأصلية دون أي حزم خارجية
/// تدعم التمرير الانسيابي، والعمق الحركي للبطاقات الجانبية، والمؤشرات التفاعلية
class CustomCarouselSlider<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int currentIndex;
  final ValueChanged<int>? onPageChanged;
  final double height;
  final double viewportFraction;
  final bool showIndicator;
  final PageController? controller;
  final WidgetBuilder? emptyBuilder;
  final double scaleFactor;
  final double inactiveOpacity;

  const CustomCarouselSlider({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.currentIndex = 0,
    this.onPageChanged,
    this.height = 208,
    this.viewportFraction = 0.88,
    this.showIndicator = true,
    this.controller,
    this.emptyBuilder,
    this.scaleFactor = 0.94,
    this.inactiveOpacity = 0.78,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }

    final safeIndex = currentIndex.clamp(0, items.length - 1);
    final pageController = controller ??
        PageController(
          initialPage: safeIndex,
          viewportFraction: viewportFraction,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: height.h,
          child: PageView.builder(
            controller: pageController,
            padEnds: true,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final isSelected = index == safeIndex;

              return AnimatedScale(
                scale: isSelected ? 1.0 : scaleFactor,
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : inactiveOpacity,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  child: itemBuilder(context, items[index], index),
                ),
              );
            },
          ),
        ),
        if (showIndicator && items.length > 1) ...[
          SizedBox(height: AppSpacing.sm),
          CustomCarouselIndicators(
            itemCount: items.length,
            currentIndex: safeIndex,
            onIndicatorTap: (index) {
              if (pageController.hasClients) {
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.fastOutSlowIn,
                );
              }
              onPageChanged?.call(index);
            },
          ),
        ],
      ],
    );
  }
}
