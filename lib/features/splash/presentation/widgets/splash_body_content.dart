import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:netsales/core/constants/app_constants.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/brand/custom_brand_logo.dart';
import 'package:netsales/widgets/feedback/custom_loading_indicator_bar.dart';

/// المحتوى البصري المركزي لشاشة الإقلاع
///
/// ودجت نقية تماماً (Pure Declarative Widget):
/// - خالية من أي متحكمات أو منطق أعمال.
/// - تدعم التخزين الثابت (const constructor) لأعلى أداء لمحرك فلاتر.
class SplashBodyContent extends StatelessWidget {
  const SplashBodyContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 3),

          // 1. الشعار المركزي الموحد والهالة النابضة (CustomBrandLogo)
          const CustomBrandLogo.hero(withHalo: true),
          AppSpacing.vXl,

          // 2. اسم النظام الرسمي
          Text(
                AppConstants.appName,
                style: AppTypography.headlineMedium.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(duration: AppMotion.slow)
              .slideY(
                begin: 0.15,
                end: 0,
                duration: AppMotion.slow,
                curve: AppMotion.emphasized,
              ),
          AppSpacing.vSm,

          // 3. النص الوصفي
          Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  'المنظومة الذكية لإدارة مبيعات الشبكات ونقاط البيع',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              .animate()
              .fadeIn(duration: AppMotion.slow)
              .slideY(
                begin: 0.15,
                end: 0,
                duration: AppMotion.slow,
                curve: AppMotion.emphasized,
              ),

          const Spacer(flex: 3),

          // 4. شريط التحميل الانسيابي المتحرك في الأسفل
          const CustomLoadingIndicatorBar(),
          AppSpacing.vGiant,
          AppSpacing.vGiant,
        ],
      ),
    );
  }
}
