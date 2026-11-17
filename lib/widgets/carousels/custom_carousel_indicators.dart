import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// مؤشر الصفحات التفاعلي الحركي للكاروسيل (CustomCarouselIndicators)
/// يتمدد بسلاسة لتمييز العنصر النشط ويدعم النقر المباشر للتبديل
class CustomCarouselIndicators extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final ValueChanged<int>? onIndicatorTap;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? activeWidth;
  final double? dotSize;

  const CustomCarouselIndicators({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.onIndicatorTap,
    this.activeColor,
    this.inactiveColor,
    this.activeWidth,
    this.dotSize,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) return const SizedBox.shrink();

    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveActiveColor = activeColor ?? colors.primary;
    final effectiveInactiveColor =
        inactiveColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.15)
            : colors.outlineVariant.withValues(alpha: 0.5));
    final effectiveDotSize = dotSize ?? 6.5.r;
    final effectiveActiveWidth = activeWidth ?? 22.w;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: CustomInteractiveBounce(
            onTap: onIndicatorTap != null ? () => onIndicatorTap!(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              height: effectiveDotSize,
              width: isActive ? effectiveActiveWidth : effectiveDotSize,
              decoration: BoxDecoration(
                color: isActive ? effectiveActiveColor : effectiveInactiveColor,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: effectiveActiveColor.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
