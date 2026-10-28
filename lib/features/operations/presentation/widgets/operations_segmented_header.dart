import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_sale_invoice_sheet.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_voucher_request_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

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
                  label: 'الفواتير',
                  count: controller.invoices.length,
                  icon: Icons.receipt_long_rounded,
                ),
                CustomSegmentItem(
                  label: 'الطلبات',
                  count: controller.pendingRequestsCount,
                  highlightBadge: controller.pendingRequestsCount > 0,
                  icon: Icons.inventory_2_rounded,
                ),
              ],
            ),
          ),

          AppSpacing.hSm,

          // 2. زر الإجراء السريع السياقي المدمج
          CustomButton.primary(
            text: isInvoiceTab ? 'فاتورة' : 'طلب توريد',
            icon: isInvoiceTab
                ? Icons.add_rounded
                : Icons.add_shopping_cart_rounded,
            height: 42.h,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            onPressed: () {
              if (isInvoiceTab) {
                CreateSaleInvoiceSheet.show(context);
              } else {
                CreateVoucherRequestSheet.show(context);
              }
            },
          ),
        ],
      );
    });
  }
}
