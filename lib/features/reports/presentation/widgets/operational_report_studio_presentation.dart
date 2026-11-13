import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_column_visibility.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_document_options.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_presentation_toggles.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_sort_group_controls.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_studio_section.dart';

/// Composes output visibility, ordering, document, and display controls.
class OperationalReportStudioPresentation extends StatelessWidget {
  const OperationalReportStudioPresentation({
    required this.definition,
    required this.presentation,
    required this.resolveLabel,
    required this.onChanged,
    super.key,
  });

  final ReportDefinition definition;
  final ReportPresentationOptions presentation;
  final ReportLabelResolver resolveLabel;
  final ValueChanged<ReportPresentationOptions> onChanged;

  @override
  Widget build(BuildContext context) {
    final issues = presentation.validateAgainst(definition);
    return OperationalReportStudioSection(
      title: 'تصميم المخرجات',
      icon: Icons.tune_rounded,
      children: [
        OperationalReportColumnVisibility(
          definition: definition,
          presentation: presentation,
          resolveLabel: resolveLabel,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        OperationalReportSortGroupControls(
          definition: definition,
          presentation: presentation,
          resolveLabel: resolveLabel,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        OperationalReportDocumentOptions(
          definition: definition,
          presentation: presentation,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        OperationalReportPresentationToggles(
          definition: definition,
          presentation: presentation,
          onChanged: onChanged,
        ),
        if (issues.isNotEmpty) ...[
          const SizedBox(height: 12),
          OperationalReportValidationNotice(
            title: 'راجع تصميم المخرجات',
            messages: issues.map((issue) {
              return switch (issue.code) {
                'unknown_column' => 'العمود «${issue.fieldId}» غير موجود.',
                'required_column_hidden' =>
                  'يجب إبقاء العمود «${issue.fieldId}» ظاهراً.',
                'unknown_sort_column' || 'sorting_not_allowed' =>
                  'الترتيب حسب «${issue.fieldId}» غير مدعوم.',
                'unknown_group_column' || 'grouping_not_allowed' =>
                  'التجميع حسب «${issue.fieldId}» غير مدعوم.',
                'template_not_allowed' => 'قالب التقرير المحدد غير متاح.',
                'locale_not_allowed' => 'لغة المستند المحددة غير مدعومة.',
                'page_profile_not_allowed' => 'حجم الصفحة المحدد غير متاح.',
                'metrics_not_available' => 'هذا التقرير لا يوفّر مؤشرات.',
                'charts_not_available' => 'هذا التقرير لا يوفّر رسوماً بيانية.',
                _ => 'إعداد «${issue.fieldId}» غير صالح.',
              };
            }).toList(growable: false),
          ),
        ],
      ],
    );
  }
}
