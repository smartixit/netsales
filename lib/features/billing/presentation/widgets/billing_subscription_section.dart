import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_cursor_collection_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_dialogs.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_collection_status_options.dart';

class BillingSubscriptionSection extends StatelessWidget {
  const BillingSubscriptionSection({required this.controller, super.key});

  final BillingController controller;

  @override
  Widget build(BuildContext context) {
    return BillingCursorCollectionSection(
      title: 'الاشتراك الحالي',
      emptyTitle: 'لا يوجد اشتراك مسجل حالياً',
      page: controller.subscriptionsPage,
      itemBuilder: _tile,
      onLoadMore: controller.loadMoreSubscriptions,
      loadMoreLabel: 'تحميل المزيد من الاشتراكات',
      filterState: controller.subscriptionsFilter,
      statusOptions: BillingCollectionStatusOptions.build(
        controller.subscriptionsFilter.statusValues,
      ),
      onSearchChanged: controller.searchSubscriptions,
      onStatusChanged: controller.setSubscriptionStatus,
      onRefresh: controller.refreshSubscriptions,
      searchHint: 'ابحث باسم الخطة أو رقم الاشتراك',
    );
  }

  Widget _tile(Map<String, dynamic> subscription) {
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
            Text(
              'نهاية الفترة: ${subscription['current_period_end']?.toString() ?? '—'}',
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 6,
          children: [
            CustomButton.text(
              text: 'التفاصيل',
              onPressed: id == null
                  ? null
                  : () => BillingDialogs.subscriptionDetails(controller, id),
            ),
            CustomButton.outline(
              text: 'إلغاء',
              onPressed: id == null
                  ? null
                  : () => BillingDialogs.cancelSubscription(controller, id),
            ),
          ],
        ),
      ),
    );
  }
}
