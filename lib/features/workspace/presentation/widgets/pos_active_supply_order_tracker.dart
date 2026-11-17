import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ويدجت متابعة طلبات التوريد النشطة الحقيقية من الـ API (PosActiveSupplyOrderTracker)
class PosActiveSupplyOrderTracker extends StatelessWidget {
  final PosWorkspaceController controller;

  const PosActiveSupplyOrderTracker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final activeOrder = controller.activeSupplyOrder;
      if (activeOrder == null) return const SizedBox.shrink();

      return CustomInteractiveBounce(
        onTap: () => controller.openProcurementOrder(activeOrder.request),
        child: CustomSurfaceCard(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.hSm,
                      Text(
                        'متابعة طلب توريد نشط',
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      activeOrder.statusLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'طلب توريد ${activeOrder.reference} • الإجمالي: ${activeOrder.formattedAmount} ر.ي',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              AppSpacing.vMd,
              Row(
                children: [
                  OrderStepNode(
                    title: 'تم الإرسال',
                    isDone: true,
                    isActive: false,
                  ),
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color:
                          activeOrder.isReviewComplete ||
                              activeOrder.isReviewActive
                          ? colors.primary
                          : colors.surfaceContainerHighest,
                    ),
                  ),
                  OrderStepNode(
                    title: 'مراجعة المزود',
                    isDone: activeOrder.isReviewComplete,
                    isActive: activeOrder.isReviewActive,
                  ),
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color:
                          activeOrder.isDeliveryComplete ||
                              activeOrder.isDeliveryActive
                          ? colors.primary
                          : colors.surfaceContainerHighest,
                    ),
                  ),
                  OrderStepNode(
                    title: 'المعالجة والتسليم',
                    isDone: activeOrder.isDeliveryComplete,
                    isActive: activeOrder.isDeliveryActive,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// عقدة مرحلة الطلب في شريط التقدم (OrderStepNode)
class OrderStepNode extends StatelessWidget {
  const OrderStepNode({
    super.key,
    required this.title,
    required this.isDone,
    required this.isActive,
  });

  final String title;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Color nodeColor = colors.surfaceContainerHighest;
    IconData nodeIcon = Icons.circle_outlined;

    if (isDone) {
      nodeColor = colors.primary;
      nodeIcon = Icons.check_circle_rounded;
    } else if (isActive) {
      nodeColor = colors.warning;
      nodeIcon = Icons.timelapse_rounded;
    }

    return Column(
      children: [
        Icon(nodeIcon, color: nodeColor, size: 18.r),
        SizedBox(height: 3.h),
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(
            color: isDone || isActive
                ? colors.onSurface
                : colors.onSurfaceVariant,
            fontSize: 9.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
