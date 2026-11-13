import 'dart:async';

import 'package:flutter/material.dart';
import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';\nimport 'package:netsales/features/reports/domain/entities/operational_report_catalog.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_records_list.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_charts_section.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_summary_strip.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_type_selector.dart';\nimport 'package:netsales/features/reports/presentation/widgets/operational_report_studio_filters.dart';\nimport 'package:netsales/features/reports/presentation/widgets/operational_report_studio_presentation.dart';\nimport 'package:netsales/features/reports/presentation/widgets/operational_report_preset_dialog.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_field.dart';

class OperationalReportsScreen extends GetView<OperationalReportsController> {
  const OperationalReportsScreen({
    required this.networkId,
    required this.isNetworkWorkspace,
    this.posId,
    this.organizationName,
    this.logoUrl,
    super.key,
  });

  final int? networkId;
  final int? posId;
  final String? organizationName;
  final String? logoUrl;
  final bool isNetworkWorkspace;


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        controller.configureScope(
          networkId: networkId,
          posId: posId,
          isNetworkWorkspace: isNetworkWorkspace,
          organizationName: organizationName,
          logoUrl: logoUrl,
        ),
      );
    });

    return CustomAppScaffold(
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقارير التشغيلية',
              style: AppTypography.titleLarge.copyWith(
                color: context.colors.onSurface,
                fontWeight: AppTypography.bold,
              ),
            ),
            AppSpacing.vXs,
            Text(
              'بيانات موثقة من الخادم، مع تصفية وتصدير حسب صلاحيات مساحة العمل.',
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            AppSpacing.vMd,
            Expanded(
              child: Obx(() {
                final types = controller.availableTypes;
                if (types.isEmpty) {
                  return const CustomEmptyState.boxed(
                    title: 'لا توجد تقارير متاحة',
                    subtitle:
                        'لا توجد لديك صلاحية لعرض أي من التقارير التشغيلية في مساحة العمل الحالية.',
                    icon: Icons.lock_outline_rounded,
                  );
                }

                if (!controller.hasNetworkScope) {
                  return const CustomEmptyState.boxed(
                    title: 'حدد مساحة العمل أولاً',
                    subtitle:
                        'اختر شبكة أو نقطة بيع مصرحاً بها حتى يمكن تحميل تقاريرها.',
                    icon: Icons.business_outlined,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OperationalReportTypeSelector(
                      controller: controller,
                      types: types,
                    ),
                    AppSpacing.vMd,
                    if (controller.selectedReportEntry case final entry?)
                      Expanded(
                        flex: 3,
                        child: Obx(() => ReportConfigurationStudio(
                        definition: entry.definition,
                        criteria: controller.criteria.value,
                        presentation: controller.presentation.value,
                        resolveLabel: (context, key) =>\n                            _resolveReportLabel(context, entry, key),,
                        onCriteriaChanged: controller.updateCriteria,
                        onPresentationChanged: controller.updatePresentation,
                        filterSectionBuilder: (
                          context, {
                          required definition,
                          required criteria,
                          required resolveLabel,
                          required onChanged,
                        }) => OperationalReportStudioFilters(
                          definition: definition,
                          criteria: criteria,
                          resolveLabel: resolveLabel,
                          textControllerFor: (id) => controller.textControllerFor(
                            definition.filter(id)!,
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
                        }) => OperationalReportStudioPresentation(
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
                        actionBuilder: (context, {required label, required icon, required onPressed, required secondary}) =>
                            secondary
                                ? CustomButton.outline(text: label, prefix: icon, onPressed: onPressed)
                                : CustomButton.primary(text: label, prefix: icon, onPressed: onPressed),
                        isBusy: controller.isLoading.value || controller.isPdfActionRunning.value,
                      )),
                      ),
                    Obx(() {
                      if (controller.savedPresets.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.savedPresets.map((preset) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomButton.outline(text: preset.name, onPressed: () => controller.applyPreset(preset)),
                              CustomButton.icon(icon: Icons.delete_outline, tooltip: 'حذف الإعداد', onPressed: controller.isDeletingPreset.value ? null : () => controller.deletePreset(preset)),
                            ],
                          )).toList(growable: false),
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          CustomButton.outline(
                            text: 'مسح عوامل التصفية',
                            prefix: Icons.filter_alt_off_outlined,
                            onPressed: controller.clearFilters,
                          ),
                          Obx(() => CustomButton.primary(
                            text: 'تصدير CSV',
                            prefix: Icons.table_view_outlined,
                            onPressed: controller.canExport &&
                                    !controller.isExportActionRunning.value
                                ? controller.requestExport
                                : null,
                            loading: controller.isExportActionRunning.value,
                          )),
                          Obx(() => CustomButton.outline(
                            text: 'تصدير PDF تفصيلي',
                            prefix: Icons.picture_as_pdf_outlined,
                            onPressed: controller.canExport &&
                                    controller.summary.value != null &&
                                    !controller.isPdfActionRunning.value
                                ? controller.exportDetailedPdf
                                : null,
                            loading: controller.isPdfActionRunning.value,
                          )),
                          Obx(() => CustomButton.outline(
                            text: 'حفظ ملخص PDF',
                            prefix: Icons.picture_as_pdf_outlined,
                            onPressed: controller.canExport &&
                                    controller.summary.value != null &&
                                    !controller.isPdfActionRunning.value
                                ? controller.exportSummaryPdf
                                : null,
                            loading: controller.isPdfActionRunning.value,
                          )),
                          Obx(() => CustomButton.outline(
                            text: 'مشاركة PDF',
                            prefix: Icons.share_outlined,
                            onPressed: controller.canExport &&
                                    controller.summary.value != null &&
                                    !controller.isPdfActionRunning.value
                                ? controller.shareSummaryPdf
                                : null,
                          )),
                          Obx(() => CustomButton.outline(
                            text: 'طباعة PDF',
                            prefix: Icons.print_outlined,
                            onPressed: controller.canExport &&
                                    controller.summary.value != null &&
                                    !controller.isPdfActionRunning.value
                                ? controller.printSummaryPdf
                                : null,
                          )),
                        ],
                      ),
                    ),
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
                        child: OperationalReportSummaryStrip(
                          summary: summary,
                        ),
                      );
                    }),
                    Obx(() {
                      final summary = controller.summary.value;
                      if (summary == null || !controller.presentation.value.includeCharts) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: OperationalReportChartsSection(summary: summary),
                      );
                    }),
                    AppSpacing.vSm,
                    Expanded(
                      flex: 2,
                      child: OperationalReportRecordsList(
                        controller: controller,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }


  String _resolveReportLabel(
    BuildContext context,
    OperationalReportCatalogEntry entry,
    String key,
  ) {
    if (key == entry.definition.titleKey) return entry.label;
    if (key == entry.definition.descriptionKey) return entry.description;
    final localized = switch (key) {
      'report_configuration.authorization_notice' => 'تُحدد الصلاحيات ونطاق الوصول من الخادم',
      'report_configuration.schema_version' => 'إصدار تعريف التقرير',
      'report_configuration.client_execution' => 'تنفيذ محلي',
      'report_configuration.server_execution' => 'تنفيذ على الخادم',
      'report_configuration.either_execution' => 'تنفيذ مرن',
      'report_configuration.client_limit' => 'الحد الأقصى للسجلات المحلية',
      'report_configuration.data_criteria' => 'معايير البيانات',
      'report_configuration.data_criteria_hint' => 'حدد القيم التي سيستخدمها الخادم لاستخراج النتائج',
      'report_configuration.no_filters' => 'لا توجد مرشحات لهذا التقرير',
      'common.required' => 'مطلوب',
      'report_configuration.from_date' => 'من تاريخ',
      'report_configuration.to_date' => 'إلى تاريخ',
      'report_configuration.output_design' => 'تصميم المخرجات',
      'report_configuration.output_design_hint' => 'خصص الأعمدة وترتيب العرض والقالب',
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

}
