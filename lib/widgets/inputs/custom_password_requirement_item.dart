import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// عنصر متناسق لعرض شروط ومعايير قوة كلمة المرور بالاعتماد الكامل على ScreenUtil
class CustomPasswordRequirementItem extends StatelessWidget {
  const CustomPasswordRequirementItem({
    super.key,
    required this.isValid,
    required this.label,
  });

  final bool isValid;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isValid
                  ? colors.success.withValues(alpha: 0.15)
                  : colors.outlineVariant.withValues(alpha: 0.3),
            ),
            child: Icon(
              isValid ? Icons.check_rounded : Icons.circle_outlined,
              size: 13.r,
              color: isValid ? colors.success : colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.hSm,
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isValid ? colors.success : colors.onSurfaceVariant,
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
