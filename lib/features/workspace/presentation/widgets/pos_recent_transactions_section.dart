import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_tile.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
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
      final error = controller.recentInvoicesError.value ??
          controller.recentRequestsError.value;

      if (controller.isLoadingRecentData.value && items.isEmpty) {
        return const CustomStateView.loading(
          presentation: CustomStatePresentation.skeletonOnly,
          skeleton: CustomStateSkeleton(
            layout: CustomStateSkeletonLayout.list,
            itemCount: 3,
            cardHeight: 78,
            maxColumns: 1,
          ),
        );
      }

      if (error != null && items.isEmpty) {
        return CustomErrorState.boxed(
          title: 'تعذر تحميل نشاط الشبكة',
          subtitle: error,
          onRetry: controller.retryScopedData,
        );
      }

      return CustomSurfaceCard(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            AppSpacing.vSm,
            if (items.isEmpty)
              const CustomEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'لا توجد حركات',
                subtitle: 'لم يُرجع الخادم فواتير أو طلبات لهذه الشبكة.',
              )
            else
              for (final item in items)
                WorkspaceTransactionTile.fromItem(item),
            if (error != null && items.isNotEmpty) ...[
              AppSpacing.vSm,
              Text(
                'تعذر تحديث بعض البيانات: $error',
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.error,
                ),
              ),
              AppSpacing.vXs,
              CustomButton.text(
                text: 'إعادة المحاولة',
                onPressed: controller.retryScopedData,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'آخر فواتير وطلبات التوريد',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                'آخر البيانات التي أعادها الخادم للشبكة المحددة',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        CustomButton.text(
          text: 'عرض الفواتير',
          suffix: Icons.chevron_right_rounded,
          onPressed: controller.openPurchaseInvoices,
        ),
      ],
    );
  }
}
