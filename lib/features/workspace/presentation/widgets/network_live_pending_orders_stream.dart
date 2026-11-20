import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_tile.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';

/// شريط أحدث طلبات التوريد بانتظار الاعتماد (NetworkLivePendingOrdersStream)
/// ويدجيت عرض نقية (Pure Dumb Component) خالية من المنطق ومعالجة القواميس
class NetworkLivePendingOrdersStream extends StatelessWidget {
  final List<WorkspaceTransactionItemViewModel> items;
  final int totalPendingCount;
  final VoidCallback onViewAll;

  const NetworkLivePendingOrdersStream({
    super.key,
    required this.items,
    required this.totalPendingCount,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CustomPulsingIndicator(
                      color: colors.warning,
                      size: 6.r,
                      enablePing: true,
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Text(
                        'أحدث طلبات التوريد بانتظار الاعتماد',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton.text(
                text: 'معاينة الكل ($totalPendingCount)',
                suffix: Icons.chevron_right_rounded,
                onPressed: onViewAll,
              ),
            ],
          ),
          AppSpacing.vMd,
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
            WorkspaceTransactionTile.fromItem(items[i]),
          ],
        ],
      ),
    );
  }
}
