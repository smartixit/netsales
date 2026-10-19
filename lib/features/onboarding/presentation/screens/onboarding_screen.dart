import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:netsales/features/onboarding/presentation/widgets/onboarding_page_card.dart';
import 'package:netsales/widgets/brand/custom_brand_logo.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/indicators/custom_page_indicator.dart';

/// واجهة جولة التعريف التفاعلية (Onboarding Screen)
class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

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
          child: ResponsiveContentWrapper(
            maxWidth: AppBreakpoints.maxFormWidth,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: Column(
            children: [
              // 1. الشريط العلوي: الشعار المصغر وزر التخطي السريع
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // شارة وشعار النظام الموحد
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomBrandLogo.sm(),
                        AppSpacing.hSm,
                        Text(
                          'NetSales',
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    // زر التخطي السريع
                    CustomButton.text(
                      text: 'تخطي',
                      onPressed: controller.skip,
                    ),
                  ],
                ),
              ),

              // 2. جسم صفحات التعريف (PageView)
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.items.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return OnboardingPageCard(
                      item: controller.items[index],
                    );
                  },
                ),
              ),

              // 3. شريط التنقل السفلي والمؤشرات الموحدة
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Obx(() {
                  final isLast = controller.isLastPage;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // مؤشر النقاط التفاعلي الموحد (CustomPageIndicator)
                      CustomPageIndicator(
                        itemCount: controller.items.length,
                        currentIndex: controller.currentPage.value,
                      ),
                      AppSpacing.vLg,

                      // زر المتابعة أو البدء
                      CustomButton.primary(
                        text: isLast ? 'ابدأ الآن' : 'التالي',
                        icon: Icons.arrow_back_rounded,
                        onPressed: controller.nextPage,
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
