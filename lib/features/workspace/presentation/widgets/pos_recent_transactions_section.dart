import 'package:flutter/material.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_tile.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';

/// قسم آخر حركات الحساب والمشتريات الحية لنقطة البيع من الـ API (PosRecentTransactionsSection)
/// ويدجيت عرض نقية (Pure Dumb UI Component) خالية من منطق التحويلات وتلتزم بمعمارية الطبقات
class PosRecentTransactionsSection extends StatelessWidget {
  final PosWorkspaceController controller;

  const PosRecentTransactionsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.recentTransactionItems;
      if (controller.isLoadingRecentData.value && items.isEmpty) {
        return const CustomStateView.loading(
          presentation: CustomStatePresentation.skeletonOnly,
          skeleton: CustomStateSkeleton(
            layout: CustomStateSkeletonLayout.cards,
            itemCount: 1,
            cardHeight: 160,
            maxColumns: 1,
            minItemWidth: 180,
          ),
        );
      }

      if (items.isEmpty) {
        return CustomSurfaceCard(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              AppSpacing.vMd,
              const CustomEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'لا توجد حركات سابقة',
                subtitle: 'لم يتم تسجيل أي فواتير أو طلبات توريد لهذه الشبكة حتى الآن.',
              ),
            ],
          ),
        );
      }

      return CustomSurfaceCard(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            AppSpacing.vSm,
            for (final item in items) WorkspaceTransactionTile.fromItem(item),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomPulsingIndicator(
                    color: colors.primary,
                    size: 6.r,
                    enablePing: true,
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      'آخر حركات الحساب والمشتريات',
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
              SizedBox(height: 3.h),
              Text(
                'سجل فواتير التوريد من الشبكة وسندات المشتريات المعتمدة من الخادم',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        CustomButton.text(
          text: 'عرض الكل',
          suffix: Icons.chevron_right_rounded,
          onPressed: controller.openPurchaseInvoices,
        ),
      ],
    );
  }
}
