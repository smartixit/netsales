import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';

class ProfileMembershipsSection extends StatelessWidget {
  const ProfileMembershipsSection({super.key, required this.memberships});

  final List<ProfileMembershipEntity> memberships;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'عضويات مساحات العمل',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        AppSpacing.vSm,
        if (memberships.isEmpty)
          Text(
            'لا توجد عضويات مساحة عمل مرفقة ببيانات الحساب.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          )
        else
          ...memberships.map((membership) {
            final isNetwork = membership.scope.toUpperCase() == 'NETWORK';

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isNetwork
                            ? Icons.hub_outlined
                            : Icons.storefront_outlined,
                        color: colors.primary,
                        size: 22.r,
                      ),
                    ),
                    AppSpacing.hMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            membership.scopeLabel,
                            style: AppTypography.labelLarge.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            membership.roleName.isEmpty
                                ? membership.roleKey
                                : membership.roleName,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            'معرّف مساحة العمل: ${membership.tenantId}',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
