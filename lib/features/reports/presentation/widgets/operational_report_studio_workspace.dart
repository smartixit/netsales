import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter/material.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_catalog.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_preset_dialog.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_studio_filters.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_studio_presentation.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// Adapter between the reusable report studio and the NetSales GetX controller.
class OperationalReportStudioWorkspace extends StatelessWidget {
  const OperationalReportStudioWorkspace({
    required this.controller,
    required this.entry,
    super.key,
  });

  final OperationalReportsController controller;
  final OperationalReportCatalogEntry entry;

  String _resolveLabel(BuildContext context, String key) {
    if (key == entry.definition.titleKey) return entry.label;
    if (key == entry.definition.descriptionKey) return entry.description;

    final localized = switch (key) {
      'report_configuration.authorization_notice' =>
        'تُحدد الصلاحيات ونطاق الوصول من الخادم',
      'report_configuration.schema_version' => 'إصدار تعريف التقرير',
      'report_configuration.client_execution' => 'تنفيذ محلي',
      'report_configuration.server_execution' => 'تنفيذ على الخادم',
      'report_configuration.either_execution' => 'تنفيذ مرن',
      'report_configuration.client_limit' => 'الحد الأقصى للسجلات المحلية',
      'report_configuration.data_criteria' => 'معايير البيانات',
      'report_configuration.data_criteria_hint' =>
        'حدد القيم التي سيستخدمها الخادم لاستخراج النتائج',
      'report_configuration.no_filters' => 'لا توجد مرشحات لهذا التقرير',
      'common.required' => 'مطلوب',
      'report_configuration.from_date' => 'من تاريخ',
      'report_configuration.to_date' => 'إلى تاريخ',
      'report_configuration.output_design' => 'تصميم المخرجات',
      'report_configuration.output_design_hint' =>
        'خصص الأعمدة وترتيب العرض والقالب',
      'report_configuration.output_columns' => 'الأعمدة الظاهرة',
      'report_configuration.include_metrics' => 'إظهار المؤشرات',
      'report_configuration.include_charts' => 'إظهار الرسوم البيانية',
      'report_configuration.sort_by' => 'ترتيب حسب',
      'report_configuration.sort_direction' => 'اتجاه الترتيب',
      'report_configuration.ascending' => 'تصاعدي',
      'report_configuration.descending' => 'تنازلي',
      'report_configuration.group_by' => 'تجميع حسب',
      'report_configuration.no_grouping' => 'بدون تجميع',
      'report_configuration.template' => 'قالب التقرير',
      'report_configuration.language' => 'لغة المستند',
      'report_configuration.page_profile' => 'حجم الصفحة',
      'report_configuration.save_preset' => 'حفظ الإعدادات',
      'report_configuration.preview' => 'معاينة',
      _ => null,
    };
    if (localized != null) return localized;

    final choiceKey = key.split('.').last;
    return entry.filterLabels[key] ??
        entry.columnLabels[key] ??
        entry.metricLabels[key] ??
        entry.choiceLabels.entries
            .where((item) => item.value.containsKey(choiceKey))
            .map((item) => item.value[choiceKey]!)
            .firstOrNull ??
        key;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ReportConfigurationStudio(
        definition: entry.definition,
        criteria: controller.criteria.value,
        presentation: controller.presentation.value,
        resolveLabel: _resolveLabel,
        onCriteriaChanged: controller.updateCriteria,
        onPresentationChanged: controller.updatePresentation,
        filterSectionBuilder: (
          context, {
          required definition,
          required criteria,
          required resolveLabel,
          required onChanged,
        }) =>
            OperationalReportStudioFilters(
              definition: definition,
              criteria: criteria,
              resolveLabel: resolveLabel,
              textControllerFor: (filterId) => controller.textControllerFor(
                definition.filter(filterId)!,
              ),
              choiceValueFor: controller.choiceValueFor,
              onFilterChanged: controller.setFilterValue,
            ),
        presentationSectionBuilder: (
          context, {
          required definition,
          required presentation,
          required resolveLabel,
          required onChanged,
        }) =>
            OperationalReportStudioPresentation(
              definition: definition,
              presentation: presentation,
              resolveLabel: resolveLabel,
              onChanged: controller.updatePresentation,
            ),
        onSavePreset: () => OperationalReportPresetDialog.show(
          onSave: controller.savePreset,
        ),
        onPreview: controller.summary.value == null
            ? null
            : controller.exportDetailedPdf,
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
        isBusy: controller.isLoading.value ||
            controller.isPdfActionRunning.value,
      ),
    );
  }
}
