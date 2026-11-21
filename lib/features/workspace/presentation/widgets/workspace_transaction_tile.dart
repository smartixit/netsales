import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_identity.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_leading.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_summary.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_action.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// Feature-level transaction row shared by Network and POS dashboards.
///
/// The containing section owns the card surface and separators. This widget
/// owns only the row layout and delegates identity, leading and summary
/// rendering to focused presentation components.
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
          (item.onAction == null
              ? null
              : WorkspaceTransactionAction(
                  label: item.actionLabel ?? 'إجراء',
                  onTap: item.onAction!,
                )),
      showAmount: showAmount,
      showChevron: showChevron,
      showLeading: showLeading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < AppBreakpoints.mobileSmallMax;
        final identity = WorkspaceTransactionIdentity(
          title: title,
          reference: reference,
          subtitle: subtitle,
          compact: compact,
        );
        final summary = WorkspaceTransactionSummary(
          statusPresentation: statusPresentation,
          formattedAmount: formattedAmount,
          showAmount: showAmount,
          showChevron: showChevron,
          compact: compact,
          amountColor: amountColor,
          trailingAction: trailingAction,
        );

        final content = compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  identity,
                  SizedBox(height: AppSpacing.xs),
                  summary,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: identity),
                  SizedBox(width: AppSpacing.sm),
                  Flexible(flex: 4, child: summary),
                ],
              );

        return CustomInteractiveBounce(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showLeading) ...[
                  WorkspaceTransactionLeading(
                    icon: icon,
                    accentColor: amountColor,
                    initials: initials,
                    imageUrl: imageUrl,
                  ),
                  SizedBox(width: AppSpacing.sm),
                ],
                Expanded(child: content),
              ],
            ),
          ),
        );
      },
    );
  }
}

