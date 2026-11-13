import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_filter_field.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_studio_section.dart';

/// Composes schema-defined filter fields and validation for the report studio.
class OperationalReportStudioFilters extends StatelessWidget {
  const OperationalReportStudioFilters({
    required this.definition,
    required this.criteria,
    required this.resolveLabel,
    required this.textControllerFor,
    required this.choiceValueFor,
    required this.onFilterChanged,
    super.key,
  });

  final ReportDefinition definition;
  final ReportCriteria criteria;
  final ReportLabelResolver resolveLabel;
  final TextEditingController Function(String filterId) textControllerFor;
  final RxnString Function(String filterId) choiceValueFor;
  final void Function(String filterId, ReportFilterValue? value)
      onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      for (final filter in definition.filters)
        OperationalReportFilterField(
          definition: filter,
          value: criteria.filters[filter.id],
          resolveLabel: resolveLabel,
          textController: textControllerFor(filter.id),
          choiceValue: choiceValueFor(filter.id),
          onChanged: (value) => onFilterChanged(filter.id, value),
        ),
    ];

    final issues = criteria.validateAgainst(definition);
    if (issues.isNotEmpty) {
      controls.add(
        OperationalReportValidationNotice(
          title: 'راجع معايير التقرير',
          messages: issues.map((issue) {
            final field = definition.filter(issue.fieldId);
            final label = field == null
                ? issue.fieldId
                : resolveLabel(context, field.labelKey);
            return switch (issue.code) {
              'required_filter_missing' => 'الحقل «$label» مطلوب.',
              'unknown_filter' =>
                'المرشح «$label» غير موجود في تعريف التقرير الحالي.',
              'filter_type_mismatch' =>
                'نوع القيمة المحددة للحقل «$label» غير متوافق.',
              'text_too_short' =>
                'النص في الحقل «$label» أقصر من الحد المسموح.',
              'text_too_long' =>
                'النص في الحقل «$label» يتجاوز الحد المسموح.',
              'choice_not_allowed' =>
                'القيمة المختارة للحقل «$label» غير متاحة.',
              _ => 'تعذر التحقق من الحقل «$label».',
            };
          }).toList(growable: false),
        ),
      );
    }

    return OperationalReportStudioSection(
      title: 'معايير البيانات',
      icon: Icons.filter_alt_outlined,
      children: controls,
    );
  }
}
