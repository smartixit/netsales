import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_sale_invoice_sheet.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_voucher_request_sheet.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// رأس التبويب القطاعي للعمليات (OperationsSegmentedHeader)
/// ============================================================================
/// يدمج شريط التبديل القطاعي التنفيذي مع زر إجراء سريع سياقي ينشط مباشرة
/// لإنشاء الفاتورة أو طلب التوريد وفق التبويب الفعال.
class OperationsSegmentedHeader extends StatelessWidget {
  final OperationsController controller;

  const OperationsSegmentedHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isInvoiceTab = controller.activeSegmentIndex.value == 0;

      return Row(
        children: [
          // 1. شريط التبديل القطاعي التنفيذي المشترك
          Expanded(
            child: CustomSegmentedBar(
              selectedIndex: controller.activeSegmentIndex.value,
              onSegmentChanged: controller.changeSegment,
              items: [
                CustomSegmentItem(
                  label: 'فواتير المبيعات',
                  count: controller.invoices.length,
                  icon: Icons.receipt_long_rounded,
                ),
                CustomSegmentItem(
                  label: 'طلبات التوريد',
                  count: controller.pendingRequestsCount,
                  highlightBadge: controller.pendingRequestsCount > 0,
                  icon: Icons.inventory_2_rounded,
                ),
              ],
            ),
          ),

          AppSpacing.hSm,

          // 2. زر الإجراء السريع السياقي المدمج
          CustomInteractiveBounce(
            onTap: () {
              if (isInvoiceTab) {
                CreateSaleInvoiceSheet.show(context);
              } else {
                CreateVoucherRequestSheet.show(context);
              }
            },
            child: Tooltip(
              message: isInvoiceTab
                  ? 'إصدار فاتورة مبيعات جديدة'
                  : 'رفع طلب توريد باقات كروت',
              child: Container(
                height: 42.h,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: AppRadius.mdRadius,
                  boxShadow: AppElevation.level1(context),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isInvoiceTab
                          ? Icons.add_rounded
                          : Icons.add_shopping_cart_rounded,
                      color: colors.onPrimary,
                      size: 18.r,
                    ),
                    AppSpacing.hXxs,
                    Text(
                      isInvoiceTab ? 'فاتورة' : 'طلب توريد',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
