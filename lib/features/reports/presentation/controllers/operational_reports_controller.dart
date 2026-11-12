import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_export.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';
import 'package:netsales/features/reports/domain/usecases/operational_report_use_cases.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class OperationalReportsController extends GetxController {
  OperationalReportsController({
    required this.getReportUseCase,
    required this.getSummaryUseCase,
    required this.requestExportUseCase,
    required this.getExportStatusUseCase,
    required this.downloadExportUseCase,
    required this.getNetworkPosListUseCase,
  });

  final GetOperationalReportUseCase getReportUseCase;
  final GetOperationalReportSummaryUseCase getSummaryUseCase;
  final RequestOperationalReportExportUseCase requestExportUseCase;
  final GetOperationalReportExportStatusUseCase getExportStatusUseCase;
  final DownloadOperationalReportExportUseCase downloadExportUseCase;
  final GetNetworkPosListUseCase getNetworkPosListUseCase;

  final reports = <OperationalReportRecord>[].obs;
  final Rxn<OperationalReportSummary> summary = Rxn<OperationalReportSummary>();
  final RxnString summaryError = RxnString();
  final selectedType = Rxn<OperationalReportType>();
  final selectedStatus = RxnString();
  final selectedSaleType = RxnString();
  final selectedPosId = RxnInt();
  final posOptions = <NetworkPosLinkEntity>[].obs;
  final nextCursor = RxnString();
  final posCursor = RxnString();
  final fromDate = RxnString();
  final toDate = RxnString();
  final searchTextController = TextEditingController();

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isLoadingPos = false.obs;
  final isLoadingMorePos = false.obs;
  final isExportActionRunning = false.obs;
  final isCheckingExport = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final posError = RxnString();
  final exportJob = Rxn<OperationalReportExport>();

  Timer? _searchDebounce;
  int _requestRevision = 0;
  int _posRevision = 0;
  int? _networkId;
  int? _workspacePosId;
  bool _isNetworkWorkspace = true;
  bool _scopeConfigured = false;

  bool get hasMore => nextCursor.value?.trim().isNotEmpty ?? false;
  bool get hasMorePos => posCursor.value?.trim().isNotEmpty ?? false;
  bool get hasNetworkScope => _networkId != null;
  bool get hasPosScope => _workspacePosId != null;

  List<OperationalReportType> get availableTypes {
    return OperationalReportType.values.where((type) {
      if (!_isNetworkWorkspace && !type.availableForPos) return false;
      return PermissionService.to.can(type.requiredPermission);
    }).toList(growable: false);
  }

  bool get canExport {
    final type = selectedType.value;
    return type != null && PermissionService.to.can(type.exportPermission);
  }

  bool get requiresPosSelection =>
      selectedType.value == OperationalReportType.posWallet &&
      _isNetworkWorkspace &&
      selectedPosId.value == null;

  int? get _queryPosId {
    final type = selectedType.value;
    if (type == OperationalReportType.expenses ||
        type == OperationalReportType.networkWallet) {
      return null;
    }
    return _isNetworkWorkspace ? selectedPosId.value : _workspacePosId;
  }

  bool needsScope({
    required int? networkId,
    required int? posId,
    required bool isNetworkWorkspace,
  }) =>
      !_scopeConfigured ||
      _networkId != networkId ||
      _workspacePosId != posId ||
      _isNetworkWorkspace != isNetworkWorkspace;

  Future<void> configureScope({
    required int? networkId,
    required int? posId,
    required bool isNetworkWorkspace,
  }) async {
    if (!needsScope(
      networkId: networkId,
      posId: posId,
      isNetworkWorkspace: isNetworkWorkspace,
    )) {
      return;
    }

    _scopeConfigured = true;
    _networkId = networkId;
    _workspacePosId = posId;
    _isNetworkWorkspace = isNetworkWorkspace;
    ++_requestRevision;
    reports.clear();
    summary.value = null;
    summaryError.value = null;
    nextCursor.value = null;
    errorMessage.value = null;
    loadMoreError.value = null;
    selectedStatus.value = null;
    selectedSaleType.value = null;
    exportJob.value = null;

    if (!isNetworkWorkspace) {
      selectedPosId.value = posId;
      posOptions.clear();
      posCursor.value = null;
      posError.value = null;
    } else {
      selectedPosId.value = null;
      if (networkId != null) {
        await loadPosOptions(refresh: true);
      } else {
        posOptions.clear();
      }
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
    _searchDebounce?.cancel();
    searchTextController.dispose();
    ++_requestRevision;
    ++_posRevision;
    super.onClose();
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      loadReport(refresh: true);
    });
  }

  Future<void> selectType(OperationalReportType type) async {
    if (!availableTypes.contains(type) || selectedType.value == type) return;
    selectedType.value = type;
    selectedStatus.value = null;
    selectedSaleType.value = null;
    exportJob.value = null;
    await loadReport(refresh: true);
  }

  Future<void> selectPos(int? posId) async {
    if (selectedPosId.value == posId) return;
    selectedPosId.value = posId;
    await loadReport(refresh: true);
  }

  Future<void> selectStatus(String? value) async {
    selectedStatus.value = value;
    await loadReport(refresh: true);
  }

  Future<void> selectSaleType(String? value) async {
    selectedSaleType.value = value;
    await loadReport(refresh: true);
  }

  Future<void> selectDate({required bool isFrom}) async {
    final current = DateTime.tryParse(
      isFrom ? fromDate.value ?? '' : toDate.value ?? '',
    );
    final now = DateTime.now();
    final initial = current ?? (isFrom ? DateTime(now.year, now.month, 1) : now);
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: initial,
      firstDate: DateTime(2010),
      lastDate: DateTime(now.year + 2),
      helpText: isFrom ? 'تاريخ بداية التقرير' : 'تاريخ نهاية التقرير',
    );
    if (picked == null) return;
    final value = DateFormatter.iso(picked);
    if (isFrom) {
      fromDate.value = value;
      if (toDate.value != null && toDate.value!.compareTo(value) < 0) {
        toDate.value = value;
      }
    } else {
      toDate.value = value;
      if (fromDate.value != null && fromDate.value!.compareTo(value) > 0) {
        fromDate.value = value;
      }
    }
    await loadReport(refresh: true);
  }

  Future<void> clearFilters() async {
    _searchDebounce?.cancel();
    searchTextController.clear();
    fromDate.value = null;
    toDate.value = null;
    selectedStatus.value = null;
    selectedSaleType.value = null;
    await loadReport(refresh: true);
  }

  Future<void> loadPosOptions({bool refresh = false}) async {
    final networkId = _networkId;
    if (!_isNetworkWorkspace || networkId == null) return;
    if (!refresh &&
        (isLoadingPos.value || isLoadingMorePos.value || !hasMorePos)) {
      return;
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
        perPage: 100,
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

  Future<void> loadReport({bool refresh = false}) async {
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
      errorMessage.value = 'حدد نقطة البيع النشطة أولاً لعرض تقاريرها.';
      return;
    }
    if (requiresPosSelection) {
      reports.clear();
      nextCursor.value = null;
      errorMessage.value = 'حدد نقطة بيع لعرض كشف حساب محفظتها.';
      return;
    }
    if (!PermissionService.to.can(type.requiredPermission)) {
      reports.clear();
      errorMessage.value = 'لا تملك صلاحية عرض هذا التقرير.';
      return;
    }
    if (!refresh &&
        (isLoading.value || isLoadingMore.value || !hasMore)) {
      return;
    }

    final revision = ++_requestRevision;
    final requestedPosId = _queryPosId;
    if (refresh) {
      isLoading.value = true;
      isLoadingMore.value = false;
      errorMessage.value = null;
      summary.value = null;
      summaryError.value = null;
      loadMoreError.value = null;
      nextCursor.value = null;
    } else {
      isLoadingMore.value = true;
      loadMoreError.value = null;
    }

    try {
      final PaginatedList<OperationalReportRecord> page =
          await getReportUseCase(
        type: type,
        networkId: networkId,
        posId: requestedPosId,
        fromDate: fromDate.value,
        toDate: toDate.value,
        search: searchTextController.text,
        status: selectedStatus.value,
        saleType: selectedSaleType.value,
        cursor: refresh ? null : nextCursor.value,
      );
      if (revision != _requestRevision ||
          networkId != _networkId ||
          type != selectedType.value ||
          requestedPosId != _queryPosId) {
        return;
      }

      if (refresh) {
        reports.assignAll(page.items);
      } else {
        reports.addAll(page.items);
      }
      nextCursor.value = page.nextCursor;
      errorMessage.value = null;

      if (refresh) {
        try {
          final reportSummary = await getSummaryUseCase(
            type: type,
            networkId: networkId,
            posId: requestedPosId,
            fromDate: fromDate.value,
            toDate: toDate.value,
            search: searchTextController.text,
            status: selectedStatus.value,
            saleType: selectedSaleType.value,
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
        fromDate: fromDate.value,
        toDate: toDate.value,
        search: searchTextController.text,
        status: selectedStatus.value,
        saleType: selectedSaleType.value,
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

  Future<void> refreshExportStatus() async {
    final job = exportJob.value;
    if (job == null || isCheckingExport.value) return;
    isCheckingExport.value = true;
    try {
      final status = await getExportStatusUseCase(job.exportId);
      exportJob.value = status;
      if (status.isReady) {
        final url = status.downloadUrl ??
            ApiConstants.operationalReportExportDownload(status.exportId);
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
