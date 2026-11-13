import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_dialogs.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/dividers/custom_divider.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_cursor_collection_section.dart';

class BillingWorkspaceContent extends StatelessWidget {
  const BillingWorkspaceContent({super.key, required this.controller});

  final BillingController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
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
                  style: AppTypography.titleLarge,
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
            CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
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
                    const Text('جهات الاتصال', style: AppTypography.titleSmall),
                    if (account['contacts'] is List &&
                        (account['contacts'] as List).isNotEmpty)
                      ...(account['contacts'] as List<dynamic>)
                          .whereType<Map<String, dynamic>>()
                          .map((contact) => _contactTile(context, contact))
                    else
                      const CustomEmptyState.compact(title: 'لا توجد جهات اتصال مسجلة'),
                  ],
                ),
              ),
            ),
            BillingCursorCollectionSection(
              title: 'الخطط المتاحة',
              emptyTitle: 'لا توجد خطط متاحة لهذا الحساب',
              page: controller.plansPage,
              itemBuilder: (row) => _planTile(context, row),
              onLoadMore: controller.loadMorePlans,
              loadMoreLabel: 'تحميل المزيد من الخطط',
            ),
            BillingCursorCollectionSection(
              title: 'الاشتراك الحالي',
              emptyTitle: 'لا يوجد اشتراك مسجل حالياً',
              page: controller.subscriptionsPage,
              itemBuilder: _subscriptionTile,
              onLoadMore: controller.loadMoreSubscriptions,
              loadMoreLabel: 'تحميل المزيد من الاشتراكات',
            ),
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
            BillingCursorCollectionSection(
              title: 'الفواتير',
              emptyTitle: 'لا توجد فواتير',
              page: controller.invoicesPage,
              itemBuilder: _invoiceTile,
              onLoadMore: controller.loadMoreInvoices,
              loadMoreLabel: 'تحميل المزيد من الفواتير',
            ),
            BillingCursorCollectionSection(
              title: 'الإشعارات الدائنة',
              emptyTitle: 'لا توجد إشعارات دائنة',
              page: controller.creditNotesPage,
              itemBuilder: (item) => _financialTile(
                title: item['credit_note_number']?.toString() ?? 'إشعار دائن',
                status: item['status']?.toString(),
                amount: item['total_minor'],
                currencyCode: item['currency_code']?.toString(),
              ),
              onLoadMore: controller.loadMoreCreditNotes,
              loadMoreLabel: 'تحميل المزيد من الإشعارات الدائنة',
            ),
            BillingCursorCollectionSection(
              title: 'الاستردادات',
              emptyTitle: 'لا توجد استردادات',
              page: controller.refundsPage,
              itemBuilder: (item) => _financialTile(
                title: item['refund_reference']?.toString() ?? 'استرداد',
                status: item['status']?.toString(),
                amount: item['amount_minor'],
                currencyCode: item['currency_code']?.toString(),
              ),
              onLoadMore: controller.loadMoreRefunds,
              loadMoreLabel: 'تحميل المزيد من الاستردادات',
            ),
            BillingCursorCollectionSection(
              title: 'المدفوعات',
              emptyTitle: 'لا توجد مدفوعات',
              page: controller.paymentsPage,
              itemBuilder: (item) => _financialTile(
                title: item['payment_reference']?.toString() ?? 'دفعة',
                status: item['status']?.toString(),
                amount: item['amount_minor'] ?? item['amount'],
                currencyCode: item['currency_code']?.toString(),
              ),
              onLoadMore: controller.loadMorePayments,
              loadMoreLabel: 'تحميل المزيد من المدفوعات',
            ),
          ],
        ],
      ),
    );
  });

  Widget _contactTile(BuildContext context, Map<String, dynamic> contact) {
    final id = (contact['contact_id'] as num?)?.toInt();
    final details = [
      contact['email'],
      contact['phone'],
      if (contact['is_primary'] == true) 'أساسية',
      if (contact['receives_invoices'] == true) 'تستقبل الفواتير',
    ].where((value) => value != null && value.toString().isNotEmpty).join(' • ');
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
            foregroundColor: Theme.of(context).colorScheme.error,
            onPressed: id == null
                ? null
                : () => BillingDialogs.deleteContact(controller, id),
          ),
        ],
      ),
    );
  }

  Widget _planTile(BuildContext context, Map<String, dynamic> plan) {
    final version = plan['current_version'];
    final rawPrices =
        version is Map<String, dynamic> ? version['prices'] : null;
    final prices = rawPrices is List
        ? rawPrices.whereType<Map<String, dynamic>>().toList(growable: false)
        : const <Map<String, dynamic>>[];

    return CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 6),
            child: Text(
              plan['name']?.toString() ?? 'خطة اشتراك',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (prices.isEmpty)
            const CustomEmptyState.compact(
              title: 'لا توجد أسعار نشطة بهذه العملة',
            )
          else
            for (var index = 0; index < prices.length; index++) ...[
              if (index > 0)
                const CustomDivider(extent: 1),
              _planPriceTile(prices[index]),
            ],
        ],
      ),
    );
  }

  Widget _planPriceTile(Map<String, dynamic> price) {
    final id = (price['price_id'] as num?)?.toInt();
    final amount =
        price['unit_amount'] ?? price['unit_amount_minor'] ?? '—';
    final currencyCode = price['currency_code']?.toString();

    return CustomInfoListTile(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
      minHeight: 64,
      title: Text(_billingIntervalLabel(price)),
      subtitle: CustomInteractiveAmountText(
        amount: amount,
        currencyCode: currencyCode,
        trailingText: price['unit_amount'] != null
            ? currencyCode
            : 'وحدة صغرى',
        enableTooltip: false,
      ),
      trailing: CustomButton.primary(
        text: 'اختيار',
        loading: controller.isMutating.value,
        onPressed: id == null
            ? null
            : () => BillingDialogs.purchase(controller, id),
      ),
    );
  }

  String _billingIntervalLabel(Map<String, dynamic> price) {
    final interval = price['billing_interval']?.toString().toUpperCase();
    final count = (price['interval_count'] as num?)?.toInt() ?? 1;
    const units = {
      'DAY': 'يوم',
      'WEEK': 'أسبوع',
      'MONTH': 'شهر',
      'YEAR': 'سنة',
    };
    if (interval == 'ONE_TIME') return 'دفعة واحدة';
    final unit = units[interval] ?? 'فترة';
    return count == 1 ? 'كل $unit' : 'كل $count $unit';
  }

  Widget _subscriptionTile(Map<String, dynamic> subscription) {
    final id = (subscription['billing_subscription_id'] as num?)?.toInt();
    return CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
      child: CustomInfoListTile(
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

  Widget _entitlementTile(Map<String, dynamic> feature) => CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
    child: CustomInfoListTile(
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

  Widget _trialCard(Map<String, dynamic> trial) => CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('حالة الفترة التجريبية', style: AppTypography.titleSmall),
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
    return CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
      child: CustomInfoListTile(
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
          trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CustomInteractiveAmountText(
              amount: invoice['total_minor'] ?? '—',
              currencyCode: invoice['currency_code']?.toString(),
              enableTooltip: false,
              trailingText: invoice['currency_code'] == null
                  ? 'وحدة صغرى'
                  : '${invoice['currency_code']} · وحدة صغرى',
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
  }) => CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
    child: CustomInfoListTile(
      title: Text(title),
      subtitle: BillingStatusBadge(status: status),
      trailing: CustomInteractiveAmountText(
        amount: amount ?? '—',
        currencyCode: currencyCode,
        enableTooltip: false,
        trailingText: currencyCode == null
            ? 'وحدة صغرى'
            : '$currencyCode · وحدة صغرى',
      ),
    ),
  );

}
