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

  int _invoiceRequestVersion = 0;

  bool get hasMore => nextCursor.value?.trim().isNotEmpty ?? false;

  @override
  void onInit() {
    super.onInit();
    loadDebtData();
  }

  Future<void> loadDebtData() async {
    if (isLoading.value) return;
    final invoiceVersionAtStart = _invoiceRequestVersion;
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

    // A bucket change during the summary request already started a newer
    // invoice query. Do not invalidate it with a redundant stale refresh.
    if (_invoiceRequestVersion == invoiceVersionAtStart) {
      await loadInvoices(isRefresh: true);
    }
  }

  Future<void> loadInvoices({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoadingInvoices.value = true;
      isLoadingMore.value = false;
      nextCursor.value = null;
      invoicesErrorMessage.value = null;
    } else {
      if (isLoadingInvoices.value || isLoadingMore.value || !hasMore) {
        return;
      }
      isLoadingMore.value = true;
      invoicesErrorMessage.value = null;
    }

    final requestVersion = ++_invoiceRequestVersion;
    final requestedBucket = selectedBucket.value;
    final requestedCursor = isRefresh ? null : nextCursor.value;

    try {
      final res = await getOutstandingInvoicesUseCase(
        bucket: requestedBucket,
        cursor: requestedCursor,
        perPage: 15,
      );

      if (requestVersion != _invoiceRequestVersion ||
          selectedBucket.value != requestedBucket) {
        return;
      }

      if (isRefresh) {
        outstandingInvoices.assignAll(res.items);
      } else {
        final existingIds = outstandingInvoices
            .map((invoice) => invoice.invoiceId)
            .toSet();
        outstandingInvoices.addAll(
          res.items.where((invoice) => existingIds.add(invoice.invoiceId)),
        );
      }
      nextCursor.value = res.nextCursor;
      invoicesErrorMessage.value = null;
    } on AppException catch (e) {
      if (requestVersion != _invoiceRequestVersion ||
          selectedBucket.value != requestedBucket) {
        return;
      }
      invoicesErrorMessage.value = e.message;
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'تعذر تحميل الفواتير المستحقة',
          message: e.message,
          type: SnackType.error,
        );
      }
    } catch (e) {
      if (requestVersion != _invoiceRequestVersion ||
          selectedBucket.value != requestedBucket) {
        return;
      }
      invoicesErrorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل الفواتير المستحقة. يرجى المحاولة مجدداً.',
      );
    } finally {
      if (requestVersion == _invoiceRequestVersion) {
        isLoadingInvoices.value = false;
        isLoadingMore.value = false;
      }
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
    await loadInvoices(isRefresh: false);
  }
}
