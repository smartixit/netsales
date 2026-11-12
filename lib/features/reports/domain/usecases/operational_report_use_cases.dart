import 'dart:typed_data';

import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_export.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/domain/repositories/operational_report_repository.dart';

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

class DownloadOperationalReportExportUseCase {
  const DownloadOperationalReportExportUseCase(this.repository);
  final OperationalReportRepository repository;
  Future<Uint8List?> call(String url) => repository.downloadExport(url);
}
