import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:netsales/features/reports/presentation/widgets/report_presentation_options_update.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// Controls which server-defined report columns appear in the output.
class OperationalReportColumnVisibility extends StatelessWidget {
  const OperationalReportColumnVisibility({
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
    final visible = presentation.visibleColumnIds.isEmpty
        ? definition.columns
            .where((column) => column.visibleByDefault)
            .map((column) => column.id)
            .toSet()
        : presentation.visibleColumnIds.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'الأعمدة الظاهرة',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        for (final column in definition.columns)
          Row(
            children: [
              Expanded(child: Text(resolveLabel(context, column.labelKey))),
              CustomButton.icon(
                icon: visible.contains(column.id)
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                tooltip: visible.contains(column.id)
                    ? 'إخفاء العمود'
                    : 'إظهار العمود',
                onPressed: !column.hideable
                    ? null
                    : () {
                        final next = {...visible};
                        if (visible.contains(column.id)) {
                          if (next.length > 1) next.remove(column.id);
                        } else {
                          next.add(column.id);
                        }
                        onChanged(
                          copyReportPresentationOptions(
                            presentation,
                            visibleColumnIds: next.toList(),
                          ),
                        );
                      },
              ),
            ],
          ),
      ],
    );
  }
}
