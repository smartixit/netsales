import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_charts_section.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_summary_strip.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';

/// Presents server-provided summary metrics and chart slots for the report.
class OperationalReportSummaryAndCharts extends StatelessWidget {
  const OperationalReportSummaryAndCharts({
    required this.controller,
    super.key,
  });

  final OperationalReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final summary = controller.summary.value;
          final type = controller.selectedType.value;
          if (summary == null || type == null) {
            final failure = controller.summaryError.value;
            if (failure == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CustomErrorState.compact(
                title: 'تعذر تحميل الملخص المالي',
                subtitle: failure,
                onRetry: () => controller.loadReport(refresh: true),
              ),
            );
          }

          if (!controller.presentation.value.includeMetrics) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OperationalReportSummaryStrip(summary: summary),
          );
        }),
        Obx(() {
          final summary = controller.summary.value;
          if (summary == null ||
              !controller.presentation.value.includeCharts) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OperationalReportChartsSection(summary: summary),
          );
        }),
      ],
    );
  }
}
