import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class BillingAccountCreationSection extends StatelessWidget {
  const BillingAccountCreationSection({
    required this.controller,
    super.key,
  });

  final BillingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CustomEmptyState.boxed(
          title: 'لا يوجد حساب فوترة',
          subtitle:
              'أنشئ حساب فوترة للشبكة للبدء في إدارة الخطط والاشتراكات والفواتير.',
        ),
        CustomDropdown<int>(
          items: controller.currencies
              .map(
                (currency) => DropdownItem<int>(
                  value: (currency['currency_id'] as num).toInt(),
                  child: Text(currency['code']?.toString() ?? 'عملة'),
                ),
              )
              .toList(growable: false),
          rxValue: controller.selectedCurrencyId,
          onChanged: (value) => controller.selectedCurrencyId.value = value,
          label: 'عملة حساب الفوترة',
          hint: 'اختر العملة',
        ),
        CustomButton.primary(
          text: 'إنشاء حساب الفوترة',
          prefix: Icons.add_business_outlined,
          loading: controller.isMutating.value,
          onPressed: controller.selectedCurrencyId.value == null
              ? null
              : controller.createAccount,
        ),
      ],
    );
  }
}
