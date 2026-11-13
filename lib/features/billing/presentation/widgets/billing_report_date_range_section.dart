import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_modal.dart';

class BillingReportDateRangeSection extends StatelessWidget {
  const BillingReportDateRangeSection({
    required this.criteria,
    required this.hasFromDate,
    required this.hasToDate,
    required this.onChanged,
    super.key,
  });

  final ReportCriteria criteria;
  final bool hasFromDate;
  final bool hasToDate;
  final ValueChanged<ReportCriteria> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!hasFromDate && !hasToDate) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (hasFromDate)
          CustomButton.outline(
            text: _dateLabel('من تاريخ', criteria.filters['from_date']),
            prefix: Icons.calendar_today,
            onPressed: () =>
                _pickCriteriaDate(context, 'from_date'),
          ),
        if (hasToDate)
          CustomButton.outline(
            text: _dateLabel('إلى تاريخ', criteria.filters['to_date']),
            prefix: Icons.event,
            onPressed: () => _pickCriteriaDate(context, 'to_date'),
          ),
        CustomButton.text(
          text: 'مسح الفلاتر',
          onPressed: () => onChanged(ReportCriteria()),
        ),
      ],
    );
  }

  Future<void> _pickCriteriaDate(BuildContext context, String id) async {
    final current = criteria.filters[id];
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
      final end = criteria.filters['to_date'];
      if (end is ReportDateFilterValue && value.isAfter(end.value)) return;
    } else {
      final start = criteria.filters['from_date'];
      if (start is ReportDateFilterValue && value.isBefore(start.value)) {
        return;
      }
    }

    final next = Map<String, ReportFilterValue>.from(criteria.filters)
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
