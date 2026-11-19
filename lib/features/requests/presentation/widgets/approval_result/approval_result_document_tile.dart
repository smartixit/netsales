import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class ApprovalResultDocumentTile extends StatelessWidget {
  const ApprovalResultDocumentTile({
    super.key,
    required this.title,
    required this.uuid,
    required this.icon,
    this.isPrimary = false,
  });

  final String title;
  final String uuid;
  final IconData icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            color: isPrimary
                ? colors.primary.withValues(alpha: 0.12)
                : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 16.r,
              color: isPrimary ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ),
        AppSpacing.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
              Text(
                uuid,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: isPrimary ? colors.primary : colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        CustomInteractiveBounce(
          onTap: () {
            UrlLauncherService.copyToClipboard(
              uuid,
              confirmationMessage: 'تم النسخ للحافظة',
            );
            CustomSnackbar.show(
              title: 'تم النسخ',
              message: 'تم نسخ $uuid للحافظة',
              type: SnackType.info,
            );
          },
          child: Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.copy_rounded,
              size: 13.r,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
