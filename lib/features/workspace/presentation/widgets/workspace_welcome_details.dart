import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

class WorkspaceWelcomeDetails extends StatelessWidget {
  const WorkspaceWelcomeDetails({
    super.key,
    required this.userName,
    required this.userAvatarUrl,
    required this.userInitials,
    required this.role,
    this.dateText,
    this.actionLabel,
    this.onAction,
  });

  final String userName;
  final String? userAvatarUrl;
  final String userInitials;
  final String role;
  final String? dateText;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomAvatarBadge(
              imageUrl: userAvatarUrl,
              initials: userInitials,
              size: AvatarBadgeSize.md,
              customDimension: 44,
              hasPulse: false,
              borderRadius: BorderRadius.circular(AppRadius.full),
              gradientColors: const [Color(0xFFFFE7AD), Color(0xFFE7B45D)],
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'مرحباً بعودتك',
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: AppTypography.titleSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.94),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 7.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.90),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 5.w),
            Icon(
              Icons.verified_user_rounded,
              size: 13.r,
              color: Colors.white.withValues(alpha: 0.92),
            ),
            SizedBox(width: 7.w),
            Container(
              width: 3.r,
              height: 3.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 7.w),
            Text(
              'جلسة نشطة',
              maxLines: 1,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ],
        ),
        if (dateText != null) ...[
          SizedBox(height: 9.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  dateText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.calendar_month_rounded,
                size: 14.r,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ],
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: 10.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CustomInteractiveBounce(
              onTap: onAction,
              child: Container(
                constraints: BoxConstraints(minHeight: 35.h),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: const Color(0xFF63E6D0).withValues(alpha: 0.82),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 19.r,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
