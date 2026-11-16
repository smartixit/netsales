import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// سطر موحد لعرض حركة أو عملية تنفيذية في لوحة التحكم (WorkspaceTransactionTile)
/// مخصص لمساحات العمل كـ Pure Stateless Component يعاد استخدامه للفواتير، طلبات التوريد، والسندات
class WorkspaceTransactionTile extends StatelessWidget {
  final String title;
  final String? reference;
  final String? subtitle;
  final String formattedAmount;
  final EnumPresentation statusPresentation;
  final IconData? icon;
  final String? initials;
  final String? imageUrl;
  final Color? amountColor;
  final VoidCallback? onTap;
  final Widget? trailingAction;

  const WorkspaceTransactionTile({
    super.key,
    required this.title,
    required this.formattedAmount,
    required this.statusPresentation,
    this.reference,
    this.subtitle,
    this.icon,
    this.initials,
    this.imageUrl,
    this.amountColor,
    this.onTap,
    this.trailingAction,
  });

  /// إنشاء مباشر من نموذج العرض المجرد (WorkspaceTransactionItem)
  factory WorkspaceTransactionTile.fromItem(
    WorkspaceTransactionItemViewModel item, {
    Key? key,
    Widget? customTrailingAction,
  }) {
    return WorkspaceTransactionTile(
      key: key,
      title: item.title,
      reference: item.reference,
      subtitle: item.subtitle,
      formattedAmount: item.formattedAmount,
      statusPresentation: item.statusPresentation,
      amountColor: item.amountColor,
      initials: item.initials,
      imageUrl: item.imageUrl,
      icon: item.icon,
      onTap: item.onTap,
      trailingAction:
          customTrailingAction ??
          (item.onAction != null
              ? _ActionBadge(
                  label: item.actionLabel ?? 'إجراء',
                  onTap: item.onAction!,
                )
              : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final leadingWidget = initials != null
        ? CustomAvatarBadge(
            initials: initials!,
            imageUrl: imageUrl,
            size: AvatarBadgeSize.sm,
            customDimension: 40,
            hasPulse: false,
            borderRadius: BorderRadius.circular(AppRadius.md),
          )
        : Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon ?? Icons.receipt_long_rounded,
              color: colors.primary,
              size: 20.r,
            ),
          );

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leadingWidget,
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (reference != null && reference!.isNotEmpty) ...[
                        AppSpacing.hSm,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            reference!,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppSpacing.hSm,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedAmount,
                  style: AppTypography.titleSmall.copyWith(
                    color: amountColor ?? colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3.h),
                if (trailingAction != null)
                  trailingAction!
                else
                  CustomStatusBadge.fromPresentation(
                    statusPresentation,
                    isCompact: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionBadge({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.badgeText.copyWith(
                color: colors.primary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 2.w),
            Icon(Icons.chevron_left_rounded, size: 12.r, color: colors.primary),
          ],
        ),
      ),
    );
  }
}
