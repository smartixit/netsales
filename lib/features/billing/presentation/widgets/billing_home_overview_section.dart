import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomSurfaceCard(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مساحة فوترة الشبكة', style: AppTypography.titleSmall),
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
