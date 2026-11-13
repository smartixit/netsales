import 'package:netsales/features/reports/domain/entities/operational_report_filter_display.dart';
import 'dart:typed_data';

import 'package:netsales/core/models/paginated_list.dart';
import 'package:document_engine/document_engine.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_export.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_catalog.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';
import 'package:netsales/features/reports/domain/repositories/operational_report_repository.dart';

class GetOperationalReportCatalogUseCase {
  const GetOperationalReportCatalogUseCase(this.repository);
  final OperationalReportRepository repository;
  Future<OperationalReportCatalog> call({required int networkId, int? posId}) =>
      repository.getCatalog(networkId: networkId, posId: posId);
}


class GetOperationalReportUseCase {
  const GetOperationalReportUseCase(this.repository);
  final OperationalReportRepository repository;

  Future<PaginatedList<OperationalReportRecord>> call({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    required ReportCriteria criteria,
    String? cursor,
  }) => repository.getReport(
    type: type,
    networkId: networkId,
    posId: posId,
    criteria: criteria,
    cursor: cursor,
  );
}

class GetOperationalReportSummaryUseCase {
  const GetOperationalReportSummaryUseCase(this.repository);
  final OperationalReportRepository repository;

  Future<OperationalReportSummary> call({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    required ReportCriteria criteria,
  }) => repository.getSummary(
    type: type,
    networkId: networkId,
    posId: posId,
    criteria: criteria,
  );
}

class RequestOperationalReportExportUseCase {
  const RequestOperationalReportExportUseCase(this.repository);
  final OperationalReportRepository repository;

  Future<OperationalReportExport> call({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    required ReportCriteria criteria,
  }) => repository.requestExport(
    type: type,
    networkId: networkId,
    posId: posId,
    criteria: criteria,
  );
}

class GetOperationalReportExportStatusUseCase {
  const GetOperationalReportExportStatusUseCase(this.repository);
  final OperationalReportRepository repository;
  Future<OperationalReportExport> call(String exportId) =>
      repository.getExportStatus(exportId);
}

class SaveOperationalReportSummaryPdfUseCase {
  const SaveOperationalReportSummaryPdfUseCase(this.repository);
  final OperationalReportRepository repository;

  Future<bool> call({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) => repository.saveSummaryPdf(
    type: type,
    pageProfileId: pageProfileId,
    summary: summary,
    organizationName: organizationName,
    logoUrl: logoUrl,
    activeFilters: activeFilters,
    scopeLabel: scopeLabel,
  );
}

class ShareOperationalReportSummaryPdfUseCase {
  const ShareOperationalReportSummaryPdfUseCase(this.repository);
  final OperationalReportRepository repository;

  Future<bool> call({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) => repository.shareSummaryPdf(
    type: type,
    pageProfileId: pageProfileId,
    summary: summary,
    organizationName: organizationName,
    logoUrl: logoUrl,
    activeFilters: activeFilters,
    scopeLabel: scopeLabel,
  );
}

class PrintOperationalReportSummaryPdfUseCase {
  const PrintOperationalReportSummaryPdfUseCase(this.repository);
  final OperationalReportRepository repository;

  Future<bool> call({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) => repository.printSummaryPdf(
    type: type,
    pageProfileId: pageProfileId,
    summary: summary,
    organizationName: organizationName,
    logoUrl: logoUrl,
    activeFilters: activeFilters,
    scopeLabel: scopeLabel,
  );
}

class DownloadOperationalReportExportUseCase {
  const DownloadOperationalReportExportUseCase(this.repository);
  final OperationalReportRepository repository;
  Future<Uint8List?> call(String url) => repository.downloadExport(url);
}
