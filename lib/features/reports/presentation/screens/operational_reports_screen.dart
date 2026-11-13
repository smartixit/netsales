import 'dart:async';

import 'package:flutter/material.dart';
import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_records_list.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_summary_strip.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_type_selector.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
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
                      Obx(() => ReportConfigurationStudio(
                        definition: entry.definition,
                        criteria: controller.criteria.value,
                        presentation: controller.presentation.value,
                        resolveLabel: (context, key) {
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
                          return entry.filterLabels[key] ??
                              entry.columnLabels[key] ??
                              entry.metricLabels[key] ??
                              entry.choiceLabels.entries
                                  .where((item) => item.value.containsKey(key.split('.').last))
                                  .map((item) => item.value[key.split('.').last]!)
                                  .firstOrNull ??
                              key;
                        },
                        onCriteriaChanged: controller.updateCriteria,
                        onPresentationChanged: controller.updatePresentation,
                        filterSectionBuilder: (context, {required definition, required criteria, required resolveLabel, required onChanged}) =>
                            _buildStudioFilters(context, definition, criteria, resolveLabel),
                        presentationSectionBuilder: (context, {required definition, required presentation, required resolveLabel, required onChanged}) =>
                            _buildStudioPresentation(context, definition, presentation, resolveLabel),
                        onPreview: controller.summary.value == null
                            ? null
                            : controller.exportSummaryPdf,
                        actionBuilder: (context, {required label, required icon, required onPressed, required secondary}) =>
                            secondary
                                ? CustomButton.outline(text: label, prefix: icon, onPressed: onPressed)
                                : CustomButton.primary(text: label, prefix: icon, onPressed: onPressed),
                        isBusy: controller.isLoading.value || controller.isPdfActionRunning.value,
                      )),
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

                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: OperationalReportSummaryStrip(
                          summary: summary,
                        ),
                      );
                    }),
                    AppSpacing.vSm,
                    Expanded(
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

  Widget _buildStudioFilters(
    BuildContext context,
    ReportDefinition definition,
    ReportCriteria criteria,
    ReportLabelResolver resolveLabel,
  ) {
    final filters = <Widget>[];
    for (final filter in definition.filters) {
      final label = resolveLabel(context, filter.labelKey);
      final value = criteria.filters[filter.id];
      final required = filter.required;
      switch (filter.kind) {
        case ReportFilterKind.text:
        case ReportFilterKind.integer:
        case ReportFilterKind.decimal:
          filters.add(CustomTextField(
            controller: controller.textControllerFor(filter),
            label: label,
            isRequired: required,
            keyboardType: filter.kind == ReportFilterKind.text
                ? TextInputType.text
                : filter.kind == ReportFilterKind.integer
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(decimal: true),
            onChanged: (text) {
              ReportFilterValue? next;
              final normalized = text.trim();
              if (normalized.isNotEmpty) {
                if (filter.kind == ReportFilterKind.text) {
                  next = ReportTextFilterValue(normalized);
                } else if (filter.kind == ReportFilterKind.integer) {
                  final parsed = int.tryParse(normalized);
                  if (parsed != null) next = ReportIntegerFilterValue(parsed);
                } else {
                  try { next = ReportDecimalFilterValue(normalized); } on ArgumentError { next = null; }
                }
              }
              controller.setFilterValue(filter.id, next);
            },
          ));
        case ReportFilterKind.date:
          final selected = value is ReportDateFilterValue ? value.value : null;
          filters.add(CustomDatePickerField.single(
            label: label,
            value: selected,
            isRequired: required,
            onChanged: (date) => controller.setFilterValue(
              filter.id,
              date == null ? null : ReportDateFilterValue(date),
            ),
          ));
        case ReportFilterKind.dateRange:
          final range = value is ReportDateRangeFilterValue ? value : null;
          filters.add(CustomDatePickerField.range(
            label: label,
            value: range?.start != null && range?.end != null
                ? DateTimeRange(start: range!.start!, end: range.end!)
                : null,
            isRequired: required,
            onChanged: (selected) => controller.setFilterValue(
              filter.id,
              selected == null
                  ? null
                  : ReportDateRangeFilterValue(start: selected.start, end: selected.end),
            ),
          ));
        case ReportFilterKind.boolean:
          final enabled = value is ReportBooleanFilterValue && value.value;
          filters.add(Row(children: [
            Expanded(child: Text(label)),
            CustomButton.outline(
              text: enabled ? 'مفعّل' : 'غير مفعّل',
              prefix: enabled ? Icons.check_circle_outline : Icons.circle_outlined,
              onPressed: () => controller.setFilterValue(
                filter.id,
                ReportBooleanFilterValue(!enabled),
              ),
            ),
          ]));
        case ReportFilterKind.singleChoice:
          final rx = controller.choiceValueFor(filter.id);
          filters.add(CustomDropdown<String>(
            label: label,
            hint: 'اختر $label',
            isRequired: required,
            rxValue: rx,
            items: [
              DropdownItem<String>(value: '', child: const Text('الكل')),
              ...filter.choices.map((choice) => DropdownItem<String>(
                value: choice.value,
                child: Text(resolveLabel(context, choice.labelKey)),
              )),
            ],
            onChanged: (selected) => controller.setFilterValue(
              filter.id,
              selected == null || selected.isEmpty
                  ? null
                  : ReportChoiceFilterValue(selected),
            ),
          ));
        case ReportFilterKind.multiChoice:
          final selected = value is ReportChoicesFilterValue ? value.values.toSet() : <String>{};
          filters.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: filter.choices.map((choice) {
                final active = selected.contains(choice.value);
                return active
                    ? CustomButton.secondary(
                        text: resolveLabel(context, choice.labelKey),
                        onPressed: () {
                          final next = {...selected}..remove(choice.value);
                          controller.setFilterValue(filter.id, next.isEmpty ? null : ReportChoicesFilterValue(next.toList()));
                        },
                      )
                    : CustomButton.outline(
                        text: resolveLabel(context, choice.labelKey),
                        onPressed: () {
                          final next = {...selected, choice.value};
                          controller.setFilterValue(filter.id, ReportChoicesFilterValue(next.toList()..sort()));
                        },
                      );
              }).toList()),
            ],
          ));
      }
    }
    return _studioSection(
      context,
      title: 'معايير البيانات',
      icon: Icons.filter_alt_outlined,
      children: filters,
    );
  }

  Widget _buildStudioPresentation(
    BuildContext context,
    ReportDefinition definition,
    ReportPresentationOptions presentation,
    ReportLabelResolver resolveLabel,
  ) {
    final visible = presentation.visibleColumnIds.isEmpty
        ? definition.columns.where((column) => column.visibleByDefault).map((column) => column.id).toSet()
        : presentation.visibleColumnIds.toSet();
    final children = <Widget>[];
    children.add(Text('الأعمدة الظاهرة', style: Theme.of(context).textTheme.titleSmall));
    for (final column in definition.columns) {
      final shown = visible.contains(column.id);
      children.add(Row(children: [
        Expanded(child: Text(resolveLabel(context, column.labelKey))),
        CustomButton.icon(
          icon: shown ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          tooltip: shown ? 'إخفاء العمود' : 'إظهار العمود',
          onPressed: !column.hideable ? null : () {
            final next = {...visible};
            if (shown) {
              if (next.length > 1) next.remove(column.id);
            } else {
              next.add(column.id);
            }
            controller.updatePresentation(ReportPresentationOptions(
              visibleColumnIds: next.toList(),
              sorts: presentation.sorts,
              groupByFieldId: presentation.groupByFieldId,
              template: presentation.template,
              languageTag: presentation.languageTag,
              pageProfileId: presentation.pageProfileId,
              includeMetrics: presentation.includeMetrics,
              includeCharts: presentation.includeCharts,
            ));
          },
        ),
      ]));
    }
    final sortable = definition.columns.where((column) => column.sortable).toList();
    if (sortable.isNotEmpty) {
      children.add(CustomDropdown<String>(
        label: 'ترتيب حسب',
        hint: 'بدون ترتيب',
        items: [
          DropdownItem<String>(value: '', child: const Text('بدون ترتيب')),
          ...sortable.map((column) => DropdownItem<String>(
            value: column.id,
            child: Text(resolveLabel(context, column.labelKey)),
          )),
        ],
        rxValue: RxnString(presentation.sorts.isEmpty ? '' : presentation.sorts.first.fieldId),
        onChanged: (id) => controller.updatePresentation(ReportPresentationOptions(
          visibleColumnIds: presentation.visibleColumnIds,
          sorts: id == null || id.isEmpty ? const [] : [ReportSortOption(
            fieldId: id,
            direction: presentation.sorts.isEmpty ? ReportSortDirection.ascending : presentation.sorts.first.direction,
          )],
          groupByFieldId: presentation.groupByFieldId,
          template: presentation.template,
          languageTag: presentation.languageTag,
          pageProfileId: presentation.pageProfileId,
          includeMetrics: presentation.includeMetrics,
          includeCharts: presentation.includeCharts,
        )),
      ));
    }
    final groupable = definition.columns.where((column) => column.groupable).toList();
    if (groupable.isNotEmpty) {
      children.add(CustomDropdown<String>(
        label: 'تجميع حسب',
        rxValue: RxnString(presentation.groupByFieldId ?? ''),
        items: [
          DropdownItem<String>(value: '', child: const Text('بدون تجميع')),
          ...groupable.map((column) => DropdownItem<String>(
            value: column.id,
            child: Text(resolveLabel(context, column.labelKey)),
          )),
        ],
        onChanged: (id) => controller.updatePresentation(ReportPresentationOptions(
          visibleColumnIds: presentation.visibleColumnIds,
          sorts: presentation.sorts,
          groupByFieldId: id == null || id.isEmpty ? null : id,
          template: presentation.template,
          languageTag: presentation.languageTag,
          pageProfileId: presentation.pageProfileId,
          includeMetrics: presentation.includeMetrics,
          includeCharts: presentation.includeCharts,
        )),
      ));
    }
    if (presentation.sorts.isNotEmpty) {
      children.add(CustomDropdown<ReportSortDirection>(
        label: 'اتجاه الترتيب',
        rxValue: Rxn<ReportSortDirection>(presentation.sorts.first.direction),
        items: const [
          DropdownItem<ReportSortDirection>(
            value: ReportSortDirection.ascending,
            child: Text('تصاعدي'),
          ),
          DropdownItem<ReportSortDirection>(
            value: ReportSortDirection.descending,
            child: Text('تنازلي'),
          ),
        ],
        onChanged: (direction) {
          if (direction == null) return;
          final current = presentation.sorts.first;
          controller.updatePresentation(ReportPresentationOptions(
            visibleColumnIds: presentation.visibleColumnIds,
            sorts: [ReportSortOption(fieldId: current.fieldId, direction: direction)],
            groupByFieldId: presentation.groupByFieldId,
            template: presentation.template,
            languageTag: presentation.languageTag,
            pageProfileId: presentation.pageProfileId,
            includeMetrics: presentation.includeMetrics,
            includeCharts: presentation.includeCharts,
          ));
        },
      ));
    }
    if (definition.supportedLocaleTags.isNotEmpty) {
      children.add(CustomDropdown<String>(
        label: 'لغة المستند',
        rxValue: RxnString(presentation.languageTag ?? definition.supportedLocaleTags.first),
        items: definition.supportedLocaleTags.map((tag) => DropdownItem<String>(value: tag, child: Text(tag))).toList(),
        onChanged: (tag) => controller.updatePresentation(ReportPresentationOptions(
          visibleColumnIds: presentation.visibleColumnIds,
          sorts: presentation.sorts,
          groupByFieldId: presentation.groupByFieldId,
          template: presentation.template,
          languageTag: tag,
          pageProfileId: presentation.pageProfileId,
          includeMetrics: presentation.includeMetrics,
          includeCharts: presentation.includeCharts,
        )),
      ));
    }
    if (definition.pageProfileIds.isNotEmpty) {
      children.add(CustomDropdown<String>(
        label: 'حجم الصفحة',
        rxValue: RxnString(presentation.pageProfileId ?? definition.pageProfileIds.first),
        items: definition.pageProfileIds.map((id) => DropdownItem<String>(value: id, child: Text(id))).toList(),
        onChanged: (id) => controller.updatePresentation(ReportPresentationOptions(
          visibleColumnIds: presentation.visibleColumnIds,
          sorts: presentation.sorts,
          groupByFieldId: presentation.groupByFieldId,
          template: presentation.template,
          languageTag: presentation.languageTag,
          pageProfileId: id,
          includeMetrics: presentation.includeMetrics,
          includeCharts: presentation.includeCharts,
        )),
      ));
    }
    if (definition.templates.isNotEmpty) {
      children.add(CustomDropdown<String>(
        label: 'قالب التقرير',
        rxValue: RxnString(presentation.template?.reference.key ?? ''),
        items: [
          DropdownItem<String>(value: '', child: const Text('القالب الافتراضي')),
          ...definition.templates.map((item) => DropdownItem<String>(value: item.key, child: Text(item.key))),
        ],
        onChanged: (key) {
          final template = definition.templates.where((item) => item.key == key).firstOrNull;
          controller.updatePresentation(ReportPresentationOptions(
            visibleColumnIds: presentation.visibleColumnIds,
            sorts: presentation.sorts,
            groupByFieldId: presentation.groupByFieldId,
            template: template == null ? null : ReportTemplateSelection(id: template.id, version: template.version),
            languageTag: presentation.languageTag,
            pageProfileId: presentation.pageProfileId,
            includeMetrics: presentation.includeMetrics,
            includeCharts: presentation.includeCharts,
          ));
        },
      ));
    }
    children.add(Row(children: [
      Expanded(child: const Text('إظهار المؤشرات')),
      CustomButton.outline(
        text: presentation.includeMetrics ? 'نعم' : 'لا',
        onPressed: () => controller.updatePresentation(ReportPresentationOptions(
          visibleColumnIds: presentation.visibleColumnIds,
          sorts: presentation.sorts,
          groupByFieldId: presentation.groupByFieldId,
          template: presentation.template,
          languageTag: presentation.languageTag,
          pageProfileId: presentation.pageProfileId,
          includeMetrics: !presentation.includeMetrics,
          includeCharts: presentation.includeCharts,
        )),
      ),
    ]));
    children.add(Row(children: [
      Expanded(child: const Text('إظهار الرسوم البيانية')),
      CustomButton.outline(
        text: presentation.includeCharts ? 'نعم' : 'لا',
        onPressed: definition.chartsAvailable ? () => controller.updatePresentation(ReportPresentationOptions(
          visibleColumnIds: presentation.visibleColumnIds,
          sorts: presentation.sorts,
          groupByFieldId: presentation.groupByFieldId,
          template: presentation.template,
          languageTag: presentation.languageTag,
          pageProfileId: presentation.pageProfileId,
          includeMetrics: presentation.includeMetrics,
          includeCharts: !presentation.includeCharts,
        )) : null,
      ),
    ]));
    return _studioSection(
      context,
      title: 'تصميم المخرجات',
      icon: Icons.tune_rounded,
      children: children,
    );
  }

  Widget _studioSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.colors.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [Icon(icon), const SizedBox(width: 8), Text(title, style: AppTypography.titleMedium)]),
        AppSpacing.vSm,
        ...children.map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: child,
        )),
      ],
    ),
  );


}
