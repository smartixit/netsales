import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/reports/data/datasources/reports_remote_data_source.dart';
import 'package:netsales/features/reports/domain/entities/report_export_job.dart';
import 'package:netsales/features/reports/domain/entities/report_page.dart';
import 'package:netsales/features/reports/domain/entities/report_type.dart';
import 'package:netsales/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this.remoteDataSource);
  final ReportsRemoteDataSource remoteDataSource;

  @override
  Future<ReportPage> fetch({
    required ReportType type,
    required int networkId,
    int? posId,
    String? fromDate,
    String? toDate,
    String? cursor,
    int perPage = 25,
  }) async {
    final response = await remoteDataSource.fetchReport(query: {
      'report_type': type.value,
      'network_id': networkId,
      if (posId != null) 'pos_id': posId,
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'per_page': perPage,
    });

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'تعذر تحميل التقرير.',
        code: 'OPERATIONAL_REPORT_LOAD_FAILED',
        details: response.errors,
      );
    }

    final payload = response.data!;
    final rawRows = payload['data'] ?? payload['items'] ?? const <dynamic>[];
    final rows = rawRows is List
        ? rawRows.map((row) => Map<String, dynamic>.unmodifiable(
              Map<String, dynamic>.from(row as Map),
            )).toList(growable: false)
        : const <Map<String, dynamic>>[];

    final meta = payload['meta'] is Map
        ? Map<String, dynamic>.from(payload['meta'] as Map)
        : const <String, dynamic>{};
    return ReportPage(
      rows: rows,
      nextCursor: payload['next_cursor']?.toString() ??
          response.nextCursor ??
          meta['next_cursor']?.toString(),
      prevCursor: payload['prev_cursor']?.toString() ??
          response.prevCursor ??
          meta['prev_cursor']?.toString(),
      perPage: int.tryParse(
        (payload['per_page'] ?? meta['per_page'] ?? perPage).toString(),
      ),
    );
  }

  @override
  Future<ReportExportJob> requestExport({
    required ReportType type,
    required int networkId,
    int? posId,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await remoteDataSource.requestExport(payload: {
      'report_type': type.value,
      'network_id': networkId,
      if (posId != null) 'pos_id': posId,
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
    });
    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'تعذر بدء تصدير التقرير.',
        code: 'REPORT_EXPORT_REQUEST_FAILED',
        details: response.errors,
      );
    }
    final data = response.data!;
    final id = data['export_id']?.toString();
    if (id == null || id.isEmpty) {
      throw AppException('لم يُرجع الخادم معرّف طلب التصدير.',
        code: 'REPORT_EXPORT_ID_MISSING');
    }
    return ReportExportJob(
      exportId: id,
      status: data['status']?.toString() ?? 'QUEUED',
      statusUrl: data['status_url']?.toString(),
    );
  }

  @override
  Future<ReportExportJob> getExportStatus(String exportId) async {
    final response = await remoteDataSource.getExportStatus(exportId);
    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'تعذر متابعة طلب التصدير.',
        code: 'REPORT_EXPORT_STATUS_FAILED',
        details: response.errors,
      );
    }
    final data = response.data!;
    return ReportExportJob(
      exportId: data['export_id']?.toString() ?? exportId,
      status: data['status']?.toString() ?? 'UNKNOWN',
      downloadUrl: data['download_url']?.toString(),
      fileName: data['file_name']?.toString(),
    );
  }

  @override
  Future<List<int>> downloadExport(String url) async {
    final bytes = await remoteDataSource.downloadExport(url);
    if (bytes == null || bytes.isEmpty) {
      throw AppException('تعذر تنزيل ملف التقرير أو أن الملف فارغ.',
        code: 'REPORT_EXPORT_DOWNLOAD_FAILED');
    }
    return bytes;
  }
}
