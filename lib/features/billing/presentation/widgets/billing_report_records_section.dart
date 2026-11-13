import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

class BillingReportRecordsSection extends StatelessWidget {
  const BillingReportRecordsSection({
    required this.controller,
    required this.arabicLabel,
    required this.displayValue,
    super.key,
  });

  final BillingReportsController controller;
  final String Function(String key) arabicLabel;
  final String Function(String key, dynamic value) displayValue;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading.value && controller.rows.isEmpty) {
      return const CustomSkeletonFeed(itemCount: 3, shrinkWrap: true);
    }
    if (controller.rows.isEmpty) {
      return const CustomEmptyState.boxed(
        title: 'لا توجد سجلات مطابقة',
        subtitle: 'غيّر معايير البحث أو الفلاتر ثم أعد تحميل التقرير.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...controller.rows.map(
          (row) => CustomSurfaceCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: row.entries
                  .take(8)
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '${arabicLabel(entry.key)}: '
                        '${displayValue(entry.key, entry.value)}',
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
        CustomCursorLoadMore(
          hasMore: controller.hasMore,
          isLoading: controller.isLoadingMore.value,
          error: controller.loadMoreError.value,
          onPressed: controller.loadMore,
          label: 'تحميل المزيد من سجلات التقرير',
        ),
      ],
    );
  }
}
