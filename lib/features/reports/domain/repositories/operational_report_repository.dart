import 'dart:typed_data';

import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_export.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';

abstract interface class OperationalReportRepository {
  Future<PaginatedList<OperationalReportRecord>> getReport({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    String? fromDate,
    String? toDate,
    String? search,
    String? status,
    String? saleType,
    String? cursor,
    int perPage = 25,
  });

  Future<OperationalReportExport> requestExport({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    String? fromDate,
    String? toDate,
    String? search,
    String? status,
    String? saleType,
  });

  Future<OperationalReportExport> getExportStatus(String exportId);

  Future<Uint8List?> downloadExport(String url);
}
