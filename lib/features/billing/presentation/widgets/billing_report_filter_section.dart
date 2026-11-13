import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_date_range_section.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

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
        BillingReportDateRangeSection(
          criteria: criteria,
          hasFromDate: fromFilter != null,
          hasToDate: toFilter != null,
          onChanged: onChanged,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

}
