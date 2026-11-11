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
  });

  final GetNetworkReportCatalogUseCase getCatalog;
  final CreateNetworkReportRunUseCase createRun;
  final GetNetworkReportRunUseCase getRun;
  final DownloadReportArtifactUseCase downloadArtifact;

  final catalog = <ReportCatalogItem>[].obs;
  final activeRun = Rxn<ReportRun>();
  final billingAccountIdController = TextEditingController();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final paymentStatusController = TextEditingController();
  final saleTypeController = TextEditingController();
  final isLoading = false.obs;
  final isCreating = false.obs;
  final isRefreshing = false.obs;
  final isDownloading = false.obs;
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
    billingAccountIdController.dispose();
    for (final field in filterControllers.values) {
      field.dispose();
    }
    filterControllers.clear();
    fromDateController.dispose();
    toDateController.dispose();
    paymentStatusController.dispose();
    saleTypeController.dispose();
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
    final filters = criteria.value.filters.map(
      (key, value) => MapEntry(key, value.jsonValue),
    );
    isCreating.value = true;
    try {
      activeRun.value = await createRun(
        networkId: networkId!,
        reportKey: report.key,
        filters: filters,
      );
      selectedDefinition.value = null;
      engineDefinition.value = null;
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

  Future<void> runReport(ReportCatalogItem definition) async {
    final id = networkId;
    if (id == null) return;
    final availableFilters = definition.filters.keys.toSet();
    final filters = <String, dynamic>{
      if (availableFilters.contains('from') && fromDateController.text.trim().isNotEmpty)
        'from': fromDateController.text.trim(),
      if (availableFilters.contains('to') && toDateController.text.trim().isNotEmpty)
        'to': toDateController.text.trim(),
      if (availableFilters.contains('payment_status') && paymentStatusController.text.trim().isNotEmpty)
        'payment_status': paymentStatusController.text.trim(),
      if (availableFilters.contains('sale_type') && saleTypeController.text.trim().isNotEmpty)
        'sale_type': saleTypeController.text.trim(),
    };
    if (definition.key == 'billing-account-statement') {
      final accountId = int.tryParse(billingAccountIdController.text.trim());
      if (accountId == null || accountId < 1) {
        CustomSnackbar.show(
          title: 'بيانات مطلوبة',
          message: 'أدخل رقم حساب فوترة الاشتراك لعرض كشف الحساب.',
          type: SnackType.warning,
        );
        return;
      }
      filters['billing_account_id'] = accountId;
    }
    isCreating.value = true;
    try {
      activeRun.value = await createRun(
        networkId: id,
        reportKey: definition.key,
        filters: filters,
      );
      CustomSnackbar.show(
        title: 'تم تسجيل التقرير',
        message: 'يمكنك تحديث حالته حتى يكتمل ثم تنزيل ملف النتيجة.',
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
