import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// Security posture summary with actions backed by existing security flows.
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

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حماية الحساب',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.vXs,
          Text(
            'إدارة وسائل الحماية ومراجعة الأجهزة التي تستخدم حسابك.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.vMd,
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: (isProtected ? colors.success : colors.warning)
                  .withValues(alpha: .08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: (isProtected ? colors.success : colors.warning)
                    .withValues(alpha: .24),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isProtected
                      ? Icons.shield_rounded
                      : Icons.shield_outlined,
                  color: isProtected ? colors.success : colors.warning,
                  size: 28.r,
                ),
                AppSpacing.hSm,
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
                      AppSpacing.vXxs,
                      Text(
                        isProtected
                            ? 'مفعلة — طبقة تحقق إضافية تحمي تسجيل الدخول.'
                            : 'غير مفعلة — أضف طبقة حماية إضافية لحسابك.',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomStatusBadge(
                  label: isProtected ? 'محمّي' : 'يحتاج إجراء',
                  tone: isProtected
                      ? SemanticTone.success
                      : SemanticTone.warning,
                  isCompact: true,
                ),
              ],
            ),
          ),
          if (profile.mustChangePassword) ...[
            AppSpacing.vSm,
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.priority_high_rounded,
                      color: colors.warning, size: 18.r),
                  AppSpacing.hXs,
                  Expanded(
                    child: Text(
                      'يلزم تحديث كلمة المرور قبل متابعة استخدام الحساب.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          AppSpacing.vMd,
          Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'إعدادات الأمان',
                  icon: Icons.security_rounded,
                  onPressed: onOpenSecurity,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomButton.secondary(
                  text: 'الأجهزة والجلسات',
                  icon: Icons.devices_rounded,
                  onPressed: onOpenSessions,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
