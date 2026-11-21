import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';

class PosRecentTransactionsSection extends StatelessWidget {
  const PosRecentTransactionsSection({super.key, required this.controller});

  final PosWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.recentTransactionItems;
      final error =
          controller.recentInvoicesError.value ??
          controller.recentRequestsError.value;

      if (controller.isLoadingRecentData.value && items.isEmpty) {
        return const CustomStateView.loading(
          presentation: CustomStatePresentation.skeletonOnly,
          skeleton: CustomStateSkeleton(
            layout: CustomStateSkeletonLayout.list,
            itemCount: 3,
            cardHeight: 68,
            maxColumns: 1,
          ),
        );
      }

      if (error != null && items.isEmpty) {
        return CustomErrorState.boxed(
          title: 'تعذر تحميل آخر العمليات',
          subtitle: error,
          onRetry: controller.retryScopedData,
        );
      }

      final colors = context.colors;
      return CustomSurfaceCard(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.view_list_rounded,
                  color: colors.primary,
                  size: 19.r,
                ),
                AppSpacing.hSm,
                Text(
                  'آخر العمليات',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            AppSpacing.vSm,
            if (items.isEmpty)
              const CustomEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'لا توجد حركات',
                subtitle: 'لم يُرجع الخادم فواتير أو طلبات لهذه الشبكة.',
              )
            else
              for (var index = 0; index < items.length; index++) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.45),
                  ),
                WorkspaceTransactionTile.fromItem(items[index]),
              ],
            if (error != null && items.isNotEmpty) ...[
              AppSpacing.vSm,
              Text(
                'تعذر تحديث بعض البيانات: $error',
                style: AppTypography.bodySmall.copyWith(color: colors.error),
              ),
            ],
          ],
        ),
      );
    });
  }
}
