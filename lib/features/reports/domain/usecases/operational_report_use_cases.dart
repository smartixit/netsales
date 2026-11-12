import 'dart:typed_data';

import 'package:netsales/core/models/paginated_list.dart';
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
    String? fromDate,
    String? toDate,
    String? search,
    String? status,
    String? saleType,
    String? cursor,
  }) => repository.getReport(
    type: type,
    networkId: networkId,
    posId: posId,
    fromDate: fromDate,
    toDate: toDate,
    search: search,
    status: status,
    saleType: saleType,
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
    String? fromDate,
    String? toDate,
    String? search,
    String? status,
    String? saleType,
  }) => repository.getSummary(
    type: type,
    networkId: networkId,
    posId: posId,
    fromDate: fromDate,
    toDate: toDate,
    search: search,
    status: status,
    saleType: saleType,
  );
}

class RequestOperationalReportExportUseCase {
  const RequestOperationalReportExportUseCase(this.repository);
  final OperationalReportRepository repository;

  Future<OperationalReportExport> call({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    String? fromDate,
    String? toDate,
    String? search,
    String? status,
    String? saleType,
  }) => repository.requestExport(
    type: type,
    networkId: networkId,
    posId: posId,
    fromDate: fromDate,
    toDate: toDate,
    search: search,
    status: status,
    saleType: saleType,
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
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    String? fromDate,
    String? toDate,
    String? scopeLabel,
    String? search,
    String? status,
    String? saleType,
  }) => repository.saveSummaryPdf(
    type: type,
    summary: summary,
    organizationName: organizationName,
    logoUrl: logoUrl,
    fromDate: fromDate,
    toDate: toDate,
    scopeLabel: scopeLabel,
    search: search,
    status: status,
    saleType: saleType,
  );
}

class ShareOperationalReportSummaryPdfUseCase {
  const ShareOperationalReportSummaryPdfUseCase(this.repository);
  final OperationalReportRepository repository;

  Future<bool> call({
    required OperationalReportType type,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    String? fromDate,
    String? toDate,
    String? scopeLabel,
    String? search,
    String? status,
    String? saleType,
  }) => repository.shareSummaryPdf(
    type: type,
    summary: summary,
    organizationName: organizationName,
    logoUrl: logoUrl,
    fromDate: fromDate,
    toDate: toDate,
    scopeLabel: scopeLabel,
    search: search,
    status: status,
    saleType: saleType,
  );
}

class PrintOperationalReportSummaryPdfUseCase {
  const PrintOperationalReportSummaryPdfUseCase(this.repository);
  final OperationalReportRepository repository;

  Future<bool> call({
    required OperationalReportType type,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    String? fromDate,
    String? toDate,
    String? scopeLabel,
    String? search,
    String? status,
    String? saleType,
  }) => repository.printSummaryPdf(
    type: type,
    summary: summary,
    organizationName: organizationName,
    logoUrl: logoUrl,
    fromDate: fromDate,
    toDate: toDate,
    scopeLabel: scopeLabel,
    search: search,
    status: status,
    saleType: saleType,
  );
}

class DownloadOperationalReportExportUseCase {
  const DownloadOperationalReportExportUseCase(this.repository);
  final OperationalReportRepository repository;
  Future<Uint8List?> call(String url) => repository.downloadExport(url);
}
