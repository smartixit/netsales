import 'package:document_engine/document_engine.dart';

import 'report_catalog_item.dart';

class ReportEngineDefinitionFactory {
  const ReportEngineDefinitionFactory();

  ReportDefinition create(ReportCatalogItem report) {
    final filters = report.filters.entries.map((entry) {
      final specification = entry.value is Map
          ? Map<String, dynamic>.from(entry.value as Map)
          : const <String, dynamic>{};
      final kind = switch (specification['type']) {
        'integer' => ReportFilterKind.integer,
        'date' => ReportFilterKind.date,
        'boolean' => ReportFilterKind.boolean,
        _ => ReportFilterKind.text,
      };
      return ReportFilterDefinition(
        id: entry.key,
        labelKey: 'report_filter.${entry.key}',
        kind: kind,
        required: specification['required'] == true,
        maxLength: specification['max'] is num
            ? (specification['max'] as num).toInt()
            : null,
      );
    }).toList(growable: false);

    return ReportDefinition(
      id: ReportId(report.key),
      schemaVersion: int.tryParse(report.definitionVersion.split('.').first) ?? 1,
      titleKey: 'report_title.${report.key}',
      descriptionKey: 'report_description.${report.key}',
      supportedLocaleTags: const ['ar'],
      filters: filters,
      columns: [
        ReportColumnDefinition(
          id: 'records_count',
          labelKey: 'report_configuration.records_count',
          dataType: ReportDataType.integer,
          visibleByDefault: true,
          hideable: false,
        ),
      ],
      executionPolicy: ReportExecutionPolicy.server,
    );
  }
}
