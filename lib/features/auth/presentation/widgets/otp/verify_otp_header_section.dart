import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// قسم ترويسة شاشة التحقق OTP الهندسية
class VerifyOtpHeaderSection extends StatelessWidget {
  const VerifyOtpHeaderSection({
    super.key,
    required this.maskedPhone,
    this.onChangePhone,
  });

  final String maskedPhone;
  final VoidCallback? onChangePhone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. أيقونة الرمز الهندسية المعتمدة
        Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(Icons.sms_rounded, color: colors.primary, size: 28.r),
            )
            .animate()
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: AppMotion.normal,
              curve: AppMotion.springy,
            )
            .fadeIn(duration: AppMotion.normal),

        AppSpacing.vMd,

        // 2. العنوان الرئيسي
        Text(
              'رمز التحقق',
              style: AppTypography.headlineMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(duration: AppMotion.normal)
            .slideY(
              begin: 0.15,
              end: 0,
              duration: AppMotion.normal,
              curve: AppMotion.emphasized,
            ),

        AppSpacing.vXs,

        // 3. النص الإرشادي الهادئ ورقم الهاتف المقنع
        Text(
              'تم إرسال رمز التحقق المكون من 6 أرقام إلى',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(duration: AppMotion.normal)
            .slideY(
              begin: 0.15,
              end: 0,
              duration: AppMotion.normal,
              curve: AppMotion.emphasized,
            ),

        AppSpacing.vXxs,

        Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  maskedPhone,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                if (onChangePhone != null) ...[
                  AppSpacing.hXs,
                  CustomButton.text(
                    text: 'تغيير الرقم',
                    onPressed: onChangePhone,
                    // foregroundColor: colors.onSurfaceVariant,
                    // textStyle: AppTypography.labelMedium.copyWith(
                    //   fontWeight: FontWeight.w600,
                    //   decoration: TextDecoration.underline,
                    // ),
                    // padding: EdgeInsets.symmetric(
                    //   horizontal: AppSpacing.xxs,
                    //   vertical: AppSpacing.xxs,
                    // ),
                  ),
                ],
              ],
            )
            .animate()
            .fadeIn(duration: AppMotion.normal)
            .slideY(
              begin: 0.15,
              end: 0,
              duration: AppMotion.normal,
              curve: AppMotion.emphasized,
            ),
      ],
    );
  }
}
