import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/billing_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_filter_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_presentation_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_records_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_summary_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class BillingReportsContent extends StatelessWidget {
  const BillingReportsContent({
    super.key,
    required this.controller,
  });

  final BillingReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.catalog
          .map(
            (item) => DropdownItem<String>(
              value: item['id'].toString(),
              child: Text(item['label']?.toString() ?? item['id'].toString()),
            ),
          )
          .toList(growable: false);
      final summary = controller.summary.value;
      final definition = controller.currentDefinition;

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(context),
          const SizedBox(height: 16),
          if (items.isNotEmpty)
            CustomDropdown<String>(
              items: items,
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
              resolveLabel: _resolveLabel,
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
              onRetry: controller.applyFilters,
            ),
          if (summary != null && summary['record_count'] is num)
            CustomResultsCounterBar(
              count: controller.rows.length,
              totalCount: (summary['record_count'] as num).toInt(),
              recordLabel: 'سجل',
              isFiltered: controller.criteria.value.filters.isNotEmpty,
              isLoading: controller.isLoading.value,
              onClear: controller.criteria.value.filters.isEmpty
                  ? null
                  : () => controller.setCriteria(ReportCriteria()),
            ),
          if (summary != null)
            BillingReportSummarySection(
              summary: summary,
              charts: controller.charts,
              arabicLabel: _arabicLabel,
            ),
          BillingReportRecordsSection(
            controller: controller,
            arabicLabel: _arabicLabel,
            displayValue: _displayValue,
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
          onPressed:
              controller.isLoading.value ? null : controller.exportCsv,
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

  String _resolveLabel(BuildContext context, String key) {
    final english = controller.selectedLocale.value == 'en';
    if (key.startsWith('billing.status.')) {
      return _statusLabel(
        key.substring('billing.status.'.length),
        english: english,
      );
    }
    if (key.startsWith('billing.report.column.') ||
        key.startsWith('billing.report.metric.')) {
      final id = key.substring(key.lastIndexOf('.') + 1);
      return english ? _englishLabel(id) : _arabicLabel(id);
    }
    if (key == controller.selectedDefinition?['label'] && english) {
      return _englishReportLabel(controller.selectedType.value ?? '');
    }
    if (key == 'من تاريخ' && english) return 'From date';
    if (key == 'إلى تاريخ' && english) return 'To date';
    if (key == 'الحالة' && english) return 'Status';
    if (key == 'بحث' && english) return 'Search';
    return key;
  }

  String _statusLabel(String value, {bool english = false}) {
    return EnumPresentationRegistry.resolveBillingStatus(
      BillingStatus.fromWire(value),
      english: english,
    ).label;
  }

  String _englishReportLabel(String type) => const {
        'subscriptions': 'Subscriptions',
        'trials': 'Trial usage',
        'trial_conversion': 'Trial conversion funnel',
        'renewals': 'Renewals',
        'plan_performance': 'Plan performance',
        'invoices': 'Invoices',
        'collections': 'Collections',
        'receivables': 'Accounts receivable',
        'usage': 'Usage',
        'dunning': 'Dunning',
        'refunds': 'Refunds',
        'revenue_recognition': 'Revenue recognition',
      }[type] ??
      type;

  String _englishLabel(String key) => const {
        'record_count': 'Record count',
        'active_subscriptions': 'Active subscriptions',
        'trialing_subscriptions': 'Trial subscriptions',
        'past_due_subscriptions': 'Past-due subscriptions',
        'canceled_subscriptions': 'Canceled subscriptions',
        'currency_code': 'Currency code',
        'invoice_number': 'Invoice number',
        'status': 'Status',
        'amount_minor': 'Amount (minor units)',
        'mrr_minor': 'Monthly recurring revenue',
        'arr_minor': 'Annual recurring revenue',
        'trial_eligible': 'Eligible trials',
        'trial_reserved': 'Reserved trials',
        'trial_started': 'Started trials',
        'trial_completed': 'Completed trials',
        'conversion_invoice_issued': 'Conversion invoices issued',
        'paid_conversion': 'Paid conversions',
      }[key] ??
      key.replaceAll('_', ' ');

  String _arabicLabel(String key) => const {
        'record_count': 'عدد السجلات',
        'active_subscriptions': 'الاشتراكات النشطة',
        'trialing_subscriptions': 'الاشتراكات التجريبية',
        'past_due_subscriptions': 'اشتراكات متأخرة السداد',
        'canceled_subscriptions': 'الاشتراكات الملغاة',
        'currency_code': 'رمز العملة',
        'invoice_number': 'رقم الفاتورة',
        'status': 'الحالة',
        'amount_minor': 'المبلغ (وحدة صغرى)',
        'mrr_minor': 'الإيراد الشهري المتكرر',
        'arr_minor': 'الإيراد السنوي المتكرر',
        'trial_eligible': 'التجارب المؤهلة',
        'trial_reserved': 'التجارب المحجوزة',
        'trial_started': 'التجارب التي بدأت',
        'trial_completed': 'التجارب المكتملة',
        'conversion_invoice_issued': 'فواتير التحويل الصادرة',
        'paid_conversion': 'التحويلات المدفوعة',
      }[key] ??
      key.replaceAll('_', ' ');

  String _displayValue(String key, dynamic value) {
    if (value == null) return '—';
    final isAmount = key.endsWith('_minor') ||
        key == 'amount' ||
        key == 'mrr' ||
        key == 'arr' ||
        key.contains('revenue');
    if (isAmount &&
        (value is num || num.tryParse(value.toString()) != null)) {
      return AmountFormatter.format(value.toString());
    }
    return value.toString();
  }
}
