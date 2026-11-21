import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// تفاصيل المحتوى الترحيبي داخل بطاقة الترحيب القيادية (WorkspaceWelcomeDetails)
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. هوية المستخدم والأفاتار
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomAvatarBadge(
              imageUrl: userAvatarUrl,
              initials: userInitials,
              size: AvatarBadgeSize.md,
              customDimension: 46.r,
              hasPulse: false,
              borderRadius: BorderRadius.circular(AppRadius.full),
              gradientColors: const [Color(0xFFFFE7AD), Color(0xFFE7B45D)],
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بعودتك',
                    maxLines: 1,
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
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // 2. شارة الدور ونقطة حالة الجلسة
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_rounded,
              size: 14.r,
              color: Colors.white.withValues(alpha: 0.92),
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.90),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 3.r,
              height: 3.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'جلسة نشطة',
              maxLines: 1,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ],
        ),

        // 3. التاريخ الحالي إن وجد
        if (dateText != null) ...[
          SizedBox(height: 6.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 14.r,
                color: Colors.white.withValues(alpha: 0.92),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  dateText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],

        // 4. زر الإجراء التفاعلي (مثل ربط شبكة لنقطة البيع)
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: 10.h),
          CustomInteractiveBounce(
            onTap: onAction,
            child: Container(
              constraints: BoxConstraints(minHeight: 35.h),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: const Color(0xFF63E6D0).withValues(alpha: 0.85),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 18.r,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    actionLabel!,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
