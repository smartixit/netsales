import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// Small feature action attached to a workspace transaction.
class WorkspaceTransactionAction extends StatelessWidget {
  const WorkspaceTransactionAction({
    super.key,
    required this.label,
    required this.onTap,
  });

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
          borderRadius: BorderRadius.circular(999),
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
