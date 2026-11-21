import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

/// واجهة سفلية تصريحية بحتة لعرض الملف التعريفي للعضو (Member Details Presentation Sheet)
class MemberDetailsSheet extends StatelessWidget {
  const MemberDetailsSheet({
    super.key,
    required this.member,
    required this.onClose,
  });

  final WorkspaceMemberEntity member;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = EnumPresentationRegistry.resolveMembershipStatus(
      member.status,
      serverLabel: member.statusLabel,
    );
    final role = EnumPresentationRegistry.resolveRoleKey(
      member.typedRoleKey,
      serverLabel: member.displayRoleName,
    );

    final avatarInitials = TextFormatter.avatarInitials(
      member.displayFullName,
      fallback: 'ع',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              CustomAvatarBadge(
                imageUrl: member.user?.profilePictureUrl,
                initials: avatarInitials,
                size: AvatarBadgeSize.lg,
              ),
              AppSpacing.vSm,
              Text(
                member.displayFullName,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                member.displayPhoneNumber,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              AppSpacing.vSm,
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                alignment: WrapAlignment.center,
                children: [
                  CustomStatusBadge(
                    label: status.label,
                    tone: status.tone,
                    icon: status.icon,
                  ),
                  CustomStatusBadge(
                    label: role.label,
                    tone: role.tone,
                    icon: role.icon,
                  ),
                  if (member.isOwner)
                    const CustomStatusBadge(
                      label: 'المالك المعتمد',
                      tone: SemanticTone.primary,
                      icon: Icons.verified_user_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.vLg,
        CustomSurfaceCard(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              CustomInfoListTile(
                leading: Icon(
                  Icons.fingerprint_rounded,
                  size: 20.r,
                  color: colors.onSurfaceVariant,
                ),
                title: Text(
                  'معرف المستخدم',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                trailing: Text(
                  member.displayReference,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: colors.outlineVariant.withValues(alpha: .3),
              ),
              CustomInfoListTile(
                leading: Icon(
                  Icons.phone_outlined,
                  size: 20.r,
                  color: colors.onSurfaceVariant,
                ),
                title: Text(
                  'رقم الهاتف',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                trailing: Text(
                  member.displayPhoneNumber,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (member.user?.email != null &&
                  member.user!.email!.isNotEmpty) ...[
                Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: .3),
                ),
                CustomInfoListTile(
                  leading: Icon(
                    Icons.email_outlined,
                    size: 20.r,
                    color: colors.onSurfaceVariant,
                  ),
                  title: Text(
                    'البريد الإلكتروني',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  trailing: Text(
                    member.user!.email!,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
              Divider(
                height: 1,
                color: colors.outlineVariant.withValues(alpha: .3),
              ),
              CustomInfoListTile(
                leading: Icon(
                  Icons.calendar_today_outlined,
                  size: 20.r,
                  color: colors.onSurfaceVariant,
                ),
                title: Text(
                  'تاريخ الانضمام',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                trailing: Text(
                  member.formattedJoinedDate,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vLg,
        CustomButton.primary(text: 'إغلاق', onPressed: onClose),
      ],
    );
  }
}
