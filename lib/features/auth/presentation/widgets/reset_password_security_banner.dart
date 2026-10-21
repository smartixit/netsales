import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// بطاقة التنبيه الأمني المؤسسي في أعلى شاشة تغيير كلمة المرور (ResetPasswordSecurityBanner)
class ResetPasswordSecurityBanner extends StatelessWidget {
  final bool isForced;

  const ResetPasswordSecurityBanner({
    super.key,
    required this.isForced,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isForced
            ? colors.warning.withValues(alpha: 0.12)
            : colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isForced
              ? colors.warning.withValues(alpha: 0.3)
              : colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isForced
                  ? colors.warning.withValues(alpha: 0.2)
                  : colors.primary.withValues(alpha: 0.15),
            ),
            child: Icon(
              isForced ? Icons.shield_outlined : Icons.lock_reset_rounded,
              color: isForced ? colors.warning : colors.primary,
              size: 24.r,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isForced
                      ? 'مطلوب تعيين كلمة مرور جديدة'
                      : 'تحديث كلمة المرور لحسابك',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  isForced
                      ? 'تم تسجيل الدخول باستخدام كلمة مرور مؤقتة عبر الرسائل القصيرة. لحماية بياناتك وعملياتك، يُلزم النظام تعيين كلمة مرور جديدة قبل المتابعة.'
                      : 'احرص على اختيار كلمة مرور قوية وغير مستخدمة في تطبيقات أخرى.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}
