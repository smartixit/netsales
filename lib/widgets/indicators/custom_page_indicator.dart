import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';

/// مؤشر صفحات متمدد وناعم قابل لإعادة الاستخدام (CustomPageIndicator)
/// يُستخدم في جولات التعريف، السلايدرز، وأي عرض متعدد الخطوات.
class CustomPageIndicator extends StatelessWidget {
  const CustomPageIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.activeWidth,
    this.inactiveWidth,
    this.height,
  });

  /// إجمالي عدد الصفحات
  final int itemCount;

  /// فهرس الصفحة الحالية النشطة
  final int currentIndex;

  /// عرض النقطة النشطة المتمددة
  final double? activeWidth;

  /// عرض النقطة غير النشطة
  final double? inactiveWidth;

  /// ارتفاع المؤشر
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final actW = activeWidth ?? 24.w;
    final inactW = inactiveWidth ?? 7.w;
    final h = height ?? 6.h;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;

        return AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.emphasized,
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          height: h,
          width: isActive ? actW : inactW,
          decoration: BoxDecoration(
            color: isActive
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        );
      }),
    );
  }
}
