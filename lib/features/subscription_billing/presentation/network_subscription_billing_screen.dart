import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/subscription_billing/domain/entities/network_billing_record.dart';
import 'package:netsales/features/subscription_billing/presentation/network_subscription_billing_controller.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class NetworkSubscriptionBillingScreen extends GetView<NetworkSubscriptionBillingController> {
  const NetworkSubscriptionBillingScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomAppScaffold(
    appBarTitle: 'اشتراكات وفوترة NetSales',
    appBarSubtitle: 'حسابات الاشتراك والفواتير والمدفوعات وكشوف الحساب',
    body: Padding(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Obx(() {
        if (controller.isLoadingAccounts.value) return const CustomSkeletonFeed(itemCount: 4);
        if (controller.error.value != null && controller.accounts.isEmpty) {
          return CustomErrorState.compact(title: 'تعذر تحميل حسابات الاشتراك', subtitle: controller.error.value, onRetry: controller.loadAccounts);
        }
        if (controller.accounts.isEmpty) {
          return ListView(
            children: [
              const CustomEmptyState.compact(
                title: 'لا يوجد حساب فوترة',
                subtitle: 'أنشئ حساب فوترة للشبكة لتتمكن من شراء الخطط ومتابعة الفواتير والمدفوعات.',
                icon: Icons.receipt_long_outlined,
              ),
              if (controller.currencies.isNotEmpty) ...[
                AppSpacing.vMd,
                CustomDropdown<int>(
                  label: 'العملة الأساسية لحساب الفوترة',
                  hint: 'اختر عملة الحساب',
                  rxValue: controller.selectedCurrencyId,
                  items: controller.currencies.map((currency) => DropdownItem<int>(
                    value: (currency['currency_id'] as num).toInt(),
                    child: Text('${currency['code'] ?? ''} — ${currency['name'] ?? ''}'),
                  )).toList(growable: false),
                  onChanged: (value) => controller.selectedCurrencyId.value = value,
                  isRequired: true,
                ),
                AppSpacing.vMd,
                CustomButton.primary(
                  text: 'إنشاء حساب الفوترة',
                  prefix: Icons.add_card_rounded,
                  loading: controller.isCreatingAccount.value,
                  onPressed: controller.isCreatingAccount.value
                      ? null
                      : controller.createBillingAccount,
                ),
              ],
              if (controller.error.value != null)
                CustomErrorState.compact(
                  title: 'تعذر إنشاء الحساب',
                  subtitle: controller.error.value,
                  onRetry: controller.loadAccounts,
                ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AccountSelector(controller: controller),
            AppSpacing.vMd,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final section in NetworkBillingSection.values)
                  CustomButton(
                    text: _sectionLabel(section),
                    variant: controller.selectedSection.value == section ? AppButtonVariant.primary : AppButtonVariant.outline,
                    size: AppButtonSize.small,
                    onPressed: () => controller.selectSection(section),
                  ),
              ],
            ),
            AppSpacing.vMd,
            Expanded(
              child: controller.isLoading.value
                  ? const CustomSkeletonFeed(itemCount: 4)
                  : controller.error.value != null
                      ? CustomErrorState.compact(title: 'تعذر تحميل بيانات الاشتراك', subtitle: controller.error.value, onRetry: () => controller.loadSection(controller.selectedSection.value))
                      : controller.selectedSection.value == NetworkBillingSection.statement
                          ? _StatementView(data: controller.statementData.value ?? const {})
                          : controller.records.isEmpty
                              ? const CustomEmptyState.compact(title: 'لا توجد سجلات', subtitle: 'لا توجد بيانات ضمن هذا القسم لحساب الفوترة المحدد.')
                              : NotificationListener<ScrollNotification>(
                                  onNotification: (notification) {
                                    if (notification.metrics.pixels >=
                                            notification.metrics.maxScrollExtent - 160 &&
                                        controller.hasMore &&
                                        !controller.isLoadingMore.value) {
                                      controller.loadMore();
                                    }
                                    return false;
                                  },
                                  child: ListView.separated(
                                    itemCount: controller.records.length +
                                        ((controller.hasMore || controller.loadMoreError.value != null ||
                                                controller.isLoadingMore.value) ? 1 : 0),
                                    separatorBuilder: (_, _) => AppSpacing.vSm,
                                    itemBuilder: (context, index) {
                                      if (index < controller.records.length) {
                                        return _BillingRecordCard(
                                          record: controller.records[index],
                                          section: controller.selectedSection.value,
                                        );
                                      }
                                      if (controller.loadMoreError.value != null) {
                                        return CustomErrorState.compact(
                                          title: 'تعذر تحميل بقية السجلات',
                                          subtitle: controller.loadMoreError.value,
                                          onRetry: controller.loadMore,
                                        );
                                      }
                                      return const CustomSkeletonFeed(itemCount: 1);
                                    },
                                  ),
                                ),
            ),
          ],
        );
      }),
    ),
  );
}

class _AccountSelector extends StatelessWidget {
  const _AccountSelector({required this.controller});
  final NetworkSubscriptionBillingController controller;

  @override
  Widget build(BuildContext context) {
    final account = controller.accounts.firstWhereOrNull((a) => a.id == controller.selectedAccountId.value);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('حساب الفوترة', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.vSm,
            CustomDropdown<int>(
              label: 'الحساب',
              hint: 'اختر حساب الفوترة',
              rxValue: controller.selectedAccountId,
              searchEnabled: controller.accounts.length > 5,
              items: controller.accounts.map((item) => DropdownItem<int>(
                value: item.id,
                child: Text('${item.value('account_number')} — ${item.value('legal_name')}'),
              )).toList(growable: false),
              onChanged: controller.selectAccount,
              isRequired: true,
            ),
            if (account != null) ...[
              AppSpacing.vXs,
              Text('الحالة: ${account.value('status')}  •  العملة الافتراضية: ${account.currencyCode}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _BillingRecordCard extends StatelessWidget {
  const _BillingRecordCard({required this.record, required this.section});
  final NetworkBillingRecord record;
  final NetworkBillingSection section;

  @override
  Widget build(BuildContext context) {
    final data = record.data;
    final title = switch (section) {
      NetworkBillingSection.subscriptions => data['plan'] is Map ? (data['plan']['name']?.toString() ?? 'اشتراك') : 'اشتراك',
      NetworkBillingSection.invoices => record.value('invoice_number', 'فاتورة اشتراك'),
      NetworkBillingSection.payments => record.value('payment_reference', 'دفعة'),
      NetworkBillingSection.creditNotes => record.value('credit_note_number', 'إشعار دائن'),
      NetworkBillingSection.refunds => record.value('refund_reference', 'استرداد'),
      NetworkBillingSection.statement => 'كشف الحساب',
    };
    final amount = data['total'] ?? data['amount'] ?? data['remaining'] ?? data['amount_minor'];
    final currency = record.currencyCode;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              if (record.value('status_label', '').isNotEmpty)
                Chip(label: Text(record.value('status_label'))),
            ]),
            if (amount != null) ...[
              AppSpacing.vXs,
              Text('$amount $currency', style: Theme.of(context).textTheme.titleLarge),
            ],
            AppSpacing.vXs,
            Text(_secondary(record, section), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  String _secondary(NetworkBillingRecord record, NetworkBillingSection section) => switch (section) {
    NetworkBillingSection.subscriptions => 'من ${record.value('current_period_start')} إلى ${record.value('current_period_end')}',
    NetworkBillingSection.invoices => 'تاريخ الإصدار: ${record.value('issued_on')} • الاستحقاق: ${record.value('due_on')}',
    NetworkBillingSection.payments => 'الفاتورة: ${record.value('invoice_number')} • الاعتماد: ${record.value('verified_at')}',
    NetworkBillingSection.creditNotes => 'تاريخ الإصدار: ${record.value('issued_at')} • المبلغ المطبق: ${record.value('applied_to_receivable_minor')}',
    NetworkBillingSection.refunds => 'الحالة: ${record.value('status')} • تاريخ الإنشاء: ${record.value('created_at')}',
    NetworkBillingSection.statement => '',
  };
}

class _StatementView extends StatelessWidget {
  const _StatementView({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final balances = data['balances_by_currency'] is List ? data['balances_by_currency'] as List : const [];
    return ListView(
      children: [
        Text('كشف حركة حساب الاشتراك', style: Theme.of(context).textTheme.titleLarge),
        AppSpacing.vSm,
        Text('الفترة: ${(data['period'] as Map?)?['from'] ?? '—'} إلى ${(data['period'] as Map?)?['to'] ?? '—'}'),
        AppSpacing.vMd,
        for (final raw in balances.whereType<Map>())
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${(raw['currency'] is Map ? raw['currency']['code'] : null) ?? 'العملة'}', style: Theme.of(context).textTheme.titleMedium),
                Text('الرصيد الافتتاحي: ${raw['opening_receivable'] ?? raw['opening_receivable_minor'] ?? '—'}'),
                Text('الفواتير: ${raw['invoiced'] ?? raw['invoiced_minor'] ?? '—'}'),
                Text('المدفوع: ${raw['verified_payments'] ?? raw['verified_payments_minor'] ?? '—'}'),
                Text('الإشعارات الدائنة: ${raw['credits_applied'] ?? raw['credits_applied_minor'] ?? '—'}'),
                Text('الرصيد الختامي: ${raw['closing_receivable'] ?? raw['closing_receivable_minor'] ?? '—'}'),
                Text('رصيد العميل الدائن: ${raw['closing_customer_credit'] ?? raw['closing_customer_credit_minor'] ?? '—'}'),
              ]),
            ),
          ),
      ],
    );
  }
}

String _sectionLabel(NetworkBillingSection section) => switch (section) {
  NetworkBillingSection.subscriptions => 'الاشتراكات',
  NetworkBillingSection.invoices => 'الفواتير',
  NetworkBillingSection.payments => 'المدفوعات',
  NetworkBillingSection.creditNotes => 'الإشعارات الدائنة',
  NetworkBillingSection.refunds => 'المبالغ المستردة',
  NetworkBillingSection.statement => 'كشف الحساب',
};
