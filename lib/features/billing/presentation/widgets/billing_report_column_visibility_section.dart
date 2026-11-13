import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';

class BillingReportColumnVisibilitySection extends StatelessWidget {
  const BillingReportColumnVisibilitySection({
    required this.columns,
    required this.presentation,
    required this.resolveLabel,
    required this.onChanged,
    super.key,
  });

  final List<ReportColumnDefinition> columns;
  final ReportPresentationOptions presentation;
  final ReportLabelResolver resolveLabel;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'الأعمدة الظاهرة في PDF',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        ...columns.map(
          (column) => Row(
            children: [
              Expanded(
                child: Text(resolveLabel(context, column.labelKey)),
              ),
              CustomSwitch(
                value: presentation.visibleColumnIds.contains(column.id),
                enabled: column.hideable,
                onChanged: (value) {
                  final selected =
                      List<String>.from(presentation.visibleColumnIds);
                  if (value && !selected.contains(column.id)) {
                    selected.add(column.id);
                  }
                  if (!value && selected.length > 1) {
                    selected.remove(column.id);
                  }
                  onChanged(selected);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
