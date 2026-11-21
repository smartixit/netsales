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

/// Flat transaction row for use inside a containing dashboard section.
/// The parent owns the surface and separators, avoiding nested mini-cards.
class WorkspaceTransactionTile extends StatelessWidget {
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
      trailingAction: customTrailingAction ??
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
    final leading = initials != null
        ? CustomAvatarBadge(
            initials: initials!,
            imageUrl: imageUrl,
            size: AvatarBadgeSize.sm,
            customDimension: 34,
            hasPulse: false,
            borderRadius: BorderRadius.circular(AppRadius.md),
          )
        : Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: (amountColor ?? colors.primary).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon ?? Icons.receipt_long_rounded,
              color: amountColor ?? colors.primary,
              size: 18.r,
            ),
          );

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            leading,
            AppSpacing.hSm,
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (reference != null && reference!.isNotEmpty) ...[
                        SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              reference!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Flexible(
              flex: 4,
              child: Align(
                alignment: AlignmentDirectional.center,
                child: trailingAction ??
                    CustomStatusBadge.fromPresentation(
                      statusPresentation,
                      isCompact: true,
                    ),
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Flexible(
              flex: 3,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    formattedAmount,
                    maxLines: 1,
                    style: AppTypography.labelMedium.copyWith(
                      color: amountColor ?? colors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: AppTypography.labelSmall.copyWith(
            color: colors.warning,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
