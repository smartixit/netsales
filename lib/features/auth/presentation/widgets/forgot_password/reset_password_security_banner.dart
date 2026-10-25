import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// شارة التنبيه الأمني المؤسسي الأنيقة في شاشة تعيين كلمة المرور
class ResetPasswordSecurityBanner extends StatelessWidget {
  const ResetPasswordSecurityBanner({
    super.key,
    required this.isForced,
    this.isDirectReset = false,
  });

  final bool isForced;
  final bool isDirectReset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isWarning = isForced && !isDirectReset;

    final title = isDirectReset
        ? 'تعيين كلمة مرور جديدة'
        : (isForced
            ? 'مطلوب تعيين كلمة مرور جديدة'
            : 'تحديث كلمة المرور لحسابك');

    final subtitle = isDirectReset
        ? 'أدخل كلمة مرور قوية وجديدة لحسابك للمتابعة.'
        : (isForced
            ? 'تم الدخول بكلمة مؤقتة، يُلزم النظام تعيين كلمة مرور شخصية للمتابعة.'
            : 'احرص على اختيار كلمة مرور قوية لحماية حسابك.');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isWarning
            ? colors.warningContainer.withValues(alpha: 0.35)
            : colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isWarning
              ? colors.warning.withValues(alpha: 0.25)
              : colors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWarning
                  ? colors.warning.withValues(alpha: 0.15)
                  : colors.primary.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Icon(
              isWarning ? Icons.shield_outlined : Icons.lock_reset_rounded,
              color: isWarning ? colors.warning : colors.primary,
              size: 20.r,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppMotion.normal)
        .slideY(
          begin: -0.08,
          end: 0,
          curve: AppMotion.emphasized,
        );
  }
}
