import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_dialogs.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class BillingWorkspaceContent extends StatelessWidget {
  const BillingWorkspaceContent({super.key, required this.controller});

  final BillingController controller;

  @override
  Widget build(BuildContext context) {

    if (controller.isLoading.value && controller.account.value == null) {
      return const CustomSkeletonFeed(itemCount: 4, shrinkWrap: true);
    }
    if (controller.errorMessage.value != null && controller.account.value == null) {
      return CustomErrorState.boxed(
        title: 'تعذر تحميل مساحة الفوترة',
        subtitle: controller.errorMessage.value,
        onRetry: controller.load,
      );
    }
    final account = controller.account.value;
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'الاشتراك والفوترة',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
              CustomButton.outline(
                text: 'تحديث',
                prefix: Icons.refresh_rounded,
                loading: controller.isLoading.value,
                onPressed: controller.isLoading.value ? null : controller.load,
              ),
            ],
          ),
          if (controller.errorMessage.value != null)
            CustomErrorState.compact(
              title: 'تعذر إكمال العملية',
              subtitle: controller.errorMessage.value,
              onRetry: controller.load,
            ),
          if (account == null) ...[
            const CustomEmptyState.boxed(
              title: 'لا يوجد حساب فوترة',
              subtitle: 'أنشئ حساب فوترة للشبكة للبدء في إدارة الخطط والاشتراكات والفواتير.',
            ),
            CustomDropdown<int>(
              items: controller.currencies.map((currency) => DropdownItem<int>(
                value: (currency['currency_id'] as num).toInt(),
                child: Text(currency['code']?.toString() ?? 'عملة'),
              )).toList(),
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
          ] else ...[
            _sectionTitle('حساب الفوترة'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.accounts.length > 1)
                      CustomDropdown<int>(
                        items: controller.accounts.map((item) => DropdownItem<int>(
                          value: (item['billing_account_id'] as num).toInt(),
                          child: Text(
                            (item['default_currency'] is Map<String, dynamic>
                                ? item['default_currency']['code']?.toString()
                                : null) ??
                                item['legal_name']?.toString() ??
                                'حساب فوترة',
                          ),
                        )).toList(),
                        rxValue: controller.selectedAccountId,
                        onChanged: controller.selectAccount,
                        label: 'حساب الفوترة',
                        hint: 'اختر حساب الفوترة',
                      ),
                    Text(account['legal_name']?.toString() ?? 'حساب الشبكة'),
                    Text('رقم الحساب: ${account['account_number']?.toString() ?? '—'}'),
                    Text('البريد: ${account['billing_email']?.toString() ?? '—'}'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
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
                    const SizedBox(height: 8),
                    const Text('جهات الاتصال', style: TextStyle(fontWeight: FontWeight.w700)),
                    if (account['contacts'] is List &&
                        (account['contacts'] as List).isNotEmpty)
                      ...(account['contacts'] as List<dynamic>)
                          .whereType<Map<String, dynamic>>()
                          .map(_contactTile)
                    else
                      const CustomEmptyState.compact(title: 'لا توجد جهات اتصال مسجلة'),
                  ],
                ),
              ),
            ),
            _sectionTitle('الخطط المتاحة'),
            if (controller.plans.isEmpty)
              const CustomEmptyState.compact(title: 'لا توجد خطط متاحة لهذا الحساب')
            else
              ...controller.plans.map(_planTile),
            _sectionTitle('الاشتراك الحالي'),
            if (controller.subscriptions.isEmpty)
              const CustomEmptyState.compact(title: 'لا يوجد اشتراك مسجل حالياً')
            else
              ...controller.subscriptions.map(_subscriptionTile),
            _sectionTitle('الاستحقاقات والمزايا'),
            if (controller.entitlements.value?['features'] is List &&
                (controller.entitlements.value!['features'] as List).isNotEmpty)
              ...(controller.entitlements.value!['features'] as List<dynamic>)
                  .whereType<Map<String, dynamic>>()
                  .map(_entitlementTile)
            else
              const CustomEmptyState.compact(title: 'لا توجد استحقاقات متاحة للعرض'),
            if (controller.entitlements.value?['trial'] is Map<String, dynamic>)
              _trialCard(controller.entitlements.value!['trial'] as Map<String, dynamic>),
            _sectionTitle('الفواتير'),
            if (controller.invoices.isEmpty)
              const CustomEmptyState.compact(title: 'لا توجد فواتير')
            else
              ...controller.invoices.map(_invoiceTile),
            _sectionTitle('الإشعارات الدائنة'),
            if (controller.creditNotes.isEmpty)
              const CustomEmptyState.compact(title: 'لا توجد إشعارات دائنة')
            else
              ...controller.creditNotes.map((item) => _financialTile(
                title: item['credit_note_number']?.toString() ?? 'إشعار دائن',
                status: item['status']?.toString(),
                amount: item['total_minor'],
                currencyCode: item['currency_code']?.toString(),
              )),
            _sectionTitle('الاستردادات'),
            if (controller.refunds.isEmpty)
              const CustomEmptyState.compact(title: 'لا توجد استردادات')
            else
              ...controller.refunds.map((item) => _financialTile(
                title: item['refund_reference']?.toString() ?? 'استرداد',
                status: item['status']?.toString(),
                amount: item['amount_minor'],
                currencyCode: item['currency_code']?.toString(),
              )),
            _sectionTitle('المدفوعات'),
            if (controller.payments.isEmpty)
              const CustomEmptyState.compact(title: 'لا توجد مدفوعات')
            else
              ...controller.payments.map((item) => _financialTile(
                title: item['payment_reference']?.toString() ?? 'دفعة',
                status: item['status']?.toString(),
                amount: item['amount_minor'] ?? item['amount'],
                currencyCode: item['currency_code']?.toString(),
              )),
          ],
        ],
      ),
    );
  }

  Widget _contactTile(Map<String, dynamic> contact) {
    final id = (contact['contact_id'] as num?)?.toInt();
    final details = [
      contact['email'],
      contact['phone'],
      if (contact['is_primary'] == true) 'أساسية',
      if (contact['receives_invoices'] == true) 'تستقبل الفواتير',
    ].where((value) => value != null && value.toString().isNotEmpty).join(' • ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
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
                  : () => controller.updateContact(id, {'is_primary': true}),
            ),
          CustomButton.text(
            text: 'تعديل',
            onPressed: id == null
                ? null
                : () => BillingDialogs.editContact(controller, contact),
          ),
          CustomButton.text(
            text: 'حذف',
            foregroundColor: Colors.red,
            onPressed: id == null
                ? null
                : () => BillingDialogs.deleteContact(controller, id),
          ),
        ],
      ),
    );
  }

  Widget _planTile(Map<String, dynamic> plan) {
    final version = plan['current_version'];
    final prices = version is Map<String, dynamic> && version['prices'] is List
        ? version['prices'] as List<dynamic>
        : const <dynamic>[];
    final price = prices.isNotEmpty && prices.first is Map<String, dynamic>
        ? prices.first as Map<String, dynamic>
        : const <String, dynamic>{};
    final id = (price['price_id'] as num?)?.toInt();
    return Card(
      child: ListTile(
        title: Text(plan['name']?.toString() ?? 'خطة اشتراك'),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('السعر: '),
            CustomInteractiveAmountText(
              amount: price['unit_amount'] ?? price['unit_amount_minor'] ?? '—',
              currencyCode: price['currency_code']?.toString(),
              enableTooltip: false,
            ),
          ],
        ),
        trailing: CustomButton.primary(
          text: 'اختيار',
          loading: controller.isMutating.value,
          onPressed: id == null ? null : () => BillingDialogs.purchase(controller, id),
        ),
      ),
    );
  }

  Widget _subscriptionTile(Map<String, dynamic> subscription) {
    final id = (subscription['billing_subscription_id'] as num?)?.toInt();
    return Card(
      child: ListTile(
        title: Text(
          subscription['plan'] is Map<String, dynamic>
              ? subscription['plan']['name']?.toString() ?? 'اشتراك'
              : 'اشتراك',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BillingStatusBadge(
              status: subscription['status']?.toString(),
              serverLabel: subscription['status_label']?.toString(),
            ),
            Text('نهاية الفترة: ${subscription['current_period_end']?.toString() ?? '—'}'),
          ],
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 6,
          children: [
            CustomButton.text(
              text: 'التفاصيل',
              onPressed: id == null ? null : () => BillingDialogs.subscriptionDetails(controller, id),
            ),
            CustomButton.outline(
              text: 'إلغاء',
              onPressed: id == null ? null : () => BillingDialogs.cancelSubscription(controller, id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entitlementTile(Map<String, dynamic> feature) => Card(
    child: ListTile(
      title: Text(feature['name']?.toString() ?? feature['feature_key']?.toString() ?? 'ميزة'),
      subtitle: Text('القيمة: ${feature['configured_value']?.toString() ?? '—'}'),
      trailing: CustomStatusBadge(
        label: feature['available'] == true ? 'متاح' : 'غير متاح',
        tone: feature['available'] == true ? SemanticTone.success : SemanticTone.neutral,
        icon: feature['available'] == true
            ? Icons.check_circle_rounded
            : Icons.block_rounded,
      ),
    ),
  );

  Widget _trialCard(Map<String, dynamic> trial) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('حالة الفترة التجريبية', style: TextStyle(fontWeight: FontWeight.w700)),
          BillingStatusBadge(status: trial['status']?.toString()),
          Text(trial['awaiting_first_activation'] == true
              ? 'التجربة معتمدة وتبدأ عند أول تفعيل تشغيلي؛ لم يبدأ عدادها بعد.'
              : 'تفاصيل دورة التجربة كما وردت من الخادم.'),
          Text('تاريخ البدء: ${trial['start']?.toString() ?? 'لم تبدأ'}'),
          Text('تاريخ الانتهاء: ${trial['end']?.toString() ?? '—'}'),
        ],
      ),
    ),
  );

  Widget _invoiceTile(Map<String, dynamic> invoice) {
    final invoiceId = (invoice['invoice_id'] as num?)?.toInt();
    final remaining = int.tryParse(invoice['remaining_minor']?.toString() ?? '0') ?? 0;
    final canPay = remaining > 0 &&
        invoice['status'] != 'PAID' &&
        invoice['status'] != 'VOID' &&
        invoiceId != null;
    return Card(
      child: ListTile(
        title: Text(invoice['invoice_number']?.toString() ?? 'فاتورة'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BillingStatusBadge(
              status: invoice['status']?.toString(),
              serverLabel: invoice['status_label']?.toString(),
            ),
            Text('المتبقي: ${AmountFormatter.format(remaining.toString())} وحدة صغرى'),
          ],
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CustomInteractiveAmountText(
              amount: invoice['total_minor'] ?? '—',
              enableTooltip: false,
              trailingText: 'وحدة صغرى',
            ),
            if (canPay)
              CustomButton.primary(
                text: 'تسجيل دفعة',
                onPressed: () => BillingDialogs.payInvoice(controller, invoice),
              ),
          ],
        ),
      ),
    );
  }

  Widget _financialTile({
    required String title,
    required String? status,
    required dynamic amount,
    String? currencyCode,
  }) => Card(
    child: ListTile(
      title: Text(title),
      subtitle: BillingStatusBadge(status: status),
      trailing: CustomInteractiveAmountText(
        amount: amount ?? '—',
        currencyCode: currencyCode,
        enableTooltip: false,
      ),
    ),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
  );
}
