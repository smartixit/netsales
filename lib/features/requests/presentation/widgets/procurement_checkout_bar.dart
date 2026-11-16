import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_cart_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class ProcurementCheckoutBar extends GetView<PosProcurementController> {
  const ProcurementCheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final lineCount = controller.procurementCart.length;
      final voucherCount = controller.procurementCart.fold<int>(0, (sum, line) => sum + line.voucherCount);
      final total = '\${AmountFormatter.formatValue(controller.liveOrderTotalMinor / 100)} ر.ي';
      return Container(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md,
          AppSpacing.sm + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant.withValues(alpha: .45))),
          boxShadow: [BoxShadow(color: colors.shadow.withValues(alpha: .08), blurRadius: 20, offset: const Offset(0, -6))],
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 390;
              final summary = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$lineCount باقة • \$voucherCount كرت',
                    style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                  AppSpacing.vXxs,
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(total, style: AppTypography.titleLarge.copyWith(color: colors.primary, fontWeight: FontWeight.w900)),
                  ),
                ],
              );
              final cartButton = CustomButton.outline(
                text: 'السلة',
                icon: Icons.shopping_bag_outlined,
                size: AppButtonSize.medium,
                onPressed: lineCount == 0 ? null : () => Get.bottomSheet<void>(
                  Container(
                    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .86),
                    decoration: BoxDecoration(color: colors.surface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
                    child: SafeArea(top: false, child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: const ProcurementCartSection(),
                    )),
                  ),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                ),
              );
              final submitButton = CustomButton(
                text: controller.isEditing.value ? 'حفظ التعديل' : 'إرسال الطلب',
                icon: Icons.send_rounded,
                loading: controller.isSubmitting.value,
                enabled: controller.canCreateOrder && controller.canSubmitOrder,
                onPressed: controller.submitOrderAndClose,
              );
              if (compact) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [Expanded(child: summary), AppSpacing.hSm, cartButton]),
                    AppSpacing.vSm,
                    SizedBox(width: double.infinity, child: submitButton),
                  ],
                );
              }
              return Row(children: [
                Expanded(child: summary),
                AppSpacing.hSm,
                cartButton,
                AppSpacing.hSm,
                Expanded(flex: 2, child: submitButton),
              ]);
            },
          ),
        ),
      );
    });
  }
}