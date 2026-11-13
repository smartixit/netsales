import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_studio_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';

/// Builds output presentation controls from the server-owned report definition.
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

  ReportPresentationOptions _copy({
    List<String>? visibleColumnIds,
    List<ReportSortOption>? sorts,
    String? groupByFieldId,
    bool clearGroupByFieldId = false,
    ReportTemplateSelection? template,
    bool clearTemplate = false,
    String? languageTag,
    String? pageProfileId,
    bool? includeMetrics,
    bool? includeCharts,
  }) {
    return ReportPresentationOptions(
      visibleColumnIds: visibleColumnIds ?? presentation.visibleColumnIds,
      sorts: sorts ?? presentation.sorts,
      groupByFieldId: clearGroupByFieldId
          ? null
          : groupByFieldId ?? presentation.groupByFieldId,
      template: clearTemplate ? null : template ?? presentation.template,
      languageTag: languageTag ?? presentation.languageTag,
      pageProfileId: pageProfileId ?? presentation.pageProfileId,
      includeMetrics: includeMetrics ?? presentation.includeMetrics,
      includeCharts: includeCharts ?? presentation.includeCharts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = presentation.visibleColumnIds.isEmpty
        ? definition.columns
            .where((column) => column.visibleByDefault)
            .map((column) => column.id)
            .toSet()
        : presentation.visibleColumnIds.toSet();

    final children = <Widget>[
      Text(
        'الأعمدة الظاهرة',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    ];

    for (final column in definition.columns) {
      final shown = visible.contains(column.id);
      children.add(
        Row(
          children: [
            Expanded(child: Text(resolveLabel(context, column.labelKey))),
            CustomButton.icon(
              icon: shown
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              tooltip: shown ? 'إخفاء العمود' : 'إظهار العمود',
              onPressed: !column.hideable
                  ? null
                  : () {
                      final next = {...visible};
                      if (shown) {
                        if (next.length > 1) next.remove(column.id);
                      } else {
                        next.add(column.id);
                      }
                      onChanged(_copy(visibleColumnIds: next.toList()));
                    },
            ),
          ],
        ),
      );
    }

    final sortable =
        definition.columns.where((column) => column.sortable).toList();
    if (sortable.isNotEmpty) {
      children.add(
        CustomDropdown<String>(
          label: 'ترتيب حسب',
          hint: 'بدون ترتيب',
          items: [
            const DropdownItem<String>(
              value: '',
              child: Text('بدون ترتيب'),
            ),
            ...sortable.map(
              (column) => DropdownItem<String>(
                value: column.id,
                child: Text(resolveLabel(context, column.labelKey)),
              ),
            ),
          ],
          rxValue: RxnString(
            presentation.sorts.isEmpty
                ? ''
                : presentation.sorts.first.fieldId,
          ),
          onChanged: (id) => onChanged(
            _copy(
              sorts: id == null || id.isEmpty
                  ? const []
                  : [
                      ReportSortOption(
                        fieldId: id,
                        direction: presentation.sorts.isEmpty
                            ? ReportSortDirection.ascending
                            : presentation.sorts.first.direction,
                      ),
                    ],
            ),
          ),
        ),
      );
    }

    final groupable =
        definition.columns.where((column) => column.groupable).toList();
    if (groupable.isNotEmpty) {
      children.add(
        CustomDropdown<String>(
          label: 'تجميع حسب',
          rxValue: RxnString(presentation.groupByFieldId ?? ''),
          items: [
            const DropdownItem<String>(
              value: '',
              child: Text('بدون تجميع'),
            ),
            ...groupable.map(
              (column) => DropdownItem<String>(
                value: column.id,
                child: Text(resolveLabel(context, column.labelKey)),
              ),
            ),
          ],
          onChanged: (id) => onChanged(
            _copy(
              groupByFieldId: id,
              clearGroupByFieldId: id == null || id.isEmpty,
            ),
          ),
        ),
      );
    }

    if (presentation.sorts.isNotEmpty) {
      children.add(
        CustomDropdown<ReportSortDirection>(
          label: 'اتجاه الترتيب',
          rxValue: Rxn<ReportSortDirection>(
            presentation.sorts.first.direction,
          ),
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
            onChanged(
              _copy(
                sorts: [
                  ReportSortOption(
                    fieldId: current.fieldId,
                    direction: direction,
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (definition.supportedLocaleTags.isNotEmpty) {
      children.add(
        CustomDropdown<String>(
          label: 'لغة المستند',
          rxValue: RxnString(
            presentation.languageTag ??
                definition.supportedLocaleTags.first,
          ),
          items: definition.supportedLocaleTags
              .map(
                (tag) => DropdownItem<String>(
                  value: tag,
                  child: Text(tag),
                ),
              )
              .toList(growable: false),
          onChanged: (tag) {
            if (tag != null) onChanged(_copy(languageTag: tag));
          },
        ),
      );
    }

    if (definition.pageProfileIds.isNotEmpty) {
      children.add(
        CustomDropdown<String>(
          label: 'حجم الصفحة',
          rxValue: RxnString(
            presentation.pageProfileId ?? definition.pageProfileIds.first,
          ),
          items: definition.pageProfileIds
              .map(
                (id) => DropdownItem<String>(
                  value: id,
                  child: Text(id),
                ),
              )
              .toList(growable: false),
          onChanged: (id) {
            if (id != null) onChanged(_copy(pageProfileId: id));
          },
        ),
      );
    }

    if (definition.templates.isNotEmpty) {
      children.add(
        CustomDropdown<String>(
          label: 'قالب التقرير',
          rxValue: RxnString(presentation.template?.reference.key ?? ''),
          items: [
            const DropdownItem<String>(
              value: '',
              child: Text('القالب الافتراضي'),
            ),
            ...definition.templates.map(
              (item) => DropdownItem<String>(
                value: item.key,
                child: Text(item.key),
              ),
            ),
          ],
          onChanged: (key) {
            final template = definition.templates
                .where((item) => item.key == key)
                .firstOrNull;
            onChanged(
              _copy(
                template: template == null
                    ? null
                    : ReportTemplateSelection(
                        id: template.id,
                        version: template.version,
                      ),
                clearTemplate: template == null,
              ),
            );
          },
        ),
      );
    }

    children.add(
      Row(
        children: [
          const Expanded(child: Text('إظهار المؤشرات')),
          CustomSwitch(
            value: presentation.includeMetrics,
            onChanged: (value) =>
                onChanged(_copy(includeMetrics: value)),
          ),
        ],
      ),
    );

    children.add(
      Row(
        children: [
          const Expanded(child: Text('إظهار الرسوم البيانية')),
          CustomSwitch(
            value: presentation.includeCharts,
            enabled: definition.chartsAvailable,
            onChanged: definition.chartsAvailable
                ? (value) => onChanged(_copy(includeCharts: value))
                : null,
          ),
        ],
      ),
    );

    final issues = presentation.validateAgainst(definition);
    if (issues.isNotEmpty) {
      children.add(
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
      );
    }

    return OperationalReportStudioSection(
      title: 'تصميم المخرجات',
      icon: Icons.tune_rounded,
      children: children,
    );
  }
}
