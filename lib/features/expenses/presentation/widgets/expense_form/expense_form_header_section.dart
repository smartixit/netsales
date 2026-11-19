import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_field.dart';

/// قسم الترويسة لنموذج المصروف: اختيار الشبكة وتاريخ الصرف
class ExpenseFormHeaderSection extends StatelessWidget {
  const ExpenseFormHeaderSection({super.key, required this.controller});

  final NetworkExpenseFormController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. اختيار الشبكة (إذا كانت متعددة)
        Obx(() {
          final networks = controller.authorizedNetworks;
          if (networks.length <= 1) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: CustomDropdown<int>(
              label: 'الشبكة التابع لها المصروف',
              searchEnabled: false,
              rxValue: controller.selectedNetworkId,
              items: networks.map((net) {
                return DropdownItem<int>(
                  value: net.networkId,
                  child: Text(net.networkName),
                );
              }).toList(),
              onChanged: (id) => controller.selectedNetworkId.value = id,
            ),
          );
        }),

        // 2. منتقي التاريخ
        Obx(
          () => CustomDatePickerField.single(
            label: 'تاريخ سند الصرف',
            value: controller.selectedDate.value,
            onChanged: (date) {
              if (date != null) {
                controller.setDate(date);
              }
            },
          ),
        ),
      ],
    );
  }
}
