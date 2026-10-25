import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/interactions/custome_theme_switcher.dart';

/// ============================================================================
/// زر تبديل المظهر التفاعلي بأسلوب تليجرام (Telegram-Style Theme Toggle Button)
/// ============================================================================
/// يطلق حركة انتشار دائرية خاطفة (Circular Reveal) تنبثق من موقع الزر
/// وتتسع لتغطي الشاشة كاملة، مع ارتداد فيزيائي ناعم ودوران الأيقونة.
class CustomThemeToggleButton extends StatelessWidget {
  final double? size;
  final EdgeInsetsGeometry? padding;

  const CustomThemeToggleButton({super.key, this.size, this.padding});

  void _onTap(BuildContext context) {
    final switcher = CustomThemeSwitcher.of(context);

    if (switcher != null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      final origin = renderBox != null
          ? renderBox.localToGlobal(renderBox.size.center(Offset.zero))
          : Offset.zero;

      switcher.switchTheme(
        origin: origin,
        onThemeChange: ThemeService.to.toggleTheme,
      );
    } else {
      ThemeService.to.toggleTheme();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.to;

    return Obx(() {
      final isDark = themeService.isDarkMode;
      final colors = context.colors;

      return CustomInteractiveBounce(
        onTap: () => _onTap(context),
        child: Tooltip(
          message: isDark
              ? 'التبديل إلى الوضع الفاتح'
              : 'التبديل إلى الوضع الداكن',
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
