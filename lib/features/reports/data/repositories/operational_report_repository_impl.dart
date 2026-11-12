import 'dart:typed_data';

import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/reports/data/datasources/operational_report_remote_data_source.dart';
import 'package:netsales/features/reports/data/models/operational_report_record_model.dart';
import 'package:netsales/features/reports/data/services/operational_report_document_service.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_export.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';
import 'package:netsales/features/reports/domain/repositories/operational_report_repository.dart';

class OperationalReportRepositoryImpl
    implements OperationalReportRepository {
  const OperationalReportRepositoryImpl(this.remoteDataSource);

  final OperationalReportRemoteDataSource remoteDataSource;

  @override
  Future<OperationalReportCatalog> getCatalog({
    required int networkId,
    int? posId,
  }) async {
    final response = await remoteDataSource.getCatalog(query: {
      'network_id': networkId,
      if (posId != null) 'pos_id': posId,
    });
    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'تعذر تحميل كتالوج التقارير.',
        code: 'OPERATIONAL_REPORT_CATALOG_FAILED',
        details: response.errors,
      );
    }
    return response.data!;
  }

  Map<String, dynamic> _filters({
    String? fromDate,
    String? toDate,
    String? search,
    String? status,
    String? saleType,
  }) => {
    if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
    if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
    if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    if (status != null && status.isNotEmpty) 'status': status,
    if (saleType != null && saleType.isNotEmpty) 'sale_type': saleType,
  };

  @override
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
  }) async {
    final query = <String, dynamic>{
      'report_type': type.wireValue,
      'network_id': networkId,
      if (posId != null) 'pos_id': posId,
      'per_page': perPage,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      ..._filters(
        fromDate: fromDate,
        toDate: toDate,
        search: search,
        status: status,
        saleType: saleType,
      ),
    };
    final response = await remoteDataSource.getReport(query: query);
    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تحميل بيانات التقرير.',
        code: 'OPERATIONAL_REPORT_LOAD_FAILED',
        details: response.errors,
      );
    }

    return PaginatedList<OperationalReportRecord>(
      items: response.data!
          .map(OperationalReportRecordModel.new)
          .toList(growable: false),
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
      perPage: perPage,
    );
  }

  @override
  Future<OperationalReportSummary> getSummary({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    String? fromDate,
    String? toDate,
    String? search,
    String? status,
    String? saleType,
  }) async {
    final query = <String, dynamic>{
      'report_type': type.wireValue,
      'network_id': networkId,
      if (posId != null) 'pos_id': posId,
      ..._filters(
        fromDate: fromDate,
        toDate: toDate,
        search: search,
        status: status,
        saleType: saleType,
      ),
    };
    final response = await remoteDataSource.getSummary(query: query);
    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تحميل ملخص التقرير.',
        code: 'OPERATIONAL_REPORT_SUMMARY_FAILED',
        details: response.errors,
      );
    }
    return response.data!;
  }

  @override
  Future<bool> saveSummaryPdf({
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
  }) async {
    final result = await OperationalReportDocumentService.instance
        .exportAndSaveSummary(
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
    if (!result.isSuccess) {
      throw AppException(
        result.errorMessage ?? 'تعذر حفظ ملخص التقرير بصيغة PDF.',
        code: 'OPERATIONAL_REPORT_PDF_SAVE_FAILED',
      );
    }
    return true;
  }

  @override
  Future<bool> shareSummaryPdf({
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
  }) {
    return OperationalReportDocumentService.instance.shareSummary(
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

  @override
  Future<bool> printSummaryPdf({
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
  }) {
    return OperationalReportDocumentService.instance.printSummary(
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

  @override
  Future<OperationalReportExport> requestExport({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    String? fromDate,
    String? toDate,
    String? search,
    String? status,
    String? saleType,
  }) async {
    final response = await remoteDataSource.requestExport(
      payload: {
        'report_type': type.wireValue,
        'network_id': networkId,
        if (posId != null) 'pos_id': posId,
        ..._filters(
          fromDate: fromDate,
          toDate: toDate,
          search: search,
          status: status,
          saleType: saleType,
        ),
      },
    );
    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر إرسال طلب تصدير التقرير.',
        code: 'OPERATIONAL_REPORT_EXPORT_REQUEST_FAILED',
        details: response.errors,
      );
    }
    return response.data!;
  }

  @override
  Future<OperationalReportExport> getExportStatus(String exportId) async {
    final response = await remoteDataSource.getExportStatus(exportId);
    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب حالة التصدير.',
        code: 'OPERATIONAL_REPORT_EXPORT_STATUS_FAILED',
        details: response.errors,
      );
    }
    return response.data!;
  }

  @override
  Future<Uint8List?> downloadExport(String url) {
    return remoteDataSource.downloadExport(url);
  }
}
