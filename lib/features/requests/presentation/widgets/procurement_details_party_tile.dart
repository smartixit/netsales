import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

class ProcurementDetailsPartyTile extends StatelessWidget {
  const ProcurementDetailsPartyTile({
    super.key,
    required this.roleLabel,
    required this.partyName,
    this.phoneNumber,
    this.logoUrl,
    required this.iconGradient,
  });

  final String roleLabel;
  final String partyName;
  final String? phoneNumber;
  final String? logoUrl;
  final List<Color> iconGradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          CustomAvatarBadge(
            imageUrl: logoUrl,
            initials: TextFormatter.avatarInitial(partyName),
            size: AvatarBadgeSize.sm,
            customDimension: 38.r,
            borderRadius: BorderRadius.circular(10.r),
            gradientColors: iconGradient,
            hasPulse: false,
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  roleLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  partyName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) ...[
            AppSpacing.hXs,
            CustomButton.icon(
              icon: Icons.phone_forwarded_rounded,
              tooltip: 'اتصال: $phoneNumber',
              backgroundColor: colors.surface,
              foregroundColor: colors.primary,
              borderColor: colors.outlineVariant.withValues(alpha: 0.4),
              onPressed: () => UrlLauncherService.callPhone(phoneNumber!.trim()),
            ),
          ],
        ],
      ),
    );
  }
}
