import 'package:document_engine/document_engine.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';

class OperationalReportAccess {
  const OperationalReportAccess({
    required this.available,
    required this.viewPermission,
    required this.exportPermission,
    required this.supportedScopes,
    required this.posSelection,
    this.unavailableReason,
  });

  final bool available;
  final String viewPermission;
  final String exportPermission;
  final List<String> supportedScopes;
  final String posSelection;
  final String? unavailableReason;
}

class OperationalReportChartSlot {
  const OperationalReportChartSlot({
    required this.id,
    required this.label,
    required this.chartType,
    required this.valueKey,
    required this.labelKey,
  });

  final String id;
  final String label;
  final String chartType;
  final String valueKey;
  final String labelKey;
}

class OperationalReportCatalogEntry {
  const OperationalReportCatalogEntry({
    required this.type,
    required this.label,
    required this.description,
    required this.definition,
    required this.access,
    required this.chartSlots,
    required this.filterLabels,
    required this.columnLabels,
    required this.metricLabels,
  });

  final OperationalReportType type;
  final String label;
  final String description;
  final ReportDefinition definition;
  final OperationalReportAccess access;
  final List<OperationalReportChartSlot> chartSlots;
  final Map<String, String> filterLabels;
  final Map<String, String> columnLabels;
  final Map<String, String> metricLabels;
}

class OperationalReportCatalog {
  const OperationalReportCatalog({
    required this.schemaVersion,
    required this.entries,
  });

  final int schemaVersion;
  final List<OperationalReportCatalogEntry> entries;

  OperationalReportCatalogEntry? entryFor(OperationalReportType type) {
    for (final entry in entries) {
      if (entry.type == type) return entry;
    }
    return null;
  }

  ReportDefinition? definitionFor(OperationalReportType type) =>
      entryFor(type)?.definition;

  List<OperationalReportType> get availableTypes => entries
      .where((entry) => entry.access.available)
      .map((entry) => entry.type)
      .toList(growable: false);
}
