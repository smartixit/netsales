import 'dart:typed_data';

import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/share_service.dart';
import 'package:netsales/features/reports/data/datasources/report_remote_data_source.dart';
import 'package:netsales/features/reports/domain/entities/report_catalog_item.dart';
import 'package:netsales/features/reports/domain/entities/report_run.dart';
import 'package:netsales/features/reports/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this.remote);
  final ReportRemoteDataSource remote;

  @override
  Future<List<ReportCatalogItem>> getNetworkCatalog(int networkId) async {
    final response = await remote.getNetworkCatalog(networkId);
    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'تعذر تحميل كتالوج التقارير.',
        code: 'REPORT_CATALOG_FAILED',
      );
    }
    return response.data!;
  }

  @override
  Future<ReportRun> createNetworkRun({
    required int networkId,
    required String reportKey,
    required Map<String, dynamic> filters,
  }) async {
    final response = await remote.createNetworkRun(
      networkId: networkId,
      reportKey: reportKey,
      filters: filters,
    );
    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'تعذر إنشاء التقرير.',
        code: 'REPORT_RUN_CREATE_FAILED',
      );
    }
    return response.data!;
  }

  @override
  Future<ReportRun> getNetworkRun({
    required int networkId,
    required int reportRunId,
  }) async {
    final response = await remote.getNetworkRun(
      networkId: networkId,
      reportRunId: reportRunId,
    );
    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'تعذر تحديث حالة التقرير.',
        code: 'REPORT_RUN_STATUS_FAILED',
      );
    }
    return response.data!;
  }

  @override
  Future<void> downloadArtifact({
    required String url,
    required String fileName,
  }) async {
    final bytes = await remote.downloadArtifact(url);
    final result = await FileExportService.instance.saveFile(
      bytes: Uint8List.fromList(bytes),
      fileName: fileName,
      extension: 'json',
      namingStrategy: FileNamingStrategy.report,
      folderName: 'NetSales/Reports',
    );
    if (!result.isSuccess) {
      throw AppException(
        result.errorMessage ?? 'تعذر حفظ ملف التقرير.',
        code: 'REPORT_ARTIFACT_SAVE_FAILED',
      );
    }
  }

  @override
  Future<void> shareArtifact({
    required String url,
    required String fileName,
  }) async {
    final bytes = await remote.downloadArtifact(url);
    await ShareService.instance.shareBytes(
      bytes: Uint8List.fromList(bytes),
      fileName: '$fileName.json',
      mimeType: 'application/json',
      subject: 'تقرير NetSales',
    );
  }
}
