import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/features/debts/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/debts/domain/entities/outstanding_invoice_entity.dart';
import 'package:netsales/features/debts/domain/entities/repayment_entity.dart';
import 'package:netsales/features/debts/domain/usecases/collect_repayment_use_case.dart';
import 'package:netsales/features/debts/domain/usecases/get_outstanding_invoices_use_case.dart';
import 'package:netsales/features/debts/domain/usecases/get_receivables_summary_use_case.dart';
import 'package:netsales/features/debts/domain/usecases/get_repayments_use_case.dart';
import 'package:netsales/features/debts/domain/usecases/reverse_repayment_use_case.dart';
import 'package:netsales/features/debts/domain/usecases/update_credit_limit_use_case.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkDebtsController extends GetxController {
  final GetReceivablesSummaryUseCase getReceivablesSummaryUseCase;
  final GetOutstandingInvoicesUseCase getOutstandingInvoicesUseCase;
  final GetRepaymentsUseCase getRepaymentsUseCase;
  final CollectRepaymentUseCase collectRepaymentUseCase;
  final ReverseRepaymentUseCase reverseRepaymentUseCase;
  final UpdateCreditLimitUseCase updateCreditLimitUseCase;

  NetworkDebtsController({
    required this.getReceivablesSummaryUseCase,
    required this.getOutstandingInvoicesUseCase,
    required this.getRepaymentsUseCase,
    required this.collectRepaymentUseCase,
    required this.reverseRepaymentUseCase,
    required this.updateCreditLimitUseCase,
  });

  /// البيانات الرئيسية
  final Rxn<PosDebtSummaryEntity> summary = Rxn<PosDebtSummaryEntity>();
  final Rxn<PosDebtBreakdownEntity> selectedPos = Rxn<PosDebtBreakdownEntity>();
  final RxList<PosOutstandingInvoiceEntity> outstandingInvoices = <PosOutstandingInvoiceEntity>[].obs;
  final RxList<PosRepaymentEntity> repayments = <PosRepaymentEntity>[].obs;

  /// حالات التحميل
  final RxBool isLoadingSummary = false.obs;
  final RxBool isLoadingInvoices = false.obs;
  final RxBool isLoadingRepayments = false.obs;
  final RxBool isSubmittingPayment = false.obs;
  final RxBool isReversingRepayment = false.obs;
  final RxBool isUpdatingCreditLimit = false.obs;

  /// التبويب النشط (0: نظرة عامة والذمم، 1: الفواتير الآجلة، 2: سجل السدادات)
  final RxInt activeTabIndex = 0.obs;

  /// استخلاص معرف الشبكة النشطة من سياق لوحة التحكم
  int get networkId {
    if (Get.arguments is int) {
      return Get.arguments as int;
    }
    if (Get.isRegistered<DashboardController>()) {
      final dashContext = Get.find<DashboardController>().overview.value?.context;
      if (dashContext?.networkId != null && dashContext!.networkId! > 0) {
        return dashContext.networkId!;
      }
    }
    return 1;
  }

  @override
  void onInit() {
    super.onInit();
    loadReceivablesSummary();
    loadRepayments();
  }

  /// تحميل ملخص الذمم وتحليل أعمار الديون
  Future<void> loadReceivablesSummary() async {
    try {
      isLoadingSummary.value = true;
      final res = await getReceivablesSummaryUseCase(networkId: networkId);
      if (res.success && res.data != null) {
        summary.value = res.data;
        if (selectedPos.value != null) {
          final updated = res.data!.posBreakdown.firstWhereOrNull(
            (p) => p.posId == selectedPos.value!.posId,
          );
          selectedPos.value = updated;
        }
      } else {
        CustomSnackbar.show(title: 'خطأ', message: res.message, type: SnackType.error);
      }
    } catch (e) {
      CustomSnackbar.show(title: 'خطأ', message: AppException.sanitizeMessage(e), type: SnackType.error);
    } finally {
      isLoadingSummary.value = false;
    }
  }

  /// تحديد نقطة بيع واستعراض فواتيرها الآجلة
  void selectPos(PosDebtBreakdownEntity pos) {
    selectedPos.value = pos;
    loadOutstandingInvoices(pos.posId);
  }

  /// تحميل فواتير البيع الآجل غير المسددة لنقطة بيع محددة
  Future<void> loadOutstandingInvoices(int posId) async {
    try {
      isLoadingInvoices.value = true;
      final res = await getOutstandingInvoicesUseCase(
        networkId: networkId,
        posId: posId,
      );
      if (res.success && res.data != null) {
        outstandingInvoices.assignAll(res.data!);
      } else {
        CustomSnackbar.show(title: 'خطأ', message: res.message, type: SnackType.error);
      }
    } catch (e) {
      CustomSnackbar.show(title: 'خطأ', message: AppException.sanitizeMessage(e), type: SnackType.error);
    } finally {
      isLoadingInvoices.value = false;
    }
  }

  /// تحميل سجل سندات السداد
  Future<void> loadRepayments({int? posId}) async {
    try {
      isLoadingRepayments.value = true;
      final res = await getRepaymentsUseCase(
        networkId: networkId,
        posId: posId,
      );
      if (res.success && res.data != null) {
        repayments.assignAll(res.data!);
      } else {
        CustomSnackbar.show(title: 'خطأ', message: res.message, type: SnackType.error);
      }
    } catch (e) {
      CustomSnackbar.show(title: 'خطأ', message: AppException.sanitizeMessage(e), type: SnackType.error);
    } finally {
      isLoadingRepayments.value = false;
    }
  }

  /// احتساب معاينة التوزيع الحتمي (FIFO Preview) للمبلغ المدخل على الفواتير الأقدم أولاً
  List<Map<String, dynamic>> previewFifoAllocation(double amount) {
    if (amount <= 0 || outstandingInvoices.isEmpty) return [];

    double unallocated = amount;
    final previews = <Map<String, dynamic>>[];

    for (final inv in outstandingInvoices) {
      if (unallocated <= 0.001) break;

      final allocated = unallocated >= inv.remainingAmount ? inv.remainingAmount : unallocated;
      final remainingAfter = inv.remainingAmount - allocated;
      final isFull = remainingAfter <= 0.001;

      previews.add({
        'invoice_id': inv.invoiceId,
        'invoice_uuid': inv.invoiceUuid,
        'invoice_date': inv.invoiceDate,
        'original_remaining': inv.remainingAmount,
        'allocated_amount': allocated,
        'remaining_after': remainingAfter,
        'is_fully_paid': isFull,
        'days_outstanding': inv.daysOutstanding,
      });

      unallocated = (unallocated - allocated);
    }

    return previews;
  }

  /// تحصيل سند سداد مديونية مع التوزيع الحتمي
  Future<bool> collectRepayment({
    required int posId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    try {
      isSubmittingPayment.value = true;
      final res = await collectRepaymentUseCase(
        networkId: networkId,
        posId: posId,
        amount: amount,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        notes: notes,
        idempotencyKey: IdempotencyHelper.forRepayment(posId),
      );

      if (res.success) {
        CustomSnackbar.show(title: 'نجاح', message: res.message, type: SnackType.success);
        await loadReceivablesSummary();
        if (selectedPos.value != null && selectedPos.value!.posId == posId) {
          await loadOutstandingInvoices(posId);
        }
        await loadRepayments();
        return true;
      } else {
        CustomSnackbar.show(title: 'خطأ', message: res.message, type: SnackType.error);
        return false;
      }
    } catch (e) {
      CustomSnackbar.show(title: 'خطأ', message: AppException.sanitizeMessage(e), type: SnackType.error);
      return false;
    } finally {
      isSubmittingPayment.value = false;
    }
  }

  /// عكس سند سداد مديونية مع إعادة قيد المديونية
  Future<bool> reverseRepayment({
    required int repaymentId,
    required String reversalReason,
  }) async {
    try {
      isReversingRepayment.value = true;
      final res = await reverseRepaymentUseCase(
        repaymentId: repaymentId,
        reversalReason: reversalReason,
        idempotencyKey: IdempotencyHelper.forRepaymentReversal(repaymentId),
      );

      if (res.success) {
        CustomSnackbar.show(title: 'نجاح', message: res.message, type: SnackType.success);
        await loadReceivablesSummary();
        if (selectedPos.value != null) {
          await loadOutstandingInvoices(selectedPos.value!.posId);
        }
        await loadRepayments();
        return true;
      } else {
        CustomSnackbar.show(title: 'خطأ', message: res.message, type: SnackType.error);
        return false;
      }
    } catch (e) {
      CustomSnackbar.show(title: 'خطأ', message: AppException.sanitizeMessage(e), type: SnackType.error);
      return false;
    } finally {
      isReversingRepayment.value = false;
    }
  }

  /// تحديث السقف الائتماني لمحفظة نقطة البيع
  Future<bool> updateCreditLimit({
    required int walletId,
    double? creditLimit,
  }) async {
    try {
      isUpdatingCreditLimit.value = true;
      final res = await updateCreditLimitUseCase(
        walletId: walletId,
        creditLimit: creditLimit,
      );

      if (res.success) {
        CustomSnackbar.show(title: 'نجاح', message: res.message, type: SnackType.success);
        await loadReceivablesSummary();
        return true;
      } else {
        CustomSnackbar.show(title: 'خطأ', message: res.message, type: SnackType.error);
        return false;
      }
    } catch (e) {
      CustomSnackbar.show(title: 'خطأ', message: AppException.sanitizeMessage(e), type: SnackType.error);
      return false;
    } finally {
      isUpdatingCreditLimit.value = false;
    }
  }
}
