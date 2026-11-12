import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_record_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

class OperationalReportRecordsList extends StatelessWidget {
  const OperationalReportRecordsList({
    required this.controller,
    super.key,
  });

  final OperationalReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.requiresPosSelection) {
        return const CustomEmptyState.compact(
          title: 'حدد نقطة بيع',
          subtitle: 'كشف محفظة نقطة البيع يتطلب اختيار نقطة البيع أولاً.',
          icon: Icons.storefront_outlined,
        );
      }

      if (controller.isLoading.value && controller.reports.isEmpty) {
        return const CustomSkeletonFeed(itemCount: 5);
      }

      if (controller.errorMessage.value != null &&
          controller.reports.isEmpty) {
        return CustomErrorState.compact(
          title: 'تعذر تحميل التقرير',
          subtitle: controller.errorMessage.value,
          onRetry: () => controller.loadReport(refresh: true),
        );
      }

      if (controller.reports.isEmpty) {
        return const CustomEmptyState.compact(
          title: 'لا توجد سجلات مطابقة',
          subtitle: 'غيّر الفترة أو عوامل التصفية لعرض نتائج أخرى.',
          icon: Icons.query_stats_rounded,
        );
      }

      final type = controller.selectedType.value;
      if (type == null) return const SizedBox.shrink();

      final hasTail = controller.hasMore ||
          controller.loadMoreError.value != null ||
          controller.isLoadingMore.value;

      return RefreshIndicator(
        onRefresh: () => controller.loadReport(refresh: true),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 180 &&
                controller.hasMore &&
                !controller.isLoadingMore.value &&
                controller.loadMoreError.value == null) {
              controller.loadReport();
            }
            return false;
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.reports.length + (hasTail ? 1 : 0),
            separatorBuilder: (_, _) => AppSpacing.vSm,
            itemBuilder: (context, index) {
              if (index == controller.reports.length) {
                if (controller.loadMoreError.value != null) {
                  return CustomErrorState.compact(
                    title: 'تعذر تحميل بقية السجلات',
                    subtitle: controller.loadMoreError.value,
                    onRetry: () => controller.loadReport(refresh: true),
                  );
                }
                if (controller.isLoadingMore.value) {
                  return const CustomSkeletonCard(height: 104);
                }
                return Center(
                  child: CustomButton.outline(
                    text: 'تحميل المزيد من السجلات',
                    suffix: Icons.expand_more_rounded,
                    onPressed: () => controller.loadReport(),
                  ),
                );
              }

              return OperationalReportRecordCard(
                record: controller.reports[index],
                type: type,
              );
            },
          ),
        ),
      );
    });
  }
}
