import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_studio_section.dart';
import 'package:netsales/widgets/badges/custom_filter_chip.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_field.dart';

/// Builds typed report criteria controls without owning report business state.
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
    final controls = <Widget>[];

    for (final filter in definition.filters) {
      final label = resolveLabel(context, filter.labelKey);
      final value = criteria.filters[filter.id];
      final isRequired = filter.required;

      switch (filter.kind) {
        case ReportFilterKind.text:
        case ReportFilterKind.integer:
        case ReportFilterKind.decimal:
          controls.add(
            CustomTextField(
              controller: textControllerFor(filter.id),
              label: label,
              isRequired: isRequired,
              keyboardType: switch (filter.kind) {
                ReportFilterKind.text => TextInputType.text,
                ReportFilterKind.integer => TextInputType.number,
                _ => const TextInputType.numberWithOptions(decimal: true),
              },
              onChanged: (text) {
                ReportFilterValue? next;
                final normalized = text.trim();
                if (normalized.isNotEmpty) {
                  if (filter.kind == ReportFilterKind.text) {
                    next = ReportTextFilterValue(normalized);
                  } else if (filter.kind == ReportFilterKind.integer) {
                    final parsed = int.tryParse(normalized);
                    if (parsed != null) {
                      next = ReportIntegerFilterValue(parsed);
                    }
                  } else {
                    try {
                      next = ReportDecimalFilterValue(normalized);
                    } on ArgumentError {
                      next = null;
                    }
                  }
                }
                onFilterChanged(filter.id, next);
              },
            ),
          );

        case ReportFilterKind.date:
          final selected =
              value is ReportDateFilterValue ? value.value : null;
          controls.add(
            CustomDatePickerField.single(
              label: label,
              value: selected,
              isRequired: isRequired,
              onChanged: (date) => onFilterChanged(
                filter.id,
                date == null ? null : ReportDateFilterValue(date),
              ),
            ),
          );

        case ReportFilterKind.dateRange:
          final range =
              value is ReportDateRangeFilterValue ? value : null;
          controls.add(
            CustomDatePickerField.range(
              label: label,
              value: range?.start != null && range?.end != null
                  ? DateTimeRange(start: range!.start!, end: range.end!)
                  : null,
              isRequired: isRequired,
              onChanged: (selected) => onFilterChanged(
                filter.id,
                selected == null
                    ? null
                    : ReportDateRangeFilterValue(
                        start: selected.start,
                        end: selected.end,
                      ),
              ),
            ),
          );

        case ReportFilterKind.boolean:
          final enabled =
              value is ReportBooleanFilterValue && value.value;
          controls.add(
            Row(
              children: [
                Expanded(child: Text(label)),
                CustomSwitch(
                  value: enabled,
                  onChanged: (next) => onFilterChanged(
                    filter.id,
                    ReportBooleanFilterValue(next),
                  ),
                ),
              ],
            ),
          );

        case ReportFilterKind.singleChoice:
          controls.add(
            CustomDropdown<String>(
              label: label,
              hint: 'اختر $label',
              isRequired: isRequired,
              rxValue: choiceValueFor(filter.id),
              items: [
                const DropdownItem<String>(
                  value: '',
                  child: Text('الكل'),
                ),
                ...filter.choices.map(
                  (choice) => DropdownItem<String>(
                    value: choice.value,
                    child: Text(resolveLabel(context, choice.labelKey)),
                  ),
                ),
              ],
              onChanged: (selected) => onFilterChanged(
                filter.id,
                selected == null || selected.isEmpty
                    ? null
                    : ReportChoiceFilterValue(selected),
              ),
            ),
          );

        case ReportFilterKind.multiChoice:
          final selected = value is ReportChoicesFilterValue
              ? value.values.toSet()
              : <String>{};
          controls.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: filter.choices.map((choice) {
                    final active = selected.contains(choice.value);
                    return CustomFilterChip(
                      label: resolveLabel(context, choice.labelKey),
                      isSelected: active,
                      onSelected: () {
                        final next = {...selected};
                        if (active) {
                          next.remove(choice.value);
                        } else {
                          next.add(choice.value);
                        }
                        onFilterChanged(
                          filter.id,
                          next.isEmpty
                              ? null
                              : ReportChoicesFilterValue(
                                  next.toList()..sort(),
                                ),
                        );
                      },
                      isCompact: true,
                    );
                  }).toList(growable: false),
                ),
              ],
            ),
          );
      }
    }

    final issues = criteria.validateAgainst(definition);
    if (issues.isNotEmpty) {
      controls.add(
        OperationalReportValidationNotice(
          title: 'راجع معايير التقرير',
          messages: issues.map((issue) {
            final field = definition.filter(issue.fieldId);
            final fieldLabel = field == null
                ? issue.fieldId
                : resolveLabel(context, field.labelKey);
            return switch (issue.code) {
              'required_filter_missing' => 'الحقل «$fieldLabel» مطلوب.',
              'unknown_filter' =>
                'المرشح «$fieldLabel» غير موجود في تعريف التقرير الحالي.',
              'filter_type_mismatch' =>
                'نوع القيمة المحددة للحقل «$fieldLabel» غير متوافق.',
              'text_too_short' =>
                'النص في الحقل «$fieldLabel» أقصر من الحد المسموح.',
              'text_too_long' =>
                'النص في الحقل «$fieldLabel» يتجاوز الحد المسموح.',
              'choice_not_allowed' =>
                'القيمة المختارة للحقل «$fieldLabel» غير متاحة.',
              _ => 'تعذر التحقق من الحقل «$fieldLabel».',
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
