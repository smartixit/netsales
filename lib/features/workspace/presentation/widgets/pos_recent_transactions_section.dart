import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_transaction_tile.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';

/// قسم آخر حركات الحساب والمشتريات الحية لنقطة البيع من الـ API (PosRecentTransactionsSection)
/// ويدجيت عرض نقية (Pure Dumb UI Component) خالية من منطق التحويلات وتلتزم بمعمارية الطبقات
class PosRecentTransactionsSection extends StatelessWidget {
  final PosWorkspaceController controller;

  const PosRecentTransactionsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final items = controller.recentTransactionItems;
      if (controller.isLoadingRecentData.value && items.isEmpty) {
        return const CustomSkeletonCard(height: 160);
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
                subtitle:
                    'لم يتم تسجيل أي فواتير أو طلبات توريد لهذه الشبكة حتى الآن.',
              ),
            ],
          ),
        );
      }

      return CustomSurfaceCard(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            AppSpacing.vMd,
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
              WorkspaceTransactionTile.fromItem(items[i]),
            ],
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
                  Text(
                    'آخر حركات الحساب والمشتريات',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
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
          suffix: Icons.chevron_left_rounded,
          onPressed: controller.openPurchaseInvoices,
        ),
      ],
    );
  }
}
