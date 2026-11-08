import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/finance/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/finance/domain/usecases/debt_use_cases.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class PosDebtLedgerController extends GetxController {
  final GetDebtSummaryUseCase getDebtSummaryUseCase;
  final GetOutstandingInvoicesUseCase getOutstandingInvoicesUseCase;

  PosDebtLedgerController({
    required this.getDebtSummaryUseCase,
    required this.getOutstandingInvoicesUseCase,
  });

  final summary = Rxn<DebtSummaryEntity>();
  final outstandingInvoices = <InvoiceEntity>[].obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final selectedBucket =
      RxnString(); // null, '0_30', '31_60', '61_90', 'over_90'
  final nextCursor = RxnString();
  final errorMessage = RxnString();

  bool get hasMore => nextCursor.value != null;

  @override
  void onInit() {
    super.onInit();
    loadDebtData();
  }

  Future<void> loadDebtData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final summaryRes = await getDebtSummaryUseCase();
      summary.value = summaryRes;

      await loadInvoices(isRefresh: true);
    } on AppException catch (e) {
      errorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'خطأ',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      errorMessage.value = 'تعذر تحميل بيانات الذمم والديون: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInvoices({bool isRefresh = false}) async {
    if (isRefresh) {
      nextCursor.value = null;
    }

    try {
      final res = await getOutstandingInvoicesUseCase(
        bucket: selectedBucket.value,
        cursor: isRefresh ? null : nextCursor.value,
        perPage: 15,
      );

      if (isRefresh) {
        outstandingInvoices.assignAll(res.items);
      } else {
        outstandingInvoices.addAll(res.items);
      }
      nextCursor.value = res.nextCursor;
    } catch (e) {
      // invoices error
    } finally {
      isLoadingMore.value = false;
    }
  }

  void onBucketSelected(String? bucket) {
    if (selectedBucket.value == bucket) return;
    selectedBucket.value = bucket;
    loadInvoices(isRefresh: true);
  }

  Future<void> loadMoreInvoices() async {
    if (isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    await loadInvoices(isRefresh: false);
  }
}
