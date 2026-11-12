import 'dart:typed_data';

import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/reports/data/models/operational_report_export_model.dart';
import 'package:netsales/features/reports/data/models/operational_report_summary_model.dart';

abstract interface class OperationalReportRemoteDataSource {
  Future<ApiResponse<List<Map<String, dynamic>>>> getReport({
    required Map<String, dynamic> query,
  });

  Future<ApiResponse<OperationalReportSummaryModel>> getSummary({
    required Map<String, dynamic> query,
  });

  Future<ApiResponse<OperationalReportExportModel>> requestExport({
    required Map<String, dynamic> payload,
  });

  Future<ApiResponse<OperationalReportExportModel>> getExportStatus(
    String exportId,
  );

  Future<Uint8List?> downloadExport(String url);
}
