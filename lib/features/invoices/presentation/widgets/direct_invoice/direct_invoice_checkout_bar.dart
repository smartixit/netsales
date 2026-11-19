import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط تأكيد وإصدار الفاتورة المباشرة الثابت أسفل الشاشة
class DirectInvoiceCheckoutBar extends GetView<NetworkDirectInvoiceController> {
  const DirectInvoiceCheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: .35),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final totalVouchers = controller.totalCartVouchers;
          final itemsCount = controller.cart.length;
          final isCartEmpty = controller.cart.isEmpty;

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$itemsCount باقة  •  $totalVouchers كرت',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'التسعير والإجمالي يُعتمد سيادياً من الخادم',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton.primary(
                text: 'إصدار الفاتورة',
                icon: Icons.check_circle_outline_rounded,
                loading: controller.isSubmitting.value,
                onPressed: isCartEmpty || controller.isSubmitting.value
                    ? null
                    : controller.submitInvoice,
              ),
            ],
          );
        }),
      ),
    );
  }
}
