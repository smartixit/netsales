import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// مركز الأمان والحماية التنفيذي في واجهة البروفايل
class ProfileSecuritySection extends StatelessWidget {
  const ProfileSecuritySection({
    super.key,
    required this.profile,
    required this.onOpenSecurity,
    required this.onOpenSessions,
  });

  final ProfileEntity profile;
  final VoidCallback onOpenSecurity;
  final VoidCallback onOpenSessions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isProtected = profile.twoFactorEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Text(
          'مركز الأمان والحماية',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        SizedBox(height: AppSpacing.sm),

        // 1. كرت المصادقة الثنائية (2FA)
        CustomSurfaceCard(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          backgroundColor: colors.surfaceContainerLow,
          borderColor: colors.outlineVariant.withValues(alpha: 0.4),
          onTap: onOpenSecurity,
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: (isProtected ? colors.success : colors.warning)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  isProtected ? Icons.shield_rounded : Icons.shield_outlined,
                  color: isProtected ? colors.success : colors.warning,
                  size: 22.r,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المصادقة الثنائية',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isProtected ? 'محمي — طبقة تحقق إضافية' : 'غير مفعلة',
                      style: AppTypography.bodySmall.copyWith(
                        color: isProtected
                            ? colors.success
                            : colors.onSurfaceVariant,
                        fontWeight: isProtected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (isProtected ? colors.success : colors.warning)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  isProtected ? 'محمي' : 'يحتاج تفعيل',
                  style: AppTypography.labelSmall.copyWith(
                    color: isProtected ? colors.success : colors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.sm),

        // 2. كرت كلمة المرور
        CustomSurfaceCard(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          backgroundColor: colors.surfaceContainerLow,
          borderColor: colors.outlineVariant.withValues(alpha: 0.4),
          onTap: onOpenSecurity,
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.key_rounded,
                  color: colors.primary,
                  size: 22.r,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كلمة المرور',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      profile.mustChangePassword
                          ? 'يلزم تحديث كلمة المرور'
                          : 'تأمين تسجيل الدخول وتحديث الرمز',
                      style: AppTypography.bodySmall.copyWith(
                        color: profile.mustChangePassword
                            ? colors.warning
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'تحديث',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13.r,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.sm),

        // 3. كرت الجلسات والأجهزة المصرح بها
        CustomSurfaceCard(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          backgroundColor: colors.surfaceContainerLow,
          borderColor: colors.outlineVariant.withValues(alpha: 0.4),
          onTap: onOpenSessions,
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: colors.skyAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.devices_rounded,
                  color: colors.skyAccent,
                  size: 22.r,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الجلسات والأجهزة',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'مراجعة الجلسات والأجهزة المصرح بها',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'مراجعة',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.skyAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13.r,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
