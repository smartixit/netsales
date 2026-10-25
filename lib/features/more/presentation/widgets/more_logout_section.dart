import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// قسم تسجيل الخروج ومعلومات الإصدار (MoreLogoutSection)
/// ============================================================================
class MoreLogoutSection extends StatelessWidget {
  final MoreController controller;

  const MoreLogoutSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        CustomButton.danger(
          text: 'تسجيل الخروج من الحساب',
          icon: Icons.logout_rounded,
          height: 48.h,
          onPressed: () => controller.confirmLogout(context),
        ),
        AppSpacing.vSm,
        Text(
          'NetSales Enterprise Engine v1.0.0 (Build 2026)',
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant.withValues(alpha: 0.5),
            letterSpacing: 0.2,
          ),
        ),
        AppSpacing.vLg,
      ],
    );
  }
}
