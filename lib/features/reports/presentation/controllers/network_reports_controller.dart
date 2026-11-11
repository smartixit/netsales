import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/reports/domain/entities/report_catalog_item.dart';
import 'package:netsales/features/reports/domain/entities/report_run.dart';
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

  int? get networkId => WorkspaceService.to.savedActiveNetworkId;

  @override
  void onInit() {
    super.onInit();
    loadCatalog();
  }

  @override
  void onClose() {
    billingAccountIdController.dispose();
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
