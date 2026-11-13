import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_column_visibility_section.dart';

class BillingReportPresentationSection extends StatelessWidget {
  const BillingReportPresentationSection({
    required this.controller,
    required this.definition,
    required this.presentation,
    required this.resolveLabel,
    required this.onChanged,
    super.key,
  });

  final BillingReportsController controller;
  final ReportDefinition definition;
  final ReportPresentationOptions presentation;
  final ReportLabelResolver resolveLabel;
  final ValueChanged<ReportPresentationOptions> onChanged;

  ReportTemplateSelection? _templateFor(String? id) {
    final selected = definition.templates.firstWhereOrNull(
      (item) => item.id.value == id,
    );
    if (selected == null) return presentation.template;
    return ReportTemplateSelection(
      id: selected.id,
      version: selected.version,
    );
  }

  ReportPresentationOptions _copy({
    String? languageTag,
    String? pageProfileId,
    ReportTemplateSelection? template,
    List<String>? visibleColumnIds,
    bool? includeMetrics,
  }) {
    return ReportPresentationOptions(
      visibleColumnIds: visibleColumnIds ?? presentation.visibleColumnIds,
      sorts: presentation.sorts,
      groupByFieldId: presentation.groupByFieldId,
      template: template ?? presentation.template,
      languageTag: languageTag ?? presentation.languageTag,
      pageProfileId: pageProfileId ?? presentation.pageProfileId,
      includeMetrics: includeMetrics ?? presentation.includeMetrics,
      includeCharts: presentation.includeCharts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (definition.supportedLocaleTags.length > 1)
          CustomDropdown<String>(
            items: definition.supportedLocaleTags
                .map(
                  (tag) => DropdownItem<String>(
                    value: tag,
                    child: Text(tag == 'ar-YE' ? 'العربية' : 'English'),
                  ),
                )
                .toList(growable: false),
            rxValue: controller.selectedLocale,
            onChanged: (value) {
              if (value != null) {
                onChanged(_copy(languageTag: value));
              }
            },
            label: 'لغة المستند',
            hint: 'اختر اللغة',
          ),
        if (definition.pageProfileIds.length > 1)
          CustomDropdown<String>(
            items: definition.pageProfileIds
                .map(
                  (id) => DropdownItem<String>(
                    value: id,
                    child: Text(id == 'a4-landscape' ? 'A4 أفقي' : 'A4 عمودي'),
                  ),
                )
                .toList(growable: false),
            rxValue: controller.selectedPageProfile,
            onChanged: (value) {
              if (value != null) {
                onChanged(_copy(pageProfileId: value));
              }
            },
            label: 'حجم الصفحة',
            hint: 'اختر حجم الصفحة',
          ),
        if (definition.templates.length > 1)
          CustomDropdown<String>(
            items: definition.templates
                .map(
                  (item) => DropdownItem<String>(
                    value: item.id.value,
                    child: Text(item.id.value),
                  ),
                )
                .toList(growable: false),
            rxValue: controller.selectedTemplateId,
            onChanged: (value) {
              if (value != null) {
                onChanged(_copy(template: _templateFor(value)));
              }
            },
            label: 'قالب المستند',
            hint: 'اختر القالب',
          ),
        if (definition.templates.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('القالب: ${definition.templates.first.id.value}'),
          ),
        Row(
          children: [
            const Expanded(child: Text('إظهار مؤشرات الملخص')),
            CustomSwitch(
              value: presentation.includeMetrics,
              onChanged: (value) =>
                  onChanged(_copy(includeMetrics: value)),
            ),
          ],
        ),
        if (definition.chartsAvailable)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'المخططات التفاعلية تظهر في شاشة التقرير؛ إدراج الرسوم داخل PDF سيُضاف ضمن مرحلة قوالب PDF المتقدمة.',
            ),
          ),
        const SizedBox(height: 8),
        BillingReportColumnVisibilitySection(
          columns: definition.columns,
          presentation: presentation,
          resolveLabel: resolveLabel,
          onChanged: (visibleColumnIds) => onChanged(
            _copy(visibleColumnIds: visibleColumnIds),
          ),
        ),
      ],
    );
  }
}
