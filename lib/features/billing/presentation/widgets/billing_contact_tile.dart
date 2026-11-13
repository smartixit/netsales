import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_dialogs.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';

class BillingContactTile extends StatelessWidget {
  const BillingContactTile({
    required this.controller,
    required this.contact,
    super.key,
  });

  final BillingController controller;
  final Map<String, dynamic> contact;

  @override
  Widget build(BuildContext context) {
    final id = (contact['contact_id'] as num?)?.toInt();
    final details = [
      contact['email'],
      contact['phone'],
      if (contact['is_primary'] == true) 'أساسية',
      if (contact['receives_invoices'] == true) 'تستقبل الفواتير',
    ]
        .where((value) => value != null && value.toString().isNotEmpty)
        .join(' • ');

    return CustomInfoListTile(
      padding: EdgeInsets.zero,
      title: Text(contact['name']?.toString() ?? 'جهة اتصال'),
      subtitle: Text(details),
      trailing: Wrap(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (contact['is_primary'] != true)
            CustomButton.text(
              text: 'تعيين أساسية',
              onPressed: id == null
                  ? null
                  : () => controller.updateContact(
                        id,
                        {'is_primary': true},
                      ),
            ),
          CustomButton.text(
            text: 'تعديل',
            onPressed: id == null
                ? null
                : () => BillingDialogs.editContact(controller, contact),
          ),
          CustomButton.text(
            text: 'حذف',
            foregroundColor: Theme.of(context).colorScheme.error,
            onPressed: id == null
                ? null
                : () => BillingDialogs.deleteContact(controller, id),
          ),
        ],
      ),
    );
  }
}
