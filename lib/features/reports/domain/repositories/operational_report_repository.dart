import 'package:netsales/features/reports/domain/entities/operational_report_filter_display.dart';
import 'dart:typed_data';

import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_export.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_catalog.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';
import 'package:document_engine/document_engine.dart';

abstract interface class OperationalReportRepository {
  Future<OperationalReportCatalog> getCatalog({
    required int networkId,
    int? posId,
  });

  Future<PaginatedList<OperationalReportRecord>> getReport({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    required ReportCriteria criteria,
    String? cursor,
    int perPage = 25,
  });

  Future<OperationalReportSummary> getSummary({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    required ReportCriteria criteria,
  });

  Future<OperationalReportExport> requestExport({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    required ReportCriteria criteria,
  });

  Future<OperationalReportExport> getExportStatus(String exportId);

  Future<bool> saveSummaryPdf({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  });

  Future<bool> shareSummaryPdf({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  });

  Future<bool> printSummaryPdf({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  });

  Future<Uint8List?> downloadExport(String url);
}
