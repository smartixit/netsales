import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ترويسة شاشة طلب استعادة كلمة المرور (ForgotPasswordHeaderSection)
class ForgotPasswordHeaderSection extends StatelessWidget {
  const ForgotPasswordHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Container(
          width: 80.r,
          height: 80.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.2),
              width: 2.w,
            ),
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            color: colors.primary,
            size: 40.r,
          ),
        ),
        AppSpacing.vMd,
        Text(
          'نسيت كلمة المرور؟',
          style: AppTypography.headlineSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vXs,
        Text(
          'أدخل رقم هاتفك المسجل في النظام، وسنرسل لك رمز تحقق مؤقت (OTP) لتأكيد هويتك واستعادة الحساب.',
          style: AppTypography.bodyMedium.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}
