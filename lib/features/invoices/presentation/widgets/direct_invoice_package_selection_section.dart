import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/widgets/cards/custom_package_tariff_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// قسم اختيار وتحديد باقات الكروت في الفاتورة المباشرة
class DirectInvoicePackageSelectionSection
    extends GetView<NetworkDirectInvoiceController> {
  const DirectInvoicePackageSelectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller.packageSearchController,
          label: 'البحث عن باقة',
          hint: 'بحث باسم الباقة أو السعر...',
          prefixIcon: const Icon(Icons.search_rounded),
        ),
        AppSpacing.vSm,
        Obx(() {
          if (controller.isLoadingPackages.value) {
            return const CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 3,
                cardHeight: 180,
              ),
            );
          }

          if (controller.packages.isEmpty) {
            return const CustomEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'لا توجد باقات متاحة',
              subtitle: 'لم يتم العثور على باقات كروت نشطة تابعة للشبكة.',
            );
          }

          final query = controller.packageSearchQuery.value.toLowerCase();
          final filtered = controller.packages.where((p) {
            if (query.isEmpty) return true;
            return p.packageName.toLowerCase().contains(query);
          }).toList();

          if (filtered.isEmpty) {
            return const CustomEmptyState.compact(
              icon: Icons.search_off_rounded,
              title: 'لا توجد باقات مطابقة للبحث',
              subtitle: 'جرّب كتابة كلمة بحث أخرى.',
            );
          }

          final isCash = controller.selectedSaleType == SaleType.cash;

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => AppSpacing.vSm,
            itemBuilder: (context, index) {
              final package = filtered[index];
              final capacity = package.packageVoucherCount > 0
                  ? package.packageVoucherCount
                  : 100;
              final accent = CustomColorPicker.parseHex(
                package.packageColor,
                fallback: colors.primary,
              );

              return Obx(() {
                final qty =
                    controller.packageQuantities[package.packageId] ?? 0;
                final qtyCtrl = controller.getQuantityController(
                  package.packageId,
                );
                final paperDesc = VoucherSheetCalculator.describe(
                  qty,
                  capacity,
                );

                return CustomPackageTariffCard(
                  title: package.packageName,
                  sheetCapacity: capacity,
                  accentColor: accent,
                  basePrice: package.resolvedBasePrice,
                  cashPrice: package.resolvedCashPrice,
                  creditPrice: package.resolvedCreditPrice,
                  cashDiscount: package.resolvedCashDiscount,
                  creditDiscount: package.resolvedCreditDiscount,
                  isCashSale: isCash,
                  quantity: qty,
                  quantityController: qtyCtrl,
                  paperEquivalentDescription: paperDesc,
                  onQuantityChanged: (newQty) {
                    controller.setPackageQuantity(package.packageId, newQty);
                  },
                );
              });
            },
          );
        }),
      ],
    );
  }
}
