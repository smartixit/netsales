import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// Read-only account identity details backed by the authenticated profile.
class ProfileDetailsSection extends StatelessWidget {
  const ProfileDetailsSection({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بيانات الهوية',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.vXs,
          Text(
            'بيانات الحساب المسجلة لدى المنصة',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.vSm,
          CustomInfoListTile(
            title: Text('الاسم الكامل', style: AppTypography.labelMedium),
            subtitle: Text(profile.fullName),
            leading: _DetailIcon(icon: Icons.person_outline_rounded),
          ),
          Divider(height: 1, color: colors.outlineVariant.withValues(alpha: .5)),
          CustomInfoListTile(
            title: Text('رقم الهاتف', style: AppTypography.labelMedium),
            subtitle: Text(profile.phoneNumber),
            leading: _DetailIcon(icon: Icons.phone_iphone_rounded),
            trailing: const _VerifiedMark(label: 'أساسي'),
          ),
          Divider(height: 1, color: colors.outlineVariant.withValues(alpha: .5)),
          CustomInfoListTile(
            title: Text('البريد الإلكتروني', style: AppTypography.labelMedium),
            subtitle: Text(
              profile.hasEmail ? profile.email! : 'لم تتم إضافة بريد إلكتروني',
            ),
            leading: _DetailIcon(icon: Icons.alternate_email_rounded),
            trailing: profile.hasEmail
                ? const _VerifiedMark(label: 'مسجل')
                : null,
          ),
          if (profile.lastLoginAt != null &&
              profile.lastLoginAt!.trim().isNotEmpty) ...[
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: .5),
            ),
            CustomInfoListTile(
              title: Text('آخر تسجيل دخول', style: AppTypography.labelMedium),
              subtitle: Text(profile.lastLoginAt!),
              leading: _DetailIcon(icon: Icons.history_rounded),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailIcon extends StatelessWidget {
  const _DetailIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: colors.primary, size: 19.r),
    );
  }
}

class _VerifiedMark extends StatelessWidget {
  const _VerifiedMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 14.r, color: colors.success),
        SizedBox(width: 4.w),
        Text(
          label,
          style: AppTypography.badgeText.copyWith(color: colors.success),
        ),
      ],
    );
  }
}
