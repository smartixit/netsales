import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_contact_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class BillingAccountProfileSection extends StatelessWidget {
  const BillingAccountProfileSection({
    required this.controller,
    required this.account,
    super.key,
  });

  final BillingController controller;
  final Map<String, dynamic> account;

  @override
  Widget build(BuildContext context) {
    final contacts = account['contacts'] is List
        ? (account['contacts'] as List)
            .whereType<Map<String, dynamic>>()
            .toList(growable: false)
        : const <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text('حساب الفوترة', style: AppTypography.titleMedium),
        ),
        CustomSurfaceCard(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.accounts.length > 1)
                CustomDropdown<int>(
                  items: controller.accounts.map((item) {
                    return DropdownItem<int>(
                      value: (item['billing_account_id'] as num).toInt(),
                      child: Text(
                        (item['default_currency'] is Map<String, dynamic>
                                ? item['default_currency']['code']?.toString()
                                : null) ??
                            item['legal_name']?.toString() ??
                            'حساب فوترة',
                      ),
                    );
                  }).toList(growable: false),
                  rxValue: controller.selectedAccountId,
                  onChanged: controller.selectAccount,
                  label: 'حساب الفوترة',
                  hint: 'اختر حساب الفوترة',
                ),
              Text(
                account['legal_name']?.toString() ?? 'حساب الشبكة',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 4),
              Text('رقم الحساب: ${account['account_number']?.toString() ?? '—'}'),
              Text('البريد: ${account['billing_email']?.toString() ?? '—'}'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  CustomButton.outline(
                    text: 'تعديل البيانات',
                    prefix: Icons.edit_outlined,
                    onPressed: () => BillingDialogs.editAccount(controller, account),
                  ),
                  CustomButton.primary(
                    text: 'إضافة جهة اتصال',
                    prefix: Icons.person_add_alt_1,
                    onPressed: () => BillingDialogs.addContact(controller),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('جهات الاتصال', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              if (contacts.isEmpty)
                const CustomEmptyState.compact(
                  title: 'لا توجد جهات اتصال مسجلة',
                )
              else
                ...contacts.map(
                  (contact) => BillingContactTile(
                    controller: controller,
                    contact: contact,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

