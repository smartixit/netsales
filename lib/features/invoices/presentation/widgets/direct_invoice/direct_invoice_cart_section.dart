import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice/direct_invoice_cart_item_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// قسم سلة بنود الفاتورة المباشرة القابلة للتعديل
class DirectInvoiceCartSection extends GetView<NetworkDirectInvoiceController> {
  const DirectInvoiceCartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.cart.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: colors.onSurfaceVariant,
                size: 28,
              ),
              AppSpacing.vSm,
              Text(
                'لم تتم إضافة أي باقة بعد',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.vXxs,
              Text(
                'اختر باقة وحدد عدد الكروت لإضافتها إلى الفاتورة.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'بنود الفاتورة (${controller.cart.length})',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomButton.outline(
                text: 'إفراغ البنود',
                size: AppButtonSize.small,
                onPressed: controller.clearCart,
              ),
            ],
          ),
          AppSpacing.vSm,
          for (final line in controller.cart)
            DirectInvoiceCartItemCard(
              line: line,
              onRemove: () => controller.removeFromCart(line.package.packageId),
            ),
        ],
      );
    });
  }
}
