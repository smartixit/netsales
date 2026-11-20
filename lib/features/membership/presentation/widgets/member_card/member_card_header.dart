import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// ترويسة بطاقة عضو المنشأة (MemberCardHeader)
///
/// ودجت عرض نقي يستهلك مباشرة محرك تمثيل الحالات الموحد [CustomStatusBadge.fromPresentation]
class MemberCardHeader extends StatelessWidget {
  const MemberCardHeader({
    super.key,
    required this.member,
    this.isExpanded = false,
    this.onToggleExpansion,
  });

  final WorkspaceMemberEntity member;
  final bool isExpanded;
  final VoidCallback? onToggleExpansion;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final presentation = EnumPresentationRegistry.resolveMembershipStatus(
      member.status,
      serverLabel: member.statusLabel,
    );

    return InkWell(
      onTap: onToggleExpansion,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // الأفاتار أو الحروف الأولى للعضو
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: member.isOwner
                    ? colors.emeraldDeep.withValues(alpha: .12)
                    : colors.primary.withValues(alpha: .1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: member.isOwner
                      ? colors.emeraldDeep.withValues(alpha: .3)
                      : colors.primary.withValues(alpha: .2),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                member.displayInitials,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: member.isOwner ? colors.emeraldDeep : colors.primary,
                ),
              ),
            ),
            AppSpacing.hSm,

            // تفاصيل العضو (الاسم، الهاتف، والدور)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.fullName,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (member.isOwner) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.emeraldDeep.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 12.r,
                                color: colors.emeraldDeep,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'المالك',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.emeraldDeep,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => UrlLauncherService.copyToClipboard(
                          member.phoneNumber,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 13.r,
                              color: colors.onSurfaceVariant,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              member.phoneNumber,
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (member.roleLabel != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            member.roleLabel!,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // شارة الحالة من مسجل التمثيل المعتمد مباشرة عبر fromPresentation
            CustomStatusBadge.fromPresentation(presentation),
          ],
        ),
      ),
    );
  }
}
