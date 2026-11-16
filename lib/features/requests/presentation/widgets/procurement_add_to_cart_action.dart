import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// إجراء إضافة الباقة المحددة إلى سلة التوريد أو تحديث كميتها.
class ProcurementAddToCartAction extends GetView<PosProcurementController> {
  const ProcurementAddToCartAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final package = controller.selectedPackage.value;
      final isInCart = controller.isSelectedPackageInCart;
      final canAdd = package != null && controller.requestedVoucherCount > 0;

      return Padding(
        padding: EdgeInsets.only(top: AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: CustomButton.secondary(
            text: isInCart
                ? 'تحديث كمية الباقة في السلة'
                : 'إضافة الباقة إلى الطلب',
            icon: isInCart
                ? Icons.check_circle_outline_rounded
                : Icons.add_shopping_cart_rounded,
            onPressed: canAdd ? controller.addOrUpdateCartLine : null,
          ),
        ),
      );
    });
  }
}
