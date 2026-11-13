import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_column_visibility_section.dart';

class BillingReportPresentationSection extends StatelessWidget {
  const BillingReportPresentationSection({
    required this.controller,
    required this.definition,
    required this.presentation,
    required this.resolveLabel,
    required this.onChanged,
    this.english = false,
    super.key,
  });

  final BillingReportsController controller;
  final ReportDefinition definition;
  final ReportPresentationOptions presentation;
  final ReportLabelResolver resolveLabel;
  final ValueChanged<ReportPresentationOptions> onChanged;
  final bool english;

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
            label: english ? 'Document language' : 'لغة المستند',
            hint: english ? 'Select language' : 'اختر اللغة',
          ),
        if (definition.pageProfileIds.length > 1)
          CustomDropdown<String>(
            items: definition.pageProfileIds
                .map(
                  (id) => DropdownItem<String>(
                    value: id,
                    child: Text(english ? (id == 'a4-landscape' ? 'A4 landscape' : 'A4 portrait') : (id == 'a4-landscape' ? 'A4 أفقي' : 'A4 عمودي')),
                  ),
                )
                .toList(growable: false),
            rxValue: controller.selectedPageProfile,
            onChanged: (value) {
              if (value != null) {
                onChanged(_copy(pageProfileId: value));
              }
            },
            label: english ? 'Page size' : 'حجم الصفحة',
            hint: english ? 'Select page size' : 'اختر حجم الصفحة',
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
            label: english ? 'Document template' : 'قالب المستند',
            hint: english ? 'Select template' : 'اختر القالب',
          ),
        if (definition.templates.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('${english ? 'Template: ' : 'القالب: '}${definition.templates.first.id.value}'),
          ),
        Row(
          children: [
            Expanded(child: Text(english ? 'Include summary metrics' : 'إظهار مؤشرات الملخص')),
            CustomSwitch(
              value: presentation.includeMetrics,
              onChanged: (value) =>
                  onChanged(_copy(includeMetrics: value)),
            ),
          ],
        ),
        if (definition.chartsAvailable)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              english
                  ? 'Interactive charts are available in the report view. PDF chart layouts remain part of the advanced document-template stage.'
                  : 'المخططات التفاعلية تظهر في شاشة التقرير؛ إدراج الرسوم داخل PDF سيُضاف ضمن مرحلة قوالب PDF المتقدمة.',
            ),
          ),
        const SizedBox(height: 8),
        BillingReportColumnVisibilitySection(
          columns: definition.columns,
          presentation: presentation,
          resolveLabel: resolveLabel,
          title: english ? 'Visible PDF columns' : 'الأعمدة الظاهرة في PDF',
          onChanged: (visibleColumnIds) => onChanged(
            _copy(visibleColumnIds: visibleColumnIds),
          ),
        ),
      ],
    );
  }
}
