import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/reports/domain/entities/report_catalog_item.dart';
import 'package:netsales/features/reports/domain/entities/report_run.dart';
import 'package:netsales/features/reports/domain/entities/report_engine_definition_factory.dart';
import 'package:document_engine/document_engine.dart';
import 'package:netsales/features/reports/domain/usecases/report_use_cases.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkReportsController extends GetxController {
  NetworkReportsController({
    required this.getCatalog,
    required this.createRun,
    required this.getRun,
    required this.downloadArtifact,
    required this.shareArtifact,
  });

  final GetNetworkReportCatalogUseCase getCatalog;
  final CreateNetworkReportRunUseCase createRun;
  final GetNetworkReportRunUseCase getRun;
  final DownloadReportArtifactUseCase downloadArtifact;
  final ShareReportArtifactUseCase shareArtifact;

  final catalog = <ReportCatalogItem>[].obs;
  final activeRun = Rxn<ReportRun>();
  final isLoading = false.obs;
  final isCreating = false.obs;
  final isRefreshing = false.obs;
  final isDownloading = false.obs;
  final isSharing = false.obs;
  final error = RxnString();
  final selectedDefinition = Rxn<ReportCatalogItem>();
  final engineDefinition = Rxn<ReportDefinition>();
  final criteria = ReportCriteria().obs;
  final presentation = ReportPresentationOptions().obs;
  final Map<String, TextEditingController> filterControllers = {};
  final _definitionFactory = const ReportEngineDefinitionFactory();

  int? get networkId => WorkspaceService.to.savedActiveNetworkId;

  @override
  void onInit() {
    super.onInit();
    loadCatalog();
  }

  @override
  void onClose() {
    for (final field in filterControllers.values) {
      field.dispose();
    }
    filterControllers.clear();
    super.onClose();
  }

  Future<void> loadCatalog() async {
    final id = networkId;
    if (id == null || id <= 0) {
      error.value = 'لا توجد شبكة نشطة محفوظة. افتح مساحة الشبكة وحدد الشبكة أولاً.';
      return;
    }
    isLoading.value = true;
    error.value = null;
    try {
      catalog.assignAll(await getCatalog(id));
    } catch (e) {
      error.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل التقارير المتاحة لهذه الشبكة.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void configureReport(ReportCatalogItem report) {
    for (final field in filterControllers.values) {
      field.dispose();
    }
    filterControllers.clear();
    selectedDefinition.value = report;
    engineDefinition.value = _definitionFactory.create(report);
    criteria.value = ReportCriteria();
    presentation.value = ReportPresentationOptions();
    for (final filter in engineDefinition.value!.filters) {
      filterControllers[filter.id] = TextEditingController();
    }
  }

  void clearConfiguration() {
    for (final field in filterControllers.values) {
      field.dispose();
    }
    filterControllers.clear();
    selectedDefinition.value = null;
    engineDefinition.value = null;
    criteria.value = ReportCriteria();
    presentation.value = ReportPresentationOptions();
  }

  TextEditingController textControllerFor(String filterId) =>
      filterControllers.putIfAbsent(filterId, TextEditingController.new);

  void updateFilter(String filterId, ReportFilterValue? value) {
    final next = Map<String, ReportFilterValue>.from(criteria.value.filters);
    if (value == null) {
      next.remove(filterId);
    } else {
      next[filterId] = value;
    }
    criteria.value = ReportCriteria(filters: next);
  }

  void updateCriteria(ReportCriteria value) {
    criteria.value = value;
  }

  void updatePresentation(ReportPresentationOptions value) {
    presentation.value = value;
  }

  Future<void> runConfiguredReport() async {
    final report = selectedDefinition.value;
    final definition = engineDefinition.value;
    if (report == null || definition == null) return;
    final issues = criteria.value.validateAgainst(definition);
    if (issues.isNotEmpty) {
      CustomSnackbar.show(
        title: 'مرشحات غير مكتملة',
        message: 'راجع الحقول المطلوبة وصيغ المرشحات قبل التنفيذ.',
        type: SnackType.warning,
      );
      return;
    }
    final id = networkId;
    if (id == null || id <= 0) {
      CustomSnackbar.show(
        title: 'لا توجد شبكة نشطة',
        message: 'حدد شبكة نشطة قبل تنفيذ التقرير.',
        type: SnackType.warning,
      );
      return;
    }
    final filters = <String, dynamic>{
      for (final entry in criteria.value.filters.entries)
        entry.key: entry.value.jsonValue,
    };
    isCreating.value = true;
    try {
      activeRun.value = await createRun(
        networkId: id,
        reportKey: report.key,
        filters: filters,
      );
      clearConfiguration();
      CustomSnackbar.show(
        title: 'تم تسجيل التقرير',
        message: 'يمكنك متابعة حالة التنفيذ وتنزيل ملف النتيجة بعد اكتماله.',
        type: SnackType.success,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر إنشاء التقرير',
        message: AppException.sanitizeMessage(e, fallback: 'حدث خطأ أثناء تسجيل التقرير.'),
        type: SnackType.error,
      );
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> refreshRun() async {
    final id = networkId;
    final run = activeRun.value;
    if (id == null || run == null) return;
    isRefreshing.value = true;
    try {
      activeRun.value = await getRun(networkId: id, reportRunId: run.id);
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر تحديث الحالة',
        message: AppException.sanitizeMessage(e, fallback: 'تعذر الاتصال بالخادم.'),
        type: SnackType.error,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> shareRun() async {
    final run = activeRun.value;
    final url = run?.downloadUrl;
    if (run == null || !run.isCompleted || url == null || url.isEmpty) return;
    isSharing.value = true;
    try {
      await shareArtifact(url: url, fileName: run.reportKey);
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر مشاركة التقرير',
        message: AppException.sanitizeMessage(e, fallback: 'تعذر مشاركة ملف التقرير.'),
        type: SnackType.error,
      );
    } finally {
      isSharing.value = false;
    }
  }

  Future<void> downloadRun() async {
    final run = activeRun.value;
    final url = run?.downloadUrl;
    if (run == null || !run.isCompleted || url == null || url.isEmpty) return;
    isDownloading.value = true;
    try {
      await downloadArtifact(url: url, fileName: run.reportKey);
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر تنزيل التقرير',
        message: AppException.sanitizeMessage(e, fallback: 'تعذر تنزيل ملف التقرير.'),
        type: SnackType.error,
      );
    } finally {
      isDownloading.value = false;
    }
  }
}
