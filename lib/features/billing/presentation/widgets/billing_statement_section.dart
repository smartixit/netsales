import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';

class BillingStatementSection extends StatelessWidget {
  const BillingStatementSection({required this.controller, super.key});

  final BillingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final statement = controller.statementData.value;
      final rawBalances = statement?['balances_by_currency'];
      final balances = rawBalances is List
          ? rawBalances
                .whereType<Map>()
                .map((row) => Map<String, dynamic>.from(row))
                .toList(growable: false)
          : const <Map<String, dynamic>>[];
      final period = statement?['period'];
      final periodData = period is Map
          ? Map<String, dynamic>.from(period)
          : const <String, dynamic>{};

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 18, 4, 8),
            child: Text('ملخص الذمم والأرصدة', style: AppTypography.titleMedium),
          ),
          if (controller.isStatementLoading.value && statement == null)
            const CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 2,
                cardHeight: 112,
              ),
            )
          else if (controller.statementError.value != null && statement == null)
            CustomErrorState.compact(
              title: 'تعذر تحميل كشف النشاط',
              subtitle: controller.statementError.value,
              onRetry: controller.loadStatement,
            )
          else if (balances.isEmpty)
            const CustomEmptyState.compact(
              title: 'لا توجد حركة مالية مسجلة ضمن الفترة المعروضة',
            )
          else ...[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 8),
              child: Text(
                'الفترة: ${periodData['from']?.toString() ?? '—'} – ${periodData['to']?.toString() ?? '—'}',
                style: AppTypography.bodySmall,
              ),
            ),
            ...balances.map((balance) {
              final rawCurrency = balance['currency'];
              final currency = rawCurrency is Map
                  ? Map<String, dynamic>.from(rawCurrency)
                  : const <String, dynamic>{};
              final code = currency['code']?.toString();
              final places = (currency['decimal_places'] as num?)?.toInt() ?? 2;
  
              return CustomSurfaceCard(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 4),
                      child: Text(
                        '${currency['name']?.toString() ?? 'العملة'} (${code ?? '—'})',
                        style: AppTypography.titleSmall,
                      ),
                    ),
                    CustomInfoListTile(
                      title: const Text('الذمم الافتتاحية'),
                      trailing: CustomInteractiveAmountText(
                        amount: balance['opening_receivable'] ?? '—',
                        currencyCode: code,
                        decimalPlaces: places,
                        enableTooltip: false,
                        trailingText: code,
                      ),
                    ),
                    CustomInfoListTile(
                      title: const Text('الفواتير الصادرة'),
                      trailing: CustomInteractiveAmountText(
                        amount: balance['invoiced'] ?? '—',
                        currencyCode: code,
                        decimalPlaces: places,
                        enableTooltip: false,
                        trailingText: code,
                      ),
                    ),
                    CustomInfoListTile(
                      title: const Text('المدفوعات المعتمدة'),
                      trailing: CustomInteractiveAmountText(
                        amount: balance['verified_payments'] ?? '—',
                        currencyCode: code,
                        decimalPlaces: places,
                        enableTooltip: false,
                        trailingText: code,
                      ),
                    ),
                    CustomInfoListTile(
                      title: const Text('الإشعارات المطبقة'),
                      trailing: CustomInteractiveAmountText(
                        amount: balance['credits_applied'] ?? '—',
                        currencyCode: code,
                        decimalPlaces: places,
                        enableTooltip: false,
                        trailingText: code,
                      ),
                    ),
                    CustomInfoListTile(
                      title: const Text('الذمم المستحقة'),
                      trailing: CustomInteractiveAmountText(
                        amount: balance['closing_receivable'] ?? '—',
                        currencyCode: code,
                        decimalPlaces: places,
                        enableTooltip: false,
                        trailingText: code,
                      ),
                    ),
                    CustomInfoListTile(
                      title: const Text('رصيد العميل الدائن'),
                      trailing: CustomInteractiveAmountText(
                        amount: balance['closing_customer_credit'] ?? '—',
                        currencyCode: code,
                        decimalPlaces: places,
                        enableTooltip: false,
                        trailingText: code,
                      ),
                    ),
                    CustomInfoListTile(
                      title: const Text('رصيد قابل للاسترداد'),
                      trailing: CustomInteractiveAmountText(
                        amount: balance['closing_refundable_credit'] ?? '—',
                        currencyCode: code,
                        decimalPlaces: places,
                        enableTooltip: false,
                        trailingText: code,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
        );
    });
  }
}
