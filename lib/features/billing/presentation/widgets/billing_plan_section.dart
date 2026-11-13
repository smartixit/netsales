import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_cursor_collection_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_dialogs.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/dividers/custom_divider.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';

class BillingPlanSection extends StatelessWidget {
  const BillingPlanSection({required this.controller, super.key});

  final BillingController controller;

  @override
  Widget build(BuildContext context) {
    return BillingCursorCollectionSection(
      title: 'الخطط المتاحة',
      emptyTitle: 'لا توجد خطط متاحة لهذا الحساب',
      page: controller.plansPage,
      itemBuilder: (plan) => _planCard(context, plan),
      onLoadMore: controller.loadMorePlans,
      loadMoreLabel: 'تحميل المزيد من الخطط',
    );
  }

  Widget _planCard(BuildContext context, Map<String, dynamic> plan) {
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
              if (index > 0) const CustomDivider(extent: 1),
              _priceTile(prices[index]),
            ],
        ],
      ),
    );
  }

  Widget _priceTile(Map<String, dynamic> price) {
    final id = (price['price_id'] as num?)?.toInt();
    final amount =
        price['unit_amount'] ?? price['unit_amount_minor'] ?? '—';
    final currencyCode = price['currency_code']?.toString();

    return CustomInfoListTile(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
      minHeight: 64,
      title: Text(_intervalLabel(price)),
      subtitle: CustomInteractiveAmountText(
        amount: amount,
        currencyCode: currencyCode,
        trailingText:
            price['unit_amount'] != null ? currencyCode : 'وحدة صغرى',
        enableTooltip: false,
      ),
      trailing: CustomButton.primary(
        text: 'اختيار',
        loading: controller.isMutating.value,
        onPressed:
            id == null ? null : () => BillingDialogs.purchase(controller, id),
      ),
    );
  }

  String _intervalLabel(Map<String, dynamic> price) {
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
}
