import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class ProfileSecuritySection extends StatelessWidget {
  const ProfileSecuritySection({
    super.key,
    required this.profile,
    required this.onOpenSecuritySettings,
    required this.onOpenActiveSessions,
  });

  final ProfileEntity profile;
  final VoidCallback onOpenSecuritySettings;
  final VoidCallback onOpenActiveSessions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final securityColor = profile.twoFactorEnabled
        ? colors.success
        : colors.warning;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أمان الحساب',
            style: AppTypography.titleSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: securityColor,
                size: 22.r,
              ),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'المصادقة الثنائية',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                profile.twoFactorEnabled ? 'مفعّلة' : 'غير مفعّلة',
                style: AppTypography.labelMedium.copyWith(
                  color: securityColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          CustomButton.outline(
            text: 'إعدادات الأمان',
            icon: Icons.security_rounded,
            width: double.infinity,
            onPressed: onOpenSecuritySettings,
          ),
          AppSpacing.vSm,
          CustomButton.outline(
            text: 'الأجهزة والجلسات النشطة',
            icon: Icons.devices_rounded,
            width: double.infinity,
            onPressed: onOpenActiveSessions,
          ),
        ],
      ),
    );
  }
}
