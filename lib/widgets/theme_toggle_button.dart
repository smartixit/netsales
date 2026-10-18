import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/widgets/custom_interactive_bounce.dart';

/// ============================================================================
/// زر تبديل المظهر التفاعلي (Animated 1-Click Theme Toggle Button)
/// ============================================================================
/// يوفر حركة انسيابية مبهجة مستندة لنظام الحركة الموحد [AppMotion] مع ارتداد
/// فيزيائي ناعم (Bounce) لتبديل المظهر بين الفاتح والداكن بنقرة واحدة.
class ThemeToggleButton extends StatelessWidget {
  final double? size;
  final EdgeInsetsGeometry? padding;

  const ThemeToggleButton({
    super.key,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.to;

    return Obx(() {
      final isDark = themeService.isDarkMode;
      final colors = context.colors;

      return CustomInteractiveBounce(
        onTap: themeService.toggleTheme,
        child: Tooltip(
          message: isDark ? 'التبديل إلى الوضع الفاتح' : 'التبديل إلى الوضع الداكن',
          child: Container(
            padding: padding ?? EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: AnimatedSwitcher(
              duration: AppMotion.duration(context, AppMotion.slow),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.75, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: AppMotion.springy,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: AppMotion.standard,
                    ),
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: animation,
                        curve: AppMotion.emphasized,
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDark),
                size: size ?? 22.r,
                color: isDark ? colors.warning : colors.primary,
              ),
            ),
          ),
        ),
      );
    });
  }
}
