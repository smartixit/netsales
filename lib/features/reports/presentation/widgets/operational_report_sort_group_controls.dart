import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/reports/presentation/widgets/report_presentation_options_update.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// Server-side sorting and grouping choices for a report definition.
class OperationalReportSortGroupControls extends StatelessWidget {
  const OperationalReportSortGroupControls({
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
    final children = <Widget>[];
    final sortable =
        definition.columns.where((column) => column.sortable).toList();

    if (sortable.isNotEmpty) {
      children.add(
        CustomDropdown<String>(
          label: 'ترتيب حسب',
          hint: 'بدون ترتيب',
          rxValue: RxnString(
            presentation.sorts.isEmpty
                ? ''
                : presentation.sorts.first.fieldId,
          ),
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
          onChanged: (id) {
            onChanged(
              copyReportPresentationOptions(
                presentation,
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
            );
          },
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
            copyReportPresentationOptions(
              presentation,
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
              copyReportPresentationOptions(
                presentation,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
