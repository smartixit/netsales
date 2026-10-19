import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:netsales/core/constants/app_constants.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/splash/presentations/widgets/splash_flowing_progress_bar.dart';
import 'package:netsales/widgets/brand/custom_brand_logo.dart';

/// شاشة الإقلاع الرئيسية للنظام (Splash Screen)
/// واجهة عرض نقية (Lean View) خالية من أي منطق أعمال وتلتزم بنظام التصميم الموحد.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppGradients.surfaceMesh(context),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // 1. الشعار المركزي الموحد والهالة النابضة (CustomBrandLogo)
              const CustomBrandLogo.lg(withHalo: true),
              AppSpacing.vXl,

              // 2. اسم النظام الرسمي
              Text(
                AppConstants.appName,
                style: AppTypography.headlineMedium.copyWith(
                  color: colors.primary,
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
                    color: colors.onSurfaceVariant,
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
              const SplashFlowingProgressBar(),
              AppSpacing.vXxl,
            ],
          ),
        ),
      ),
    );
  }
}
