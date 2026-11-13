import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_modal.dart';

class BillingReportFilterSection extends StatelessWidget {
  const BillingReportFilterSection({
    required this.controller,
    required this.definition,
    required this.criteria,
    required this.onChanged,
    required this.resolveLabel,
    super.key,
  });

  final BillingReportsController controller;
  final ReportDefinition definition;
  final ReportCriteria criteria;
  final ValueChanged<ReportCriteria> onChanged;
  final ReportLabelResolver resolveLabel;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    final searchFilter = definition.filter('search');
    if (searchFilter != null) {
      widgets.add(
        CustomTextField(
          controller: controller.searchController,
          label: resolveLabel(context, searchFilter.labelKey),
          hint: 'ابحث في سجلات التقرير',
          prefixIcon: const Icon(Icons.search),
          isRequired: searchFilter.required,
          onChanged: (value) {
            final next =
                Map<String, ReportFilterValue>.from(criteria.filters);
            if (value.trim().isEmpty) {
              next.remove('search');
            } else {
              next['search'] = ReportTextFilterValue(value.trim());
            }
            onChanged(ReportCriteria(filters: next));
          },
        ),
      );
    }

    final statusFilter = definition.filter('status');
    if (statusFilter != null) {
      widgets.add(const SizedBox(height: 10));
      if (statusFilter.choices.isNotEmpty) {
        widgets.add(
          CustomDropdown<String>(
            items: statusFilter.choices
                .map(
                  (choice) => DropdownItem<String>(
                    value: choice.value,
                    child: Text(resolveLabel(context, choice.labelKey)),
                  ),
                )
                .toList(growable: false),
            rxValue: controller.selectedStatus,
            onChanged: (value) {
              final next =
                  Map<String, ReportFilterValue>.from(criteria.filters);
              if (value == null || value.isEmpty) {
                next.remove('status');
              } else {
                next['status'] = ReportChoiceFilterValue(value);
              }
              onChanged(ReportCriteria(filters: next));
            },
            label: resolveLabel(context, statusFilter.labelKey),
            hint: 'كل الحالات',
          ),
        );
      } else {
        widgets.add(
          CustomTextField(
            controller: controller.statusController,
            label: resolveLabel(context, statusFilter.labelKey),
            hint: 'أدخل الحالة',
            isRequired: statusFilter.required,
            onChanged: (value) {
              final next =
                  Map<String, ReportFilterValue>.from(criteria.filters);
              if (value.trim().isEmpty) {
                next.remove('status');
              } else {
                next['status'] = ReportTextFilterValue(value.trim());
              }
              onChanged(ReportCriteria(filters: next));
            },
          ),
        );
      }
    }

    final fromFilter = definition.filter('from_date');
    final toFilter = definition.filter('to_date');
    if (fromFilter != null || toFilter != null) {
      widgets.add(const SizedBox(height: 10));
      widgets.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (fromFilter != null)
              CustomButton.outline(
                text: _dateLabel('من تاريخ', criteria.filters['from_date']),
                prefix: Icons.calendar_today,
                onPressed: () => _pickCriteriaDate(
                  context,
                  'from_date',
                  criteria,
                  onChanged,
                ),
              ),
            if (toFilter != null)
              CustomButton.outline(
                text: _dateLabel('إلى تاريخ', criteria.filters['to_date']),
                prefix: Icons.event,
                onPressed: () => _pickCriteriaDate(
                  context,
                  'to_date',
                  criteria,
                  onChanged,
                ),
              ),
            CustomButton.text(
              text: 'مسح الفلاتر',
              onPressed: () => onChanged(ReportCriteria()),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Future<void> _pickCriteriaDate(
    BuildContext context,
    String id,
    ReportCriteria currentCriteria,
    ValueChanged<ReportCriteria> onChanged,
  ) async {
    final current = currentCriteria.filters[id];
    final initial = current is ReportDateFilterValue
        ? current.value
        : DateTime.now();
    final selected = await CustomDatePickerModal.showDialog(
      context: context,
      initialValue: [initial],
      title: id == 'from_date' ? 'اختر تاريخ البداية' : 'اختر تاريخ النهاية',
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    final value =
        selected != null && selected.isNotEmpty ? selected.first : null;
    if (value == null) return;

    if (id == 'from_date') {
      final end = currentCriteria.filters['to_date'];
      if (end is ReportDateFilterValue && value.isAfter(end.value)) return;
    } else {
      final start = currentCriteria.filters['from_date'];
      if (start is ReportDateFilterValue && value.isBefore(start.value)) {
        return;
      }
    }

    final next = Map<String, ReportFilterValue>.from(currentCriteria.filters)
      ..[id] = ReportDateFilterValue(value);
    onChanged(ReportCriteria(filters: next));
  }

  String _dateLabel(String label, ReportFilterValue? value) {
    if (value is! ReportDateFilterValue) return label;
    final date = value.value;
    return '$label ${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
