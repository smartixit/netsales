import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ترويسة شاشة التحقق بخطوتين وتأكيد الجهاز (TwoFactorHeaderSection)
class TwoFactorHeaderSection extends StatelessWidget {
  final String maskedPhone;

  const TwoFactorHeaderSection({
    super.key,
    required this.maskedPhone,
  });

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
            Icons.security_rounded,
            color: colors.primary,
            size: 40.r,
          ),
        ),
        AppSpacing.vMd,
        Text(
          'التحقق بخطوتين (2FA)',
          style: AppTypography.headlineSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vXs,
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
            children: [
              const TextSpan(
                text: 'تم إرسال رمز الأمان المكون من 6 أرقام إلى هاتفك\n',
              ),
              TextSpan(
                text: maskedPhone,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}
