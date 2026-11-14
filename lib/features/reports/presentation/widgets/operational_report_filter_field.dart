import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/widgets/badges/custom_filter_chip.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_field.dart';

/// One schema-defined filter control, bound to the host-owned typed criteria.
class OperationalReportFilterField extends StatelessWidget {
  const OperationalReportFilterField({
    required this.definition,
    required this.value,
    required this.resolveLabel,
    required this.textController,
    required this.choiceValue,
    required this.onChanged,
    super.key,
  });

  final ReportFilterDefinition definition;
  final ReportFilterValue? value;
  final ReportLabelResolver resolveLabel;
  final TextEditingController textController;
  final RxnString choiceValue;
  final ValueChanged<ReportFilterValue?> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = resolveLabel(context, definition.labelKey);
    switch (definition.kind) {
      case ReportFilterKind.text:
      case ReportFilterKind.integer:
      case ReportFilterKind.decimal:
        return CustomTextField(
          controller: textController,
          label: label,
          isRequired: definition.required,
          keyboardType: switch (definition.kind) {
            ReportFilterKind.text => TextInputType.text,
            ReportFilterKind.integer => TextInputType.number,
            _ => const TextInputType.numberWithOptions(decimal: true),
          },
          onChanged: (text) {
            ReportFilterValue? next;
            final normalized = text.trim();
            if (normalized.isNotEmpty) {
              if (definition.kind == ReportFilterKind.text) {
                next = ReportTextFilterValue(normalized);
              } else if (definition.kind == ReportFilterKind.integer) {
                final parsed = int.tryParse(normalized);
                if (parsed != null) next = ReportIntegerFilterValue(parsed);
              } else {
                try {
                  next = ReportDecimalFilterValue(normalized);
                } on ArgumentError {
                  next = null;
                }
              }
            }
            onChanged(next);
          },
        );

      case ReportFilterKind.date:
        final currentValue = value;
        final selected = currentValue is ReportDateFilterValue
            ? currentValue.value
            : null;
        return CustomDatePickerField.single(
          label: label,
          value: selected,
          isRequired: definition.required,
          onChanged: (date) => onChanged(
            date == null ? null : ReportDateFilterValue(date),
          ),
        );

      case ReportFilterKind.dateRange:
        final currentValue = value;
        final range = currentValue is ReportDateRangeFilterValue
            ? currentValue
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              definition.required ? '$label *' : label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            CustomDatePickerField.single(
              label: 'من تاريخ',
              hint: 'بداية الفترة',
              value: range?.start,
              onChanged: (start) => _updateDateRange(start, range?.end),
            ),
            const SizedBox(height: 10),
            CustomDatePickerField.single(
              label: 'إلى تاريخ',
              hint: 'نهاية الفترة',
              value: range?.end,
              onChanged: (end) => _updateDateRange(range?.start, end),
            ),
          ],
        );

      case ReportFilterKind.boolean:
        final currentValue = value;
        final enabled = currentValue is ReportBooleanFilterValue &&
            currentValue.value;
        return Row(
          children: [
            Expanded(child: Text(label)),
            CustomSwitch(
              value: enabled,
              onChanged: (next) => onChanged(ReportBooleanFilterValue(next)),
            ),
          ],
        );

      case ReportFilterKind.singleChoice:
        return CustomDropdown<String>(
          label: label,
          hint: 'اختر $label',
          isRequired: definition.required,
          rxValue: choiceValue,
          items: [
            const DropdownItem<String>(
              value: '',
              child: Text('الكل'),
            ),
            ...definition.choices.map(
              (choice) => DropdownItem<String>(
                value: choice.value,
                child: Text(resolveLabel(context, choice.labelKey)),
              ),
            ),
          ],
          onChanged: (selected) => onChanged(
            selected == null || selected.isEmpty
                ? null
                : ReportChoiceFilterValue(selected),
          ),
        );

      case ReportFilterKind.multiChoice:
        final currentValue = value;
        final selected = currentValue is ReportChoicesFilterValue
            ? <String>{...currentValue.values}
            : <String>{};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: definition.choices.map((choice) {
                final active = selected.contains(choice.value);
                return CustomFilterChip(
                  label: resolveLabel(context, choice.labelKey),
                  isSelected: active,
                  onSelected: () {
                    final next = <String>{...selected};
                    if (active) {
                      next.remove(choice.value);
                    } else {
                      next.add(choice.value);
                    }
                    onChanged(
                      next.isEmpty
                          ? null
                          : ReportChoicesFilterValue(next.toList()..sort()),
                    );
                  },
                  isCompact: true,
                );
              }).toList(growable: false),
            ),
          ],
        );
    }
  }

  void _updateDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      onChanged(null);
      return;
    }
    // The date range contract rejects inverted bounds. Ignore an invalid
    // intermediate selection instead of throwing from a UI callback.
    if (start != null && end != null && end.isBefore(start)) return;
    onChanged(ReportDateRangeFilterValue(start: start, end: end));
  }
}
