import 'dart:typed_data';

import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/reports/data/datasources/operational_report_remote_data_source.dart';
import 'package:netsales/features/reports/data/models/operational_report_export_model.dart';
import 'package:netsales/features/reports/data/models/operational_report_catalog_model.dart';

class OperationalReportRemoteDataSourceImpl
    implements OperationalReportRemoteDataSource {
  const OperationalReportRemoteDataSourceImpl();


  @override
  Future<ApiResponse<OperationalReportCatalogModel>> getCatalog({
    required Map<String, dynamic> query,
  }) {
    return ApiService.instance.get<OperationalReportCatalogModel>(
      ApiConstants.operationalReportCatalog,
      queryParameters: query,
      fromJson: OperationalReportCatalogModel.fromJson,
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getReport({
    required Map<String, dynamic> query,
  }) {
    return ApiService.instance.get<List<Map<String, dynamic>>>(
      ApiConstants.operationalReports,
      queryParameters: query,
      fromJson: (data) {
        final rows = data is Map ? data['data'] : data;
        if (rows is! List) {
          throw const FormatException('لم يُرجع الخادم قائمة سجلات صالحة.');
        }
        return rows.map((row) {
          if (row is! Map) {
            throw const FormatException('يوجد سجل تقرير بتنسيق غير صالح.');
          }
          return Map<String, dynamic>.from(row);
        }).toList(growable: false);
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getSummary({
    required Map<String, dynamic> query,
  }) {
    return ApiService.instance.get<Map<String, dynamic>>(
      ApiConstants.operationalReportSummary,
      queryParameters: query,
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException('تنسيق ملخص التقرير غير صالح.');
        }
        return Map<String, dynamic>.from(json);
      },
    );
  }

  @override
  Future<ApiResponse<OperationalReportExportModel>> requestExport({
    required Map<String, dynamic> payload,
  }) {
    return ApiService.instance.post<OperationalReportExportModel>(
      ApiConstants.operationalReportExports,
      data: payload,
      fromJson: OperationalReportExportModel.fromJson,
    );
  }

  @override
  Future<ApiResponse<OperationalReportExportModel>> getExportStatus(
    String exportId,
  ) {
    return ApiService.instance.get<OperationalReportExportModel>(
      ApiConstants.operationalReportExportStatus(exportId),
      fromJson: OperationalReportExportModel.fromJson,
    );
  }

  @override
  Future<Uint8List?> downloadExport(String url) {
    return ApiService.instance.downloadBytes(url);
  }
}
