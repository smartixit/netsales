import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';

class OperationalReportCatalog {
  const OperationalReportCatalog({
    required this.schemaVersion,
    required this.reports,
  });

  final int schemaVersion;
  final List<Map<String, dynamic>> reports;

  bool isAvailable(OperationalReportType type) {
    final definition = definitionFor(type);
    return definition?['available'] == true;
  }

  Map<String, dynamic>? definitionFor(OperationalReportType type) {
    for (final definition in reports) {
      if (definition['id'] == type.wireValue) return definition;
    }
    return null;
  }

  List<OperationalReportType> get availableTypes => OperationalReportType.values
      .where(isAvailable)
      .toList(growable: false);
}
