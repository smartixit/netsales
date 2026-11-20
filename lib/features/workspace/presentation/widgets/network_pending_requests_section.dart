import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_tile.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// Displays the latest pending requests returned by the current API response.
/// It intentionally does not imply a live stream or push connection.
class NetworkPendingRequestsSection extends StatelessWidget {
  const NetworkPendingRequestsSection({
    super.key,
    required this.items,
    required this.totalPendingCount,
    required this.onViewAll,
  });

  final List<WorkspaceTransactionItemViewModel> items;
  final int totalPendingCount;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (items.isEmpty) return const SizedBox.shrink();

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.inbox_outlined, color: colors.warning, size: 18.r),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'طلبات التوريد بانتظار الاعتماد',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomButton.text(
                text: 'عرض الكل ($totalPendingCount)',
                suffix: Icons.chevron_right_rounded,
                onPressed: onViewAll,
              ),
            ],
          ),
          AppSpacing.vMd,
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
            WorkspaceTransactionTile.fromItem(items[index]),
          ],
        ],
      ),
    );
  }
}
