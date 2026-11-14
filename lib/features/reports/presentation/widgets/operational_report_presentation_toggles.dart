import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:netsales/features/reports/presentation/widgets/report_presentation_options_update.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';

/// Optional summary metrics and charts included in the report presentation.
class OperationalReportPresentationToggles extends StatelessWidget {
  const OperationalReportPresentationToggles({
    required this.definition,
    required this.presentation,
    required this.onChanged,
    super.key,
  });

  final ReportDefinition definition;
  final ReportPresentationOptions presentation;
  final ValueChanged<ReportPresentationOptions> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Text('إظهار المؤشرات')),
            CustomSwitch(
              value: presentation.includeMetrics,
              onChanged: (value) => onChanged(
                copyReportPresentationOptions(
                  presentation,
                  includeMetrics: value,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(child: Text('إظهار الرسوم البيانية')),
            CustomSwitch(
              value: presentation.includeCharts,
              enabled: definition.chartsAvailable,
              onChanged: definition.chartsAvailable
                  ? (value) => onChanged(
                      copyReportPresentationOptions(
                        presentation,
                        includeCharts: value,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
