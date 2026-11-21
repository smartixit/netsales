import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// Actionable overview of the account's authorized operational memberships.
class ProfileMembershipsSection extends StatelessWidget {
  const ProfileMembershipsSection({
    super.key,
    required this.memberships,
    required this.onOpenMembership,
  });

  final List<ProfileMembershipEntity> memberships;
  final ValueChanged<ProfileMembershipEntity> onOpenMembership;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'مساحات العمل',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              CustomChip(
                label: '${memberships.length} عضوية',
                icon: Icons.hub_outlined,
                isCompact: true,
              ),
            ],
          ),
          AppSpacing.vXs,
          Text(
            'اختر مساحة عمل للانتقال إلى بيئتها التشغيلية.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.vMd,
          if (memberships.isEmpty)
            const _NoMemberships()
          else
            ...memberships.map(
              (membership) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: _MembershipCard(
                  membership: membership,
                  onTap: () => onOpenMembership(membership),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.membership,
    required this.onTap,
  });

  final ProfileMembershipEntity membership;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetwork = membership.scope == RoleScope.network;
    final role = EnumPresentationRegistry.resolveRoleKey(membership.roleKey);

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.md),
      backgroundColor: colors.surfaceContainerLow,
      borderColor: colors.outlineVariant.withValues(alpha: .55),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: (isNetwork ? colors.primary : colors.skyAccent)
                  .withValues(alpha: .12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isNetwork
                  ? Icons.router_rounded
                  : Icons.point_of_sale_rounded,
              color: isNetwork ? colors.primary : colors.skyAccent,
              size: 24.r,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membership.scopeLabel,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vXxs,
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    CustomChip(label: role.label, isCompact: true),
                    const CustomStatusBadge(
                      label: 'عضوية معتمدة',
                      tone: SemanticTone.success,
                      isCompact: true,
                    ),
                  ],
                ),
                AppSpacing.vXxs,
                Text(
                  'معرّف مساحة العمل: #${membership.tenantId}',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hXs,
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15.r,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _NoMemberships extends StatelessWidget {
  const _NoMemberships();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(Icons.domain_disabled_outlined, size: 30.r, color: colors.outline),
          AppSpacing.vSm,
          Text(
            'لا توجد عضويات تشغيلية مرتبطة بهذا الحساب.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
