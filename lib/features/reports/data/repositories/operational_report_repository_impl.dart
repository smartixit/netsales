import 'package:netsales/features/reports/domain/entities/operational_report_filter_display.dart';
import 'dart:typed_data';

import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/reports/data/datasources/operational_report_remote_data_source.dart';
import 'package:netsales/features/reports/data/models/operational_report_record_model.dart';
import 'package:netsales/features/reports/data/models/operational_report_summary_model.dart';
import 'package:netsales/features/reports/data/services/operational_report_document_service.dart';
import 'package:netsales/features/reports/data/services/detailed_operational_report_document_service.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_export.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_catalog.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';
import 'package:netsales/features/reports/domain/repositories/operational_report_repository.dart';

class OperationalReportRepositoryImpl
    implements OperationalReportRepository {
  OperationalReportRepositoryImpl(this.remoteDataSource);

  final OperationalReportRemoteDataSource remoteDataSource;
  final Map<String, OperationalReportCatalog> _catalogCache =
      <String, OperationalReportCatalog>{};

  String _catalogKey(int networkId, int? posId) =>
      '$networkId:${posId ?? 'network'}';

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
    final catalog = response.data!;
    _catalogCache[_catalogKey(networkId, posId)] = catalog;
    return catalog;
  }

  Map<String, dynamic> _filters(ReportCriteria criteria) {
    final result = <String, dynamic>{};
    String dateValue(DateTime value) {
      final date = value.toLocal();
      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }
    for (final entry in criteria.filters.entries) {
      final value = entry.value;
      switch (value) {
        case ReportTextFilterValue():
          if (value.value.trim().isNotEmpty) result[entry.key] = value.value.trim();
        case ReportIntegerFilterValue():
          result[entry.key] = value.value;
        case ReportDecimalFilterValue():
          result[entry.key] = value.value;
        case ReportDateFilterValue():
          result[entry.key] = dateValue(value.value);
        case ReportDateRangeFilterValue():
          result[entry.key] = <String, Object?>{
            'from': value.start == null ? null : dateValue(value.start!),
            'to': value.end == null ? null : dateValue(value.end!),
          };
        case ReportBooleanFilterValue():
          result[entry.key] = value.value;
        case ReportChoiceFilterValue():
          result[entry.key] = value.value;
        case ReportChoicesFilterValue():
          result[entry.key] = value.values;
      }
    }
    return result;
  }

  @override
  Future<PaginatedList<OperationalReportRecord>> getReport({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    required ReportCriteria criteria,
    String? cursor,
    int perPage = 25,
  }) async {
    final filters = _filters(criteria);
    final query = <String, dynamic>{
      'report_type': type.wireValue,
      'network_id': networkId,
      if (posId != null) 'pos_id': posId,
      'per_page': perPage,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (filters.isNotEmpty) 'filters': filters,
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
    required ReportCriteria criteria,
  }) async {
    final filters = _filters(criteria);
    final query = <String, dynamic>{
      'report_type': type.wireValue,
      'network_id': networkId,
      if (posId != null) 'pos_id': posId,
      if (filters.isNotEmpty) 'filters': filters,
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
    final catalog = _catalogCache[_catalogKey(networkId, posId)] ??
        await getCatalog(networkId: networkId, posId: posId);
    final entry = catalog.entryFor(type);
    if (entry == null) {
      throw AppException(
        'تعريف التقرير غير موجود في كتالوج نطاق العمل الحالي.',
        code: 'OPERATIONAL_REPORT_DEFINITION_MISSING',
      );
    }

    return OperationalReportSummaryModel(
      response.data!,
      metricDefinitions: entry.definition.metricSlots,
      metricLabels: entry.metricLabels,
      chartSlots: entry.chartSlots,
      reportTitle: entry.label,
    );
  }

  @override
  Future<bool> saveSummaryPdf({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) async {
    final result = await OperationalReportDocumentService.instance
        .exportAndSaveSummary(
          type: type,
          pageProfileId: pageProfileId,
          summary: summary,
          organizationName: organizationName,
          logoUrl: logoUrl,
          activeFilters: activeFilters,
          scopeLabel: scopeLabel,
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
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) {
    return OperationalReportDocumentService.instance.shareSummary(
      type: type,
      pageProfileId: pageProfileId,
      summary: summary,
      organizationName: organizationName,
      logoUrl: logoUrl,
      activeFilters: activeFilters,
      scopeLabel: scopeLabel,
    );
  }

  @override
  Future<bool> printSummaryPdf({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) {
    return OperationalReportDocumentService.instance.printSummary(
      type: type,
      pageProfileId: pageProfileId,
      summary: summary,
      organizationName: organizationName,
      logoUrl: logoUrl,
      activeFilters: activeFilters,
      scopeLabel: scopeLabel,
    );
  }


  @override
  Future<bool> saveDetailedPdf({
    required OperationalReportType type,
    required OperationalReportCatalogEntry entry,
    required List<OperationalReportRecord> records,
    required ReportPresentationOptions presentation,
    required OperationalReportSummary summary,
    required String pageProfileId,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) async {
    final result = await DetailedOperationalReportDocumentService.instance.exportAndSave(
      type: type,
      entry: entry,
      records: records,
      presentation: presentation,
      summary: summary,
      pageProfileId: pageProfileId,
      organizationName: organizationName,
      logoUrl: logoUrl,
      activeFilters: activeFilters,
      scopeLabel: scopeLabel,
    );
    if (!result.isSuccess) {
      throw AppException(
        result.errorMessage ?? 'تعذر حفظ التقرير التفصيلي بصيغة PDF.',
        code: 'OPERATIONAL_REPORT_DETAILED_PDF_FAILED',
      );
    }
    return true;
  }

  @override
  Future<OperationalReportExport> requestExport({
    required OperationalReportType type,
    required int networkId,
    int? posId,
    required ReportCriteria criteria,
  }) async {
    final filters = _filters(criteria);
    final response = await remoteDataSource.requestExport(
      payload: {
        'report_type': type.wireValue,
        'network_id': networkId,
        if (posId != null) 'pos_id': posId,
        if (filters.isNotEmpty) 'filters': filters,
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


  Map<String, dynamic> _presetScope(OperationalReportType type, int networkId, int? posId) =>
      {'report_type': type.wireValue, 'network_id': networkId, if (posId != null) 'pos_id': posId};

  Map<String, dynamic> _presetPayload({
    required OperationalReportType type, required int networkId, int? posId,
    required String name, required int reportSchemaVersion,
    required ReportCriteria criteria, required ReportPresentationOptions presentation,
  }) => {
    ..._presetScope(type, networkId, posId), 'name': name.trim(),
    'report_schema_version': reportSchemaVersion, 'criteria': criteria.toJson(),
    'presentation': presentation.toJson(),
  };

  @override
  Future<List<SavedReportPreset>> getPresets({required OperationalReportType type, required int networkId, int? posId}) async {
    final response = await remoteDataSource.getPresets(query: _presetScope(type, networkId, posId));
    if (!response.success || response.data == null) {
      throw AppException(response.message.isNotEmpty ? response.message : 'تعذر تحميل الإعدادات المحفوظة.', code: 'OPERATIONAL_REPORT_PRESETS_LOAD_FAILED', details: response.errors);
    }
    return response.data!;
  }

  @override
  Future<SavedReportPreset> savePreset({required OperationalReportType type, required int networkId, int? posId, required String name, required int reportSchemaVersion, required ReportCriteria criteria, required ReportPresentationOptions presentation}) async {
    final response = await remoteDataSource.savePreset(payload: _presetPayload(type: type, networkId: networkId, posId: posId, name: name, reportSchemaVersion: reportSchemaVersion, criteria: criteria, presentation: presentation));
    if (!response.success || response.data == null) {
      throw AppException(response.message.isNotEmpty ? response.message : 'تعذر حفظ إعداد التقرير.', code: 'OPERATIONAL_REPORT_PRESET_SAVE_FAILED', details: response.errors);
    }
    return response.data!;
  }

  @override
  Future<SavedReportPreset> updatePreset({required String presetId, required OperationalReportType type, required int networkId, int? posId, required String name, required int reportSchemaVersion, required ReportCriteria criteria, required ReportPresentationOptions presentation}) async {
    final response = await remoteDataSource.updatePreset(presetId, payload: _presetPayload(type: type, networkId: networkId, posId: posId, name: name, reportSchemaVersion: reportSchemaVersion, criteria: criteria, presentation: presentation));
    if (!response.success || response.data == null) {
      throw AppException(response.message.isNotEmpty ? response.message : 'تعذر تحديث إعداد التقرير.', code: 'OPERATIONAL_REPORT_PRESET_UPDATE_FAILED', details: response.errors);
    }
    return response.data!;
  }

  @override
  Future<void> deletePreset({required String presetId, required OperationalReportType type, required int networkId, int? posId}) async {
    final response = await remoteDataSource.deletePreset(presetId, query: _presetScope(type, networkId, posId));
    if (!response.success) {
      throw AppException(response.message.isNotEmpty ? response.message : 'تعذر حذف إعداد التقرير.', code: 'OPERATIONAL_REPORT_PRESET_DELETE_FAILED', details: response.errors);
    }
  }

  @override
  Future<Uint8List?> downloadExport(String url) {
    return remoteDataSource.downloadExport(url);
  }
}
