import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';

class BillingHomeOverviewSection extends StatelessWidget {
  const BillingHomeOverviewSection({
    required this.controller,
    required this.account,
    super.key,
  });

  final BillingController controller;
  final Map<String, dynamic> account;

  @override
  Widget build(BuildContext context) {
    final rawCurrency = account['default_currency'];
    final currency = rawCurrency is Map
        ? Map<String, dynamic>.from(rawCurrency)
        : const <String, dynamic>{};
    final currencyCode = currency['code']?.toString() ?? '—';
    final decimalPlaces = (currency['decimal_places'] as num?)?.toInt() ?? 2;

    return Obx(() {
      final latestInvoice = controller.invoices.isEmpty
          ? null
          : controller.invoices.first;
      final latestSubscription = controller.subscriptions.isEmpty
          ? null
          : controller.subscriptions.first;
      final rawPlan = latestSubscription?['plan'];
      final plan = rawPlan is Map
          ? Map<String, dynamic>.from(rawPlan)
          : const <String, dynamic>{};

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomSurfaceCard(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حساب فوترة الشبكة', style: AppTypography.titleSmall),
                const SizedBox(height: 8),
                Text(
                  account['legal_name']?.toString() ?? 'حساب الفوترة',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: 10),
                BillingStatusBadge(status: account['status']?.toString()),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _BillingAccountFact(
                      label: 'رقم الحساب',
                      value: account['account_number']?.toString() ?? '—',
                    ),
                    _BillingAccountFact(
                      label: 'عملة الحساب',
                      value: currencyCode,
                    ),
                    _BillingAccountFact(
                      label: 'شروط السداد',
                      value:
                          '${account['payment_terms_days']?.toString() ?? '0'} يوم',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 18, 4, 8),
            child: Text('آخر نشاط على الحساب', style: AppTypography.titleMedium),
          ),
          CustomSurfaceCard(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                CustomInfoListTile(
                  title: const Text('أحدث اشتراك'),
                  subtitle: latestSubscription == null
                      ? const Text('لا يوجد اشتراك مسجل حتى الآن')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan['name']?.toString() ?? 'اشتراك'),
                            BillingStatusBadge(
                              status: latestSubscription['status']?.toString(),
                              serverLabel:
                                  latestSubscription['status_label']?.toString(),
                            ),
                            Text(
                              'نهاية الفترة: ${latestSubscription['current_period_end']?.toString() ?? '—'}',
                            ),
                          ],
                        ),
                  trailing: const Icon(Icons.workspace_premium_outlined),
                ),
                const Divider(height: 1),
                CustomInfoListTile(
                  title: const Text('أحدث فاتورة'),
                  subtitle: latestInvoice == null
                      ? const Text('لا توجد فواتير صادرة لهذا الحساب')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              latestInvoice['invoice_number']?.toString() ??
                                  'فاتورة',
                            ),
                            BillingStatusBadge(
                              status: latestInvoice['status']?.toString(),
                              serverLabel:
                                  latestInvoice['status_label']?.toString(),
                            ),
                            CustomInteractiveAmountText(
                              amount: latestInvoice['remaining'] ?? '—',
                              currencyCode: currencyCode,
                              decimalPlaces: decimalPlaces,
                              enableTooltip: false,
                              trailingText: currencyCode,
                            ),
                          ],
                        ),
                  trailing: const Icon(Icons.receipt_long_outlined),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 18, 4, 8),
            child: Text('الوصول السريع', style: AppTypography.titleMedium),
          ),
          CustomSurfaceCard(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CustomButton.outline(
                  text: 'إدارة الاشتراك',
                  prefix: Icons.workspace_premium_outlined,
                  onPressed: () => controller.selectWorkspaceTab(1),
                ),
                CustomButton.outline(
                  text: 'عرض الفواتير',
                  prefix: Icons.receipt_long_outlined,
                  onPressed: () => controller.selectWorkspaceTab(2),
                ),
                CustomButton.outline(
                  text: 'النشاط المالي',
                  prefix: Icons.account_balance_wallet_outlined,
                  onPressed: () => controller.selectWorkspaceTab(3),
                ),
                CustomButton.outline(
                  text: 'بيانات الحساب',
                  prefix: Icons.business_outlined,
                  onPressed: () => controller.selectWorkspaceTab(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}

class _BillingAccountFact extends StatelessWidget {
  const _BillingAccountFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall),
        const SizedBox(height: 3),
        Text(value, style: AppTypography.titleSmall),
      ],
    );
  }
}
