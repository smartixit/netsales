import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// Responsive transaction row shared by POS activity and Network follow-up.
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
    this.showAmount = true,
    this.showChevron = false,
    this.showLeading = true,
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
  final bool showAmount;
  final bool showChevron;
  final bool showLeading;

  factory WorkspaceTransactionTile.fromItem(
    WorkspaceTransactionItemViewModel item, {
    Key? key,
    Widget? customTrailingAction,
    bool showAmount = true,
    bool showChevron = false,
    bool showLeading = true,
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
      showAmount: showAmount,
      showChevron: showChevron,
      showLeading: showLeading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The reference uses a single, balanced line on wide cards. On phone
        // widths the metadata gets its own natural-height row instead of being
        // squeezed into three competing Flexible columns.
        final useCompactLayout = constraints.maxWidth < 420;
        final content = useCompactLayout
            ? _buildCompactContent(context, colors)
            : _buildWideContent(context, colors);

        return CustomSurfaceCard(
          radius: AppRadius.md,
          elevation: 0.5,
          borderWidth: 0.8,
          borderColor: colors.outlineVariant.withValues(alpha: 0.48),
          backgroundColor: colors.surface,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: CustomInteractiveBounce(
            onTap: onTap,
            child: showLeading
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildLeading(context, colors),
                      AppSpacing.hSm,
                      Expanded(child: content),
                    ],
                  )
                : content,
          ),
        );
      },
    );
  }

  Widget _buildLeading(BuildContext context, AppColors colors) {
    if (initials != null) {
      return CustomAvatarBadge(
        initials: initials!,
        imageUrl: imageUrl,
        size: AvatarBadgeSize.sm,
        customDimension: 34,
        hasPulse: false,
        borderRadius: BorderRadius.circular(AppRadius.md),
      );
    }

    return Container(
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
  }

  Widget _buildTitleLine({
    required AppColors colors,
    required bool compact,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (reference != null && reference!.isNotEmpty) ...[
          SizedBox(width: AppSpacing.xs),
          _ReferencePill(reference: reference!, colors: colors),
        ],
        if (showChevron) ...[
          SizedBox(width: AppSpacing.xxs),
          Icon(
            Icons.chevron_left_rounded,
            size: 19.r,
            color: colors.onSurfaceVariant,
          ),
        ],
      ],
    );
  }

  Widget _buildSubtitle(AppColors colors, {required bool compact}) {
    if (subtitle == null || subtitle!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      subtitle!,
      maxLines: compact ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.labelSmall.copyWith(
        color: colors.onSurfaceVariant,
        height: 1.25,
      ),
    );
  }

  Widget _buildStatus() {
    return trailingAction ??
        CustomStatusBadge.fromPresentation(
          statusPresentation,
          isCompact: true,
        );
  }

  Widget _buildAmount(AppColors colors, {required bool compact}) {
    if (!showAmount || formattedAmount.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      formattedAmount,
      maxLines: compact ? 2 : 1,
      softWrap: compact,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.end,
      style: AppTypography.labelMedium.copyWith(
        color: amountColor ?? colors.onSurface,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
        height: 1.2,
      ),
    );
  }

  Widget _buildWideContent(BuildContext context, AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleLine(colors: colors, compact: false),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                SizedBox(height: 3.h),
                _buildSubtitle(colors, compact: false),
              ],
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 112.r),
          child: Center(child: _buildStatus()),
        ),
        if (showAmount && formattedAmount.isNotEmpty) ...[
          SizedBox(width: AppSpacing.sm),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 116.r),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _buildAmount(colors, compact: false),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTitleLine(colors: colors, compact: true),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          SizedBox(height: 4.h),
          _buildSubtitle(colors, compact: true),
        ],
        SizedBox(height: AppSpacing.xs),
        Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _buildStatus(),
              if (showAmount && formattedAmount.isNotEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 240.r),
                  child: _buildAmount(colors, compact: true),
                ),
          ],
        ),
      ],
    );
  }
}

class _ReferencePill extends StatelessWidget {
  const _ReferencePill({required this.reference, required this.colors});

  final String reference;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 92.r),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        reference,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.labelSmall.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
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
        constraints: BoxConstraints(maxWidth: 112.r),
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
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: colors.warning,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
