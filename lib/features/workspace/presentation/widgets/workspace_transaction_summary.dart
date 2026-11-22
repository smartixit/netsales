import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// Displays the operational status and optional server-formatted amount.
class WorkspaceTransactionSummary extends StatelessWidget {
  const WorkspaceTransactionSummary({
    super.key,
    required this.statusPresentation,
    required this.formattedAmount,
    required this.showAmount,
    required this.showChevron,
    required this.compact,
    this.amountColor,
    this.trailingAction,
  });

  final EnumPresentation statusPresentation;
  final String formattedAmount;
  final bool showAmount;
  final bool showChevron;
  final bool compact;
  final Color? amountColor;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      alignment: compact ? WrapAlignment.spaceBetween : WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 190.r : 150.r),
          child:
              trailingAction ??
              CustomStatusBadge.fromPresentation(
                statusPresentation,
                isCompact: true,
              ),
        ),
        if (showAmount && formattedAmount.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 220.r : 148.r),
            child: Text(
              formattedAmount,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              softWrap: compact,
              textAlign: TextAlign.end,
              style: AppTypography.labelMedium.copyWith(
                color: amountColor ?? colors.onSurface,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                height: 1.2,
              ),
            ),
          ),
        if (showChevron)
          Icon(
            Icons.chevron_right_rounded,
            size: 19.r,
            color: colors.onSurfaceVariant,
          ),
      ],
    );
  }
}
