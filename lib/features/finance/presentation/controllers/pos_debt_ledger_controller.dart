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
  final isLoadingInvoices = false.obs;
  final isLoadingMore = false.obs;
  final selectedBucket = RxnString();
  final nextCursor = RxnString();
  final summaryErrorMessage = RxnString();
  final invoicesErrorMessage = RxnString();

  bool get hasMore => nextCursor.value != null;

  @override
  void onInit() {
    super.onInit();
    loadDebtData();
  }

  Future<void> loadDebtData() async {
    if (isLoading.value) return;
    isLoading.value = true;
    summaryErrorMessage.value = null;

    try {
      summary.value = await getDebtSummaryUseCase();
    } on AppException catch (e) {
      summaryErrorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'تعذر تحميل ملخص الذمم',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      summaryErrorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل ملخص الذمم. يرجى المحاولة مجدداً.',
      );
    } finally {
      isLoading.value = false;
    }

    await loadInvoices(isRefresh: true);
  }

  Future<void> loadInvoices({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoadingInvoices.value = true;
      nextCursor.value = null;
      invoicesErrorMessage.value = null;
    } else if (!hasMore) {
      return;
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
        outstandingInvoices.addAll(
          res.items.where(
            (item) => !outstandingInvoices.any(
              (existing) => existing.invoiceId == item.invoiceId,
            ),
          ),
        );
      }
      nextCursor.value = res.nextCursor;
      invoicesErrorMessage.value = null;
    } on AppException catch (e) {
      invoicesErrorMessage.value = e.message;
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'تعذر تحميل الفواتير المستحقة',
          message: e.message,
          type: SnackType.error,
        );
      }
    } catch (e) {
      invoicesErrorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل الفواتير المستحقة. يرجى المحاولة مجدداً.',
      );
    } finally {
      if (isRefresh) isLoadingInvoices.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> onBucketSelected(String? bucket) async {
    if (selectedBucket.value == bucket) return;
    selectedBucket.value = bucket;
    outstandingInvoices.clear();
    nextCursor.value = null;
    await loadInvoices(isRefresh: true);
  }

  Future<void> loadMoreInvoices() async {
    if (isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    await loadInvoices(isRefresh: false);
  }
}
