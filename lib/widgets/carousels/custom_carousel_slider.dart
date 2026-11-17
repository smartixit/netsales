import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/carousels/custom_carousel_indicators.dart';

export 'package:carousel_slider/carousel_slider.dart'
    show CarouselSliderController;
export 'package:netsales/widgets/carousels/custom_carousel_card.dart';
export 'package:netsales/widgets/carousels/custom_carousel_indicators.dart';

/// ودجت كاروسيل عامة ومستقلة وقابلة لإعادة الاستخدام بالكامل (CustomCarouselSlider)
/// مبنية كغلاف نظيف وموحد لحزمة carousel_slider المعتمدة
/// تدعم التوسيط التلقائي، والعمق الحركي للبطاقات الجانبية، والمؤشرات التفاعلية
class CustomCarouselSlider<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int currentIndex;
  final ValueChanged<int>? onPageChanged;
  final double height;
  final double viewportFraction;
  final bool showIndicator;
  final bool enableInfiniteScroll;
  final bool autoPlay;
  final bool enlargeCenterPage;
  final CarouselSliderController? carouselController;
  final WidgetBuilder? emptyBuilder;

  const CustomCarouselSlider({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.currentIndex = 0,
    this.onPageChanged,
    this.height = 208,
    this.viewportFraction = 0.88,
    this.showIndicator = true,
    this.enableInfiniteScroll = false,
    this.autoPlay = false,
    this.enlargeCenterPage = true,
    this.carouselController,
    this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }

    final safeIndex = currentIndex.clamp(0, items.length - 1);
    final controller = carouselController ?? CarouselSliderController();

    return Container(
      clipBehavior: Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CarouselSlider.builder(
            carouselController: controller,
            itemCount: items.length,
            options: CarouselOptions(
              height: height.h,
              viewportFraction: viewportFraction,
              initialPage: safeIndex,
              enableInfiniteScroll: enableInfiniteScroll,
              autoPlay: autoPlay,
              enlargeCenterPage: enlargeCenterPage,
              enlargeFactor: 0.16,
              scrollPhysics: const BouncingScrollPhysics(),
              padEnds: true,
              onPageChanged: (index, reason) {
                onPageChanged?.call(index);
              },
            ),
            itemBuilder: (context, index, realIndex) {
              return itemBuilder(context, items[index], index);
            },
          ),
          if (showIndicator && items.length > 1) ...[
            SizedBox(height: AppSpacing.sm),
            CustomCarouselIndicators(
              itemCount: items.length,
              currentIndex: safeIndex,
              onIndicatorTap: (index) {
                controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.fastOutSlowIn,
                );
                onPageChanged?.call(index);
              },
            ),
          ],
        ],
      ),
    );
  }
}
