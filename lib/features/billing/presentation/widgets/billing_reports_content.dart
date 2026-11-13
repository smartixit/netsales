import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_filter_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_labels.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_presentation_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_records_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_summary_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// Composition-only content for Billing subscription reports.
class BillingReportsContent extends StatelessWidget {
  const BillingReportsContent({
    super.key,
    required this.controller,
  });

  final BillingReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final catalogItems = controller.catalog
          .map(
            (item) => DropdownItem<String>(
              value: item['id'].toString(),
              child: Text(item['label']?.toString() ?? item['id'].toString()),
            ),
          )
          .toList(growable: false);
      final reportSummary = controller.summary.value;
      final definition = controller.currentDefinition;

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(context),
          const SizedBox(height: 16),
          if (catalogItems.isNotEmpty)
            CustomDropdown<String>(
              items: catalogItems,
              rxValue: controller.selectedType,
              onChanged: controller.selectReport,
              label: 'نوع التقرير',
              hint: 'اختر تقريراً',
            ),
          if (definition != null)
            ReportConfigurationStudio(
              definition: definition,
              criteria: controller.criteria.value,
              presentation: controller.presentation.value,
              resolveLabel: (context, key) =>
                  BillingReportLabels.resolve(context, controller, key),
              onCriteriaChanged: controller.setCriteria,
              onPresentationChanged: controller.setPresentation,
              onPreview: controller.applyFilters,
              isBusy: controller.isLoading.value,
              actionBuilder: (
                context, {
                required label,
                required icon,
                required onPressed,
                required secondary,
              }) =>
                  secondary
                      ? CustomButton.outline(
                          text: label,
                          prefix: icon,
                          onPressed: onPressed,
                        )
                      : CustomButton.primary(
                          text: label,
                          prefix: icon,
                          onPressed: onPressed,
                        ),
              filterSectionBuilder: (
                context, {
                required definition,
                required criteria,
                required resolveLabel,
                required onChanged,
              }) =>
                  BillingReportFilterSection(
                    controller: controller,
                    definition: definition,
                    criteria: criteria,
                    resolveLabel: resolveLabel,
                    onChanged: onChanged,
                  ),
              presentationSectionBuilder: (
                context, {
                required definition,
                required presentation,
                required resolveLabel,
                required onChanged,
              }) =>
                  BillingReportPresentationSection(
                    controller: controller,
                    definition: definition,
                    presentation: presentation,
                    resolveLabel: resolveLabel,
                    onChanged: onChanged,
                  ),
            ),
          if (controller.errorMessage.value != null)
            CustomErrorState.compact(
              title: 'تعذر تحميل بيانات التقرير',
              subtitle: controller.errorMessage.value,
              onRetry: controller.loadCatalog,
            ),
          if (reportSummary != null &&
              reportSummary['record_count'] is num)
            CustomResultsCounterBar(
              count: controller.rows.length,
              totalCount: (reportSummary['record_count'] as num).toInt(),
              recordLabel: 'سجل',
              isFiltered: controller.criteria.value.filters.isNotEmpty,
              isLoading: controller.isLoading.value,
              onClear: controller.criteria.value.filters.isEmpty
                  ? null
                  : () => controller.setCriteria(ReportCriteria()),
            ),
          if (reportSummary != null)
            BillingReportSummarySection(
              summary: reportSummary,
              charts: controller.charts,
              arabicLabel: BillingReportLabels.arabic,
            ),
          BillingReportRecordsSection(
            controller: controller,
            arabicLabel: BillingReportLabels.arabic,
            displayValue: BillingReportLabels.displayValue,
          ),
        ],
      );
    });
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تقارير الاشتراكات', style: AppTypography.titleLarge),
              Text(
                'تقارير Billing مستقلة عن تقارير المبيعات والتشغيل.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        CustomButton.outline(
          text: 'PDF تفصيلي',
          prefix: Icons.picture_as_pdf_outlined,
          loading: controller.isExportingPdf.value,
          onPressed: controller.isExportingPdf.value
              ? null
              : controller.exportPdfSummary,
        ),
        CustomButton.outline(
          text: 'تصدير CSV',
          prefix: Icons.download_rounded,
          onPressed: controller.isLoading.value ? null : controller.exportCsv,
        ),
        CustomButton.outline(
          text: 'تحديث',
          prefix: Icons.refresh_rounded,
          onPressed:
              controller.isLoading.value ? null : controller.loadCatalog,
        ),
      ],
    );
  }
}
