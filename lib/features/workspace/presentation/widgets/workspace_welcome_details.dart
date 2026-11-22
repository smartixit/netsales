import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/greeting_formatter.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

/// تفاصيل المحتوى الترحيبي القيادي الموحد (WorkspaceWelcomeDetails)
///
/// مبني بالكامل على المكونات المعيارية والرموز المركزية من lib/core و lib/widgets:
/// - نصوص وتيبوغرافي: [AppTypography] و [GreetingFormatter]
/// - ألوان وهوية: [AppColors] (context.colors)
/// - مسافات وهوامش: [AppSpacing] و [AppRadius]
/// - شارات وأزرار ومؤشرات: [CustomChip], [CustomStatusBadge], [CustomButton], [CustomAvatarBadge]
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
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. رقاقة التاريخ الموحدة إن وجد (Frosted Glass Contrast)
        if (dateText != null) ...[
          CustomChip(
            label: dateText!,
            icon: Icons.calendar_today_rounded,
            isCompact: true,
            backgroundColor: Colors.white.withValues(alpha: 0.14),
            foregroundColor: Colors.white,
            borderColor: Colors.white.withValues(alpha: 0.25),
          ),
          SizedBox(height: AppSpacing.sm),
        ],

        // 2. بطاقة هوية القائد والأفاتار مع الترحيب الزمني الموحد
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomAvatarBadge(
              imageUrl: userAvatarUrl,
              initials: userInitials,
              size: AvatarBadgeSize.md,
              hasPulse: true,
              pulseColor: colors.emeraldGlow,
              gradientColors: [
                colors.executiveGoldAccent,
                colors.executiveGoldIcon,
              ],
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              GreetingFormatter.greeting(),
                              maxLines: 1,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.executiveGoldAccent,
                                fontWeight: AppTypography.medium,
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: AppSpacing.md,
                              color: colors.executiveGoldIcon,
                            ),
                          ],
                        ),
                      ),
                      // 4. زر الإجراء التفاعلي الموحد من lib/widgets/buttons
                      if (actionLabel != null && onAction != null) ...[
                        CustomButton.icon(
                          tooltip: actionLabel,
                          icon: Icons.qr_code_scanner_rounded,
                          onPressed: onAction,
                          backgroundColor: colors.onPrimary,
                          foregroundColor: colors.primary,
                          size: AppButtonSize.medium,
                          shape: AppButtonShape.pill,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleLarge.copyWith(
                      color: colors.onPrimary,
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),

        // 3. شارات الصلاحيات وحالة الجلسة الموحدة بتباين عالي وفاخر (High Contrast VIP)
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CustomChip(
              label: role,
              icon: Icons.verified_user_rounded,
              isCompact: true,
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              foregroundColor: Colors.white,
              borderColor: Colors.white.withValues(alpha: 0.25),
            ),
            const CustomStatusBadge(
              label: 'جلسة نشطة',
              tone: SemanticTone.success,
              showDot: true,
              isCompact: true,
              backgroundColor: Color(0xB3064E3B),
              foregroundColor: Color(0xFF6EE7B7),
              borderColor: Color(0x8034D399),
            ),
          ],
        ),
      ],
    );
  }
}
