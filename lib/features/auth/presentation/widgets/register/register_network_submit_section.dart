import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/register_network_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// قسم زر إرسال طلب التسجيل وروابط التوجيه (RegisterSubmitSection)
class RegisterNetworkSubmitSection extends StatelessWidget {
  final RegisterNetworkController controller;

  const RegisterNetworkSubmitSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          return CustomButton.primary(
            text: 'إرسال طلب التسجيل',
            icon: Icons.app_registration_rounded,
            iconSize: 20.r,
            loading: controller.isLoading.value,
            onPressed: controller.submitRegistration,
          );
        }),
        AppSpacing.vLg,
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xs,
          children: [
            Text(
              'لديك حساب مزود شبكة مسبقاً؟',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            CustomButton.text(
              text: 'تسجيل الدخول',
              onPressed: controller.goToLogin,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 550.ms);
  }
}
