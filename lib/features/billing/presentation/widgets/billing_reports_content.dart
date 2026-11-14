import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_filter_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_labels.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_presentation_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_records_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_summary_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_reports_header.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';

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
      final english = controller.selectedLocale.value == 'en';
      final catalogItems = controller.catalog
          .map(
            (item) => DropdownItem<String>(
              value: item['id'].toString(),
              child: Text(
                english
                    ? BillingReportLabels.englishReport(item['id'].toString())
                    : item['label']?.toString() ?? item['id'].toString(),
              ),
            ),
          )
          .toList(growable: false);
      final reportSummary = controller.summary.value;
      final definition = controller.currentDefinition;

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          BillingReportsHeader(
            isExportingPdf: controller.isExportingPdf.value,
            isExportingCsv: controller.isExportingCsv.value,
            isLoading: controller.isLoading.value,
            title: english ? 'Subscription reports' : 'تقارير الاشتراكات',
            subtitle: english
                ? 'Billing reports are separate from sales and operational reports.'
                : 'تقارير Billing مستقلة عن تقارير المبيعات والتشغيل.',
            onExportPdf: controller.exportPdfSummary,
            onExportCsv: controller.exportCsv,
            onRefresh: controller.loadCatalog,
          ),
          const SizedBox(height: 16),
          if (catalogItems.isNotEmpty)
            CustomDropdown<String>(
              items: catalogItems,
              rxValue: controller.selectedType,
              onChanged: controller.selectReport,
              label: english ? 'Report type' : 'نوع التقرير',
              hint: english ? 'Select a report' : 'اختر تقريراً',
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
                    english: english,
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
                    english: english,
                  ),
            ),
          if (controller.errorMessage.value != null)
            CustomErrorState.compact(
              title: english ? 'Unable to load report data' : 'تعذر تحميل بيانات التقرير',
              subtitle: controller.errorMessage.value,
              onRetry: controller.loadCatalog,
            ),
          if (reportSummary != null &&
              reportSummary['record_count'] is num)
            CustomResultsCounterBar(
              count: controller.rows.length,
              totalCount: (reportSummary['record_count'] as num).toInt(),
              recordLabel: english ? 'Records' : 'سجل',
              isFiltered: controller.criteria.value.filters.isNotEmpty,
              isLoading: controller.isLoading.value,
              onClear: controller.criteria.value.filters.isEmpty
                  ? null
                  : controller.clearFilters,
            ),
          if (reportSummary != null)
            BillingReportSummarySection(
              summary: reportSummary,
              charts: controller.charts,
              title: english ? 'Report summary' : 'ملخص التقرير',
              arabicLabel: (key) => BillingReportLabels.field(
                key,
                english: english,
              ),
            ),
          BillingReportRecordsSection(
            controller: controller,
            arabicLabel: (key) => BillingReportLabels.field(
              key,
              english: english,
            ),
            displayValue: (key, value) => BillingReportLabels.displayValue(
              key,
              value,
              english: english,
            ),
            emptyTitle: english ? 'No matching records' : 'لا توجد سجلات مطابقة',
            emptySubtitle: english
                ? 'Change the search or filters, then reload the report.'
                : 'غيّر معايير البحث أو الفلاتر ثم أعد تحميل التقرير.',
            loadMoreLabel: english ? 'Load more report records' : 'تحميل المزيد من سجلات التقرير',
          ),
        ],
      );
    });
  }

}
