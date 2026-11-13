import 'package:netsales/features/reports/domain/entities/operational_report_filter_display.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:document_engine/document_engine.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_export.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_catalog.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';
import 'package:netsales/features/reports/domain/usecases/operational_report_use_cases.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class OperationalReportsController extends GetxController {
  OperationalReportsController({
    required this.getReportCatalogUseCase,
    required this.getReportUseCase,
    required this.getSummaryUseCase,
    required this.requestExportUseCase,
    required this.getExportStatusUseCase,
    required this.downloadExportUseCase,
    required this.getNetworkPosListUseCase,
    required this.saveSummaryPdfUseCase,
    required this.shareSummaryPdfUseCase,
    required this.printSummaryPdfUseCase,
  });

  final GetOperationalReportCatalogUseCase getReportCatalogUseCase;
  final GetOperationalReportUseCase getReportUseCase;
  final Rxn<OperationalReportCatalog> catalog = Rxn<OperationalReportCatalog>();
  final Rx<ReportCriteria> criteria = ReportCriteria().obs;
  final Rx<ReportPresentationOptions> presentation = ReportPresentationOptions().obs;
  final GetOperationalReportSummaryUseCase getSummaryUseCase;
  final RequestOperationalReportExportUseCase requestExportUseCase;
  final GetOperationalReportExportStatusUseCase getExportStatusUseCase;
  final DownloadOperationalReportExportUseCase downloadExportUseCase;
  final GetNetworkPosListUseCase getNetworkPosListUseCase;
  final SaveOperationalReportSummaryPdfUseCase saveSummaryPdfUseCase;
  final ShareOperationalReportSummaryPdfUseCase shareSummaryPdfUseCase;
  final PrintOperationalReportSummaryPdfUseCase printSummaryPdfUseCase;

  final reports = <OperationalReportRecord>[].obs;
  final Rxn<OperationalReportSummary> summary = Rxn<OperationalReportSummary>();
  final RxnString summaryError = RxnString();
  final selectedType = Rxn<OperationalReportType>();
  final selectedPosId = RxnInt();
  final posOptions = <NetworkPosLinkEntity>[].obs;
  final nextCursor = RxnString();
  final posCursor = RxnString();

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isLoadingPos = false.obs;
  final isLoadingMorePos = false.obs;
  final isExportActionRunning = false.obs;
  final isCheckingExport = false.obs;
  final isPdfActionRunning = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final posError = RxnString();
  final exportJob = Rxn<OperationalReportExport>();

  Timer? _criteriaDebounce;
  final Map<String, TextEditingController> _criteriaTextControllers = {};
  final Map<String, RxnString> _choiceValues = {};
  int _requestRevision = 0;
  int _posRevision = 0;
  final Set<String> _seenReportCursors = <String>{};
  String _posSearchQuery = '';
  int? _networkId;
  int? _workspacePosId;
  bool _isNetworkWorkspace = true;
  bool _scopeConfigured = false;
  String? _organizationName;
  String? _logoUrl;

  bool get hasMore => nextCursor.value?.trim().isNotEmpty ?? false;
  bool get hasMorePos => posCursor.value?.trim().isNotEmpty ?? false;
  bool get hasNetworkScope => _networkId != null;
  bool get hasPosScope => _workspacePosId != null;

  String get reportOrganizationName {
    final value = _organizationName?.trim();
    return value == null || value.isEmpty ? 'NetSales' : value;
  }

  String? get reportLogoUrl => _logoUrl;

  String get reportCurrencyCode =>
      summary.value?.values['currency_code']?.toString() ?? '';

  String get reportScopeLabel {
    if (!_isNetworkWorkspace) return 'نقطة البيع الحالية';
    if (selectedReportEntry?.access.posSelection == 'forbidden') {
      return 'نطاق الشبكة بالكامل';
    }
    final posId = selectedPosId.value;
    if (posId == null) return 'جميع نقاط البيع';
    final link = posOptions.firstWhereOrNull((item) => item.posId == posId);
    return link?.pos?.posName ?? 'نقطة بيع #' + posId.toString();
  }

  List<OperationalReportType> get availableTypes =>
      catalog.value?.availableTypes ?? const <OperationalReportType>[];

  OperationalReportCatalogEntry? get selectedReportEntry {
    final type = selectedType.value;
    return type == null ? null : catalog.value?.entryFor(type);
  }

  String? get selectedPageProfileId {
    final pageProfileIds = selectedReportEntry?.definition.pageProfileIds;
    if (pageProfileIds == null || pageProfileIds.isEmpty) return null;
    final selected = presentation.value.pageProfileId;
    return selected != null && pageProfileIds.contains(selected)
        ? selected
        : pageProfileIds.first;
  }

  String reportLabel(OperationalReportType type) =>
      catalog.value?.entryFor(type)?.label ?? type.wireValue;

  List<OperationalReportFilterDisplay> get activeFilterDisplays {
    final entry = selectedReportEntry;
    if (entry == null) return const [];
    return entry.definition.filters
        .where((filter) => criteria.value.filters.containsKey(filter.id))
        .map((filter) {
          final value = criteria.value.filters[filter.id]!;
          final displayValue = switch (value) {
            ReportTextFilterValue() => value.value,
            ReportIntegerFilterValue() => value.value.toString(),
            ReportDecimalFilterValue() => value.value,
            ReportDateFilterValue() => _dateText(value.value),
            ReportDateRangeFilterValue() =>
              '${value.start == null ? '—' : _dateText(value.start!)} — ${value.end == null ? '—' : _dateText(value.end!)}',
            ReportBooleanFilterValue() => value.value ? 'نعم' : 'لا',
            ReportChoiceFilterValue() =>
              entry.choiceLabels[filter.id]?[value.value] ?? value.value,
            ReportChoicesFilterValue() => value.values
                .map((choice) => entry.choiceLabels[filter.id]?[choice] ?? choice)
                .join('، '),
          };
          return OperationalReportFilterDisplay(
            id: filter.id,
            label: entry.filterLabels[filter.labelKey] ?? filter.id,
            value: displayValue,
          );
        }).toList(growable: false);
  }

  TextEditingController textControllerFor(ReportFilterDefinition filter) {
    return _criteriaTextControllers.putIfAbsent(filter.id, () {
      final value = criteria.value.filters[filter.id];
      final initial = switch (value) {
        ReportTextFilterValue() => value.value,
        ReportIntegerFilterValue() => value.value.toString(),
        ReportDecimalFilterValue() => value.value,
        ReportDateFilterValue() => _dateText(value.value),
        _ => '',
      };
      return TextEditingController(text: initial);
    });
  }

  RxnString choiceValueFor(String filterId) {
    return _choiceValues.putIfAbsent(filterId, () {
      final value = criteria.value.filters[filterId];
      return RxnString(
        value is ReportChoiceFilterValue ? value.value : null,
      );
    });
  }

  void setFilterValue(String filterId, ReportFilterValue? value) {
    final filters = Map<String, ReportFilterValue>.of(criteria.value.filters);
    if (value == null) {
      filters.remove(filterId);
    } else {
      filters[filterId] = value;
    }
    updateCriteria(ReportCriteria(filters: filters));
  }

  void updateCriteria(ReportCriteria value) {
    final definition = selectedReportEntry?.definition;
    if (definition == null) return;

    final issues = value.validateAgainst(definition);
    criteria.value = value;
    for (final entry in _choiceValues.entries) {
      final selected = value.filters[entry.key];
      entry.value.value = selected is ReportChoiceFilterValue
          ? selected.value
          : null;
    }
    summary.value = null;
    summaryError.value = null;
    reports.clear();
    nextCursor.value = null;
    ++_requestRevision;
    isLoading.value = false;
    isLoadingMore.value = false;

    _criteriaDebounce?.cancel();
    if (issues.isNotEmpty) return;

    _criteriaDebounce = Timer(const Duration(milliseconds: 350), () {
      loadReport(refresh: true);
    });
  }

  void updatePresentation(ReportPresentationOptions value) {
    final definition = selectedReportEntry?.definition;
    if (definition == null || value.validateAgainst(definition).isNotEmpty) {
      return;
    }
    presentation.value = value;
  }

  ReportCriteria _effectiveCriteria() => criteria.value;

  String? _textCriteria(String id) {
    final value = criteria.value.filters[id];
    if (value is ReportTextFilterValue) return value.value;
    return null;
  }

  String? _choiceCriteria(String id) {
    final value = criteria.value.filters[id];
    if (value is ReportChoiceFilterValue) return value.value;
    return null;
  }

  String? _dateCriteria(String id) {
    final value = criteria.value.filters[id];
    if (value is! ReportDateFilterValue) return null;
    return _dateText(value.value);
  }

  String _dateText(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadReportCatalog() async {
    final networkId = _networkId;
    if (networkId == null) {
      catalog.value = null;
      return;
    }
    try {
      catalog.value = await getReportCatalogUseCase(
        networkId: networkId,
        posId: _isNetworkWorkspace ? null : _workspacePosId,
      );
    } catch (_) {
      catalog.value = null;
      rethrow;
    }
  }

  bool get canExport {
    final type = selectedType.value;
    final exportPermission = selectedReportEntry?.access.exportPermission;
    return type != null &&
        selectedReportEntry?.access.available == true &&
        exportPermission != null &&
        PermissionService.to.can(exportPermission);
  }

  bool get requiresPosSelection =>
      selectedReportEntry?.access.posSelection == 'required' &&
      _isNetworkWorkspace &&
      selectedPosId.value == null;

  int? get _queryPosId {
    if (selectedReportEntry?.access.posSelection == 'forbidden') {
      return null;
    }
    return _isNetworkWorkspace ? selectedPosId.value : _workspacePosId;
  }

  bool needsScope({
    required int? networkId,
    required int? posId,
    required bool isNetworkWorkspace,
    String? organizationName,
    String? logoUrl,
  }) =>
      !_scopeConfigured ||
      _networkId != networkId ||
      _workspacePosId != posId ||
      _isNetworkWorkspace != isNetworkWorkspace ||
      _organizationName != organizationName ||
      _logoUrl != logoUrl;

  Future<void> configureScope({
    required int? networkId,
    required int? posId,
    required bool isNetworkWorkspace,
    String? organizationName,
    String? logoUrl,
  }) async {
    if (!needsScope(
      networkId: networkId,
      posId: posId,
      isNetworkWorkspace: isNetworkWorkspace,
      organizationName: organizationName,
      logoUrl: logoUrl,
    )) {
      return;
    }

    _scopeConfigured = true;
    _networkId = networkId;
    _workspacePosId = posId;
    _isNetworkWorkspace = isNetworkWorkspace;
    _organizationName = organizationName;
    _logoUrl = logoUrl;
    _criteriaDebounce?.cancel();
    _criteriaDebounce = null;
    ++_requestRevision;
    ++_posRevision;
    isLoadingPos.value = false;
    isLoadingMorePos.value = false;
    reports.clear();
    summary.value = null;
    summaryError.value = null;
    nextCursor.value = null;
    errorMessage.value = null;
    loadMoreError.value = null;
    criteria.value = ReportCriteria();
    for (final selection in _choiceValues.values) {
      selection.value = null;
    }
    presentation.value = ReportPresentationOptions();
    for (final controller in _criteriaTextControllers.values) {
      controller.clear();
    }
    exportJob.value = null;
    _seenReportCursors.clear();

    _posSearchQuery = '';
    if (!isNetworkWorkspace) {
      selectedPosId.value = posId;
      posOptions.clear();
      posCursor.value = null;
      posError.value = null;
    } else {
      selectedPosId.value = null;
      if (networkId != null) {
        unawaited(loadPosOptions(refresh: true));
      } else {
        posOptions.clear();
      }
    }

    try {
      await _loadReportCatalog();
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      isLoading.value = false;
      return;
    }

    final types = availableTypes;
    if (types.isEmpty) {
      selectedType.value = null;
      isLoading.value = false;
      return;
    }
    if (!types.contains(selectedType.value)) {
      selectedType.value = types.first;
    }
    await loadReport(refresh: true);
  }

  @override
  void onClose() {
    _criteriaDebounce?.cancel();
    for (final controller in _criteriaTextControllers.values) {
      controller.dispose();
    }
    _criteriaTextControllers.clear();
    _choiceValues.clear();
    ++_requestRevision;
    ++_posRevision;
    super.onClose();
  }

  Future<void> selectType(OperationalReportType type) async {
    if (!availableTypes.contains(type) || selectedType.value == type) return;
    selectedType.value = type;
    _criteriaDebounce?.cancel();
    criteria.value = ReportCriteria();
    for (final selection in _choiceValues.values) {
      selection.value = null;
    }
    presentation.value = ReportPresentationOptions();
    for (final controller in _criteriaTextControllers.values) {
      controller.clear();
    }
    exportJob.value = null;
    await loadReport(refresh: true);
  }

  Future<void> selectPos(int? posId) async {
    if (selectedPosId.value == posId) return;
    selectedPosId.value = posId;
    await loadReport(refresh: true);
  }

  Future<void> clearFilters() async {
    _criteriaDebounce?.cancel();
    criteria.value = ReportCriteria();
    for (final controller in _criteriaTextControllers.values) {
      controller.clear();
    }
    if (_isNetworkWorkspace) {
      selectedPosId.value = null;
      _posSearchQuery = '';
      unawaited(loadPosOptions(refresh: true, search: ''));
    }
    await loadReport(refresh: true);
  }

  Future<void> searchPosOptions(String query) async {
    final normalized = query.trim();
    if (normalized == _posSearchQuery && posOptions.isNotEmpty) return;
    await loadPosOptions(refresh: true, search: normalized);
  }

  Future<void> loadPosOptions({
    bool refresh = false,
    String? search,
  }) async {
    final networkId = _networkId;
    if (!_isNetworkWorkspace || networkId == null) return;
    if (!refresh &&
        (isLoadingPos.value || isLoadingMorePos.value || !hasMorePos)) {
      return;
    }

    if (refresh) {
      _posSearchQuery = search?.trim() ?? '';
    }
    final revision = ++_posRevision;
    if (refresh) {
      isLoadingPos.value = true;
      isLoadingMorePos.value = false;
      posError.value = null;
      posOptions.clear();
      posCursor.value = null;
    } else {
      isLoadingMorePos.value = true;
      posError.value = null;
    }

    try {
      final result = await getNetworkPosListUseCase(
        networkId,
        cursor: refresh ? null : posCursor.value,
        status: true,
        search: _posSearchQuery.isEmpty ? null : _posSearchQuery,
        perPage: 50,
      );
      if (revision != _posRevision || networkId != _networkId) return;
      final known = posOptions.map((item) => item.posId).toSet();
      posOptions.addAll(
        result.items.where((item) => item.posId > 0 && known.add(item.posId)),
      );
      posCursor.value = result.nextCursor;
      if (selectedPosId.value != null &&
          !posOptions.any((item) => item.posId == selectedPosId.value)) {
        selectedPosId.value = null;
      }
    } catch (error) {
      if (revision == _posRevision) {
        posError.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل نقاط البيع المرتبطة بالشبكة.',
        );
      }
    } finally {
      if (revision == _posRevision) {
        isLoadingPos.value = false;
        isLoadingMorePos.value = false;
      }
    }
  }

  String _reportRecordIdentity(
    OperationalReportRecord record,
    OperationalReportType type,
  ) {
    final identity = switch (type) {
      OperationalReportType.sales ||
      OperationalReportType.debtAging =>
        record.textAt('invoice_id', fallback: record.textAt('invoice_uuid', fallback: '')),
      OperationalReportType.expenses =>
        record.textAt('expense_id', fallback: record.textAt('expense_uuid', fallback: '')),
      OperationalReportType.networkWallet ||
      OperationalReportType.posWallet => record.textAt('log_id', fallback: ''),
      OperationalReportType.repayments =>
        record.textAt('repayment_id', fallback: record.textAt('repayment_uuid', fallback: '')),
      OperationalReportType.requests =>
        record.textAt('request_id', fallback: record.textAt('request_uuid', fallback: '')),
      _ => record.textAt(
        'id',
        fallback: record.textAt(
          'uuid',
          fallback: record.textAt('reference', fallback: ''),
        ),
      ),
    };

    return identity.isEmpty ? record.values.toString() : identity;
  }

  Future<void> loadReport({bool refresh = false}) async {
    if (refresh) {
      _criteriaDebounce?.cancel();
      _criteriaDebounce = null;
      summary.value = null;
      summaryError.value = null;
    }
    final networkId = _networkId;
    final type = selectedType.value;
    if (networkId == null || type == null) {
      reports.clear();
      nextCursor.value = null;
      isLoading.value = false;
      isLoadingMore.value = false;
      return;
    }
    if (!_isNetworkWorkspace && _workspacePosId == null) {
      reports.clear();
      nextCursor.value = null;
      isLoading.value = false;
      isLoadingMore.value = false;
      errorMessage.value = 'حدد نقطة البيع النشطة أولاً لعرض تقاريرها.';
      return;
    }
    if (requiresPosSelection) {
      reports.clear();
      nextCursor.value = null;
      isLoading.value = false;
      isLoadingMore.value = false;
      errorMessage.value = 'حدد نقطة بيع لعرض كشف حساب محفظتها.';
      return;
    }
    final viewPermission = selectedReportEntry?.access.viewPermission;
    if (selectedReportEntry?.access.available != true ||
        viewPermission == null ||
        !PermissionService.to.can(viewPermission)) {
      reports.clear();
      nextCursor.value = null;
      isLoading.value = false;
      isLoadingMore.value = false;
      errorMessage.value = 'لا تملك صلاحية عرض هذا التقرير.';
      return;
    }
    if (!refresh &&
        (isLoading.value || isLoadingMore.value || !hasMore)) {
      return;
    }

    final revision = ++_requestRevision;
    final requestedPosId = _queryPosId;
    final requestedCursor = refresh ? null : nextCursor.value;
    if (refresh) {
      isLoading.value = true;
      isLoadingMore.value = false;
      errorMessage.value = null;
      loadMoreError.value = null;
      _seenReportCursors.clear();
      nextCursor.value = null;
    } else {
      if (requestedCursor == null || !_seenReportCursors.add(requestedCursor)) {
        loadMoreError.value = 'توقف تحميل التقرير بسبب تكرار مؤشر الصفحة.';
        return;
      }
      isLoadingMore.value = true;
      loadMoreError.value = null;
    }

    try {
      final PaginatedList<OperationalReportRecord> page =
          await getReportUseCase(
        type: type,
        networkId: networkId,
        posId: requestedPosId,
        criteria: _effectiveCriteria(),
        cursor: requestedCursor,
      );
      if (revision != _requestRevision ||
          networkId != _networkId ||
          type != selectedType.value ||
          requestedPosId != _queryPosId) {
        return;
      }

      if (page.nextCursor != null &&
          (page.nextCursor == requestedCursor ||
              _seenReportCursors.contains(page.nextCursor))) {
        throw const AppException(
          'توقف تحميل التقرير لأن الخادم أعاد مؤشر صفحة سبق استخدامه.',
        );
      }

      final seenRecords = reports
          .map((record) => _reportRecordIdentity(record, type))
          .toSet();
      final uniquePageItems = page.items.where(
        (record) => seenRecords.add(_reportRecordIdentity(record, type)),
      );

      if (refresh) {
        reports.assignAll(uniquePageItems);
      } else {
        reports.addAll(uniquePageItems);
      }
      nextCursor.value = page.nextCursor;
      errorMessage.value = null;

      if (refresh) {
        try {
          final reportSummary = await getSummaryUseCase(
            type: type,
            networkId: networkId,
            posId: requestedPosId,
            criteria: _effectiveCriteria(),
          );
          if (revision == _requestRevision) {
            summary.value = reportSummary;
            summaryError.value = null;
          }
        } catch (summaryFailure) {
          if (revision == _requestRevision) {
            summary.value = null;
            summaryError.value = AppException.sanitizeMessage(
              summaryFailure,
              fallback: 'تعذر تحميل إجماليات التقرير.',
            );
          }
        }
      }
    } catch (error) {
      if (revision != _requestRevision) return;
      if (!refresh && requestedCursor != null) {
        _seenReportCursors.remove(requestedCursor);
      }
      final message = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل سجلات التقرير.',
      );
      if (refresh) {
        errorMessage.value = message;
      } else {
        loadMoreError.value = message;
      }
    } finally {
      if (revision == _requestRevision) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> requestExport() async {
    final type = selectedType.value;
    final networkId = _networkId;
    if (type == null ||
        networkId == null ||
        isExportActionRunning.value ||
        !canExport) {
      return;
    }
    if (requiresPosSelection) {
      CustomSnackbar.show(
        title: 'نقطة البيع مطلوبة',
        message: 'حدد نقطة بيع قبل تصدير كشف محفظتها.',
        type: SnackType.warning,
      );
      return;
    }

    isExportActionRunning.value = true;
    try {
      final result = await requestExportUseCase(
        type: type,
        networkId: networkId,
        posId: _queryPosId,
        criteria: _effectiveCriteria(),
      );
      exportJob.value = result;
      CustomSnackbar.show(
        title: 'تم استلام طلب التصدير',
        message: 'أُرسل التقرير إلى المعالجة. حدّث الحالة عند اكتمال التجهيز.',
        type: SnackType.success,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'تعذر طلب التصدير',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'تعذر إرسال طلب تجهيز التقرير.',
        ),
        type: SnackType.error,
      );
    } finally {
      isExportActionRunning.value = false;
    }
  }

  Future<void> exportSummaryPdf() async {
    final type = selectedType.value;
    final data = summary.value;
    final pageProfileId = selectedPageProfileId;
    if (type == null ||
        data == null ||
        pageProfileId == null ||
        isPdfActionRunning.value ||
        !canExport) {
      return;
    }

    isPdfActionRunning.value = true;
    try {
      await saveSummaryPdfUseCase(
        type: type,
        pageProfileId: pageProfileId,
        summary: data,
        organizationName: reportOrganizationName,
        logoUrl: reportLogoUrl,
        activeFilters: activeFilterDisplays,
        scopeLabel: reportScopeLabel,
      );
      CustomSnackbar.show(
        title: 'تم إنشاء ملخص PDF',
        message: 'حُفظ الملخص التنفيذي في مجلد Reports.',
        type: SnackType.success,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'تعذر إنشاء ملخص PDF',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'تعذر إنشاء مستند ملخص التقرير.',
        ),
        type: SnackType.error,
      );
    } finally {
      isPdfActionRunning.value = false;
    }
  }

  Future<void> shareSummaryPdf() async {
    final type = selectedType.value;
    final data = summary.value;
    final pageProfileId = selectedPageProfileId;
    if (type == null ||
        data == null ||
        pageProfileId == null ||
        isPdfActionRunning.value ||
        !canExport) {
      return;
    }

    isPdfActionRunning.value = true;
    try {
      final shared = await shareSummaryPdfUseCase(
        type: type,
        pageProfileId: pageProfileId,
        summary: data,
        organizationName: reportOrganizationName,
        logoUrl: reportLogoUrl,
        activeFilters: activeFilterDisplays,
        scopeLabel: reportScopeLabel,
      );
      if (shared) {
        CustomSnackbar.show(
          title: 'تم تجهيز المستند للمشاركة',
          message: 'تم إنشاء ملخص PDF وفتح نافذة المشاركة.',
          type: SnackType.success,
        );
      }
    } catch (error) {
      CustomSnackbar.show(
        title: 'تعذرت مشاركة الملخص',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'تعذر إنشاء أو مشاركة مستند التقرير.',
        ),
        type: SnackType.error,
      );
    } finally {
      isPdfActionRunning.value = false;
    }
  }

  Future<void> printSummaryPdf() async {
    final type = selectedType.value;
    final data = summary.value;
    final pageProfileId = selectedPageProfileId;
    if (type == null ||
        data == null ||
        pageProfileId == null ||
        isPdfActionRunning.value ||
        !canExport) {
      return;
    }

    isPdfActionRunning.value = true;
    try {
      final printed = await printSummaryPdfUseCase(
        type: type,
        pageProfileId: pageProfileId,
        summary: data,
        organizationName: reportOrganizationName,
        logoUrl: reportLogoUrl,
        activeFilters: activeFilterDisplays,
        scopeLabel: reportScopeLabel,
      );
      if (printed) {
        CustomSnackbar.show(
          title: 'تم فتح نافذة الطباعة',
          message: 'أُرسل ملخص التقرير إلى خدمة الطباعة.',
          type: SnackType.success,
        );
      }
    } catch (error) {
      CustomSnackbar.show(
        title: 'تعذرت طباعة الملخص',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'تعذر إنشاء مستند التقرير للطباعة.',
        ),
        type: SnackType.error,
      );
    } finally {
      isPdfActionRunning.value = false;
    }
  }

  Future<void> refreshExportStatus() async {
    final job = exportJob.value;
    if (job == null || isCheckingExport.value) return;
    isCheckingExport.value = true;
    try {
      final status = await getExportStatusUseCase(job.exportId);
      exportJob.value = status;
      if (status.isReady) {
        // Never pass a server-supplied absolute URL to the authenticated
        // Dio client. Build the download path from the trusted API route and
        // the opaque export identifier returned by this API.
        final url = ApiConstants.operationalReportExportDownload(
          status.exportId,
        );
        final bytes = await downloadExportUseCase(url);
        if (bytes == null || bytes.isEmpty) {
          throw const AppException('التصدير جاهز لكن تعذر تنزيل الملف.');
        }
        final type = selectedType.value;
        final fileName = 'تقرير_' +
            (type?.wireValue ?? 'تشغيلي') +
            '_' +
            DateTime.now().millisecondsSinceEpoch.toString();
        final result = await FileExportService.instance.saveFile(
          bytes: bytes,
          fileName: fileName,
          extension: 'csv',
          folderName: 'Reports',
          namingStrategy: FileNamingStrategy.report,
          autoOpen: false,
          showFeedback: false,
        );
        if (!result.isSuccess) {
          throw AppException(
            result.errorMessage ?? 'تعذر حفظ ملف التقرير.',
          );
        }
        CustomSnackbar.show(
          title: 'اكتمل تصدير التقرير',
          message: 'تم تنزيل ملف CSV إلى مجلد Reports.',
          type: SnackType.success,
        );
      } else if (status.isFailed) {
        CustomSnackbar.show(
          title: 'فشل تجهيز التقرير',
          message: status.failureCode ?? status.statusLabel ?? 'تعذر إنشاء الملف.',
          type: SnackType.error,
        );
      } else {
        CustomSnackbar.show(
          title: 'التقرير قيد التجهيز',
          message: status.statusLabel ?? 'لم يكتمل تجهيز الملف بعد.',
          type: SnackType.info,
        );
      }
    } catch (error) {
      CustomSnackbar.show(
        title: 'تعذر تحديث حالة التصدير',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'تعذر التحقق من حالة ملف التقرير.',
        ),
        type: SnackType.error,
      );
    } finally {
      isCheckingExport.value = false;
    }
  }
}
