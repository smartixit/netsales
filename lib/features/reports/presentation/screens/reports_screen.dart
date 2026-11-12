import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/reports/domain/entities/report_type.dart';
import 'package:netsales/features/reports/presentation/controllers/reports_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class ReportsScreen extends GetView<ReportsController> {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomAppScaffold(
    appBar: AppBar(title: const Text('التقارير التشغيلية')),
    body: Column(children: [
      Obx(() {
        if (controller.isResolvingContext.value) {
          return const LinearProgressIndicator();
        }
        if (controller.networks.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
          child: DropdownButtonFormField<int>(
            value: controller.selectedNetworkId.value,
            decoration: const InputDecoration(
              labelText: 'الشبكة',
              border: OutlineInputBorder(),
            ),
            items: controller.networks.map((network) => DropdownMenuItem<int>(
              value: network.networkId,
              child: Text(network.name, overflow: TextOverflow.ellipsis),
            )).toList(growable: false),
            onChanged: controller.selectNetwork,
          ),
        );
      }),
      SizedBox(
        height: 56,
        child: Obx(() => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          children: ReportType.values.map((type) => Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: CustomButton(
              text: type.label,
              size: AppButtonSize.small,
              variant: controller.selectedType.value == type
                  ? AppButtonVariant.primary
                  : AppButtonVariant.outline,
              onPressed: () => controller.selectType(type),
            ),
          )).toList(growable: false),
        )),
      ),
      Expanded(child: Obx(() {
        if (controller.loading.value && controller.rows.isEmpty) {
          return const CustomSkeletonFeed(itemCount: 5);
        }
        if (controller.error.value != null && controller.rows.isEmpty) {
          return CustomEmptyState(
            icon: Icons.assessment_outlined,
            title: 'تعذر تحميل التقرير',
            subtitle: controller.error.value!,
            actionLabel: 'إعادة المحاولة',
            onAction: controller.resolveNetworks,
          );
        }
        if (controller.selectedNetworkId.value == null &&
            !controller.isResolvingContext.value) {
          return const CustomEmptyState(
            icon: Icons.domain_outlined,
            title: 'اختر نطاق التقرير',
            subtitle: 'حدد الشبكة المطلوبة لعرض تقاريرها. إذا كان لديك أكثر من نطاق، يجب اختيار أحدها صراحةً.',
          );
        }
        if (controller.rows.isEmpty) {
          return const CustomEmptyState(
            icon: Icons.insert_chart_outlined,
            title: 'لا توجد بيانات',
            subtitle: 'لا توجد سجلات مطابقة للتقرير المحدد.',
          );
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (event) {
            if (event.metrics.pixels >= event.metrics.maxScrollExtent - 180 &&
                controller.hasMore && !controller.loadingMore.value) {
              controller.load();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.rows.length + (controller.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.rows.length) {
                return const CustomSkeletonFeed(itemCount: 1, shrinkWrap: true);
              }
              final row = controller.rows[index];
              final heading = row['invoice_uuid'] ?? row['invoice_number'] ??
                  row['expense_number'] ?? row['repayment_uuid'] ??
                  row['request_uuid'] ?? row['id'] ?? 'سجل تشغيلي';
              final date = row['invoice_date'] ?? row['expense_date'] ??
                  row['repayment_date'] ?? row['request_date'] ?? row['created_at'] ?? '';
              final amount = row['total_amount'] ?? row['amount'] ?? row['remaining_amount'];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(heading.toString(),
                          style: Theme.of(context).textTheme.titleMedium)),
                        if (amount != null) Text(amount.toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                      ]),
                      if (date.toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(date.toString()),
                      ],
                      const SizedBox(height: 8),
                      Text(row.entries
                        .where((entry) => entry.value != null && entry.key != 'items')
                        .take(5)
                        .map((entry) => '${entry.key}: ${entry.value}')
                        .join(' • ')),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      })),
    ]),
  );
}
