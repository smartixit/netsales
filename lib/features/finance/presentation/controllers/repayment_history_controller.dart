import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/usecases/repayment_use_cases.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class RepaymentHistoryController extends GetxController {
  final GetRepaymentsUseCase getRepaymentsUseCase;
  final ReverseRepaymentUseCase? reverseRepaymentUseCase;

  RepaymentHistoryController({
    required this.getRepaymentsUseCase,
    this.reverseRepaymentUseCase,
  });

  final repayments = <PosRepaymentEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final nextCursor = RxnString();
  final selectedStatus = RxnString();
  final errorMessage = RxnString();

  int _requestVersion = 0;

  bool get hasMore => nextCursor.value?.trim().isNotEmpty ?? false;

  @override
  void onInit() {
    super.onInit();
    loadRepayments(isRefresh: true);
  }

  Future<void> loadRepayments({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading.value = true;
      isLoadingMore.value = false;
      errorMessage.value = null;
      nextCursor.value = null;
    } else {
      if (isLoading.value || isLoadingMore.value || !hasMore) return;
      isLoadingMore.value = true;
      errorMessage.value = null;
    }

    final requestVersion = ++_requestVersion;
    final requestedStatus = selectedStatus.value;
    final requestedCursor = isRefresh ? null : nextCursor.value;

    try {
      final res = await getRepaymentsUseCase(
        status: requestedStatus,
        cursor: requestedCursor,
        perPage: 15,
      );

      if (requestVersion != _requestVersion ||
          selectedStatus.value != requestedStatus) {
        return;
      }

      if (isRefresh) {
        repayments.assignAll(res.items);
      } else {
        final existingIds = repayments
            .map((repayment) => repayment.repaymentId)
            .toSet();
        repayments.addAll(
          res.items.where((repayment) => existingIds.add(repayment.repaymentId)),
        );
      }
      nextCursor.value = res.nextCursor;
      errorMessage.value = null;
    } on AppException catch (e) {
      if (requestVersion != _requestVersion ||
          selectedStatus.value != requestedStatus) {
        return;
      }
      errorMessage.value = e.message;
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'تعذر تحميل سندات السداد',
          message: e.message,
          type: SnackType.error,
        );
      }
    } catch (e) {
      if (requestVersion != _requestVersion ||
          selectedStatus.value != requestedStatus) {
        return;
      }
      errorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر استرجاع سجلات السداد. يرجى المحاولة مجدداً.',
      );
    } finally {
      if (requestVersion == _requestVersion) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreRepayments() async {
    await loadRepayments(isRefresh: false);
  }

  void onStatusChanged(String? status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    repayments.clear();
    nextCursor.value = null;
    loadRepayments(isRefresh: true);
  }

  Future<bool> reverseRepayment(int repaymentId, String reason) async {
    if (reverseRepaymentUseCase == null) return false;

    await CustomAnimationOverlay.showLoading(message: 'جاري عكس سند السداد...');
    try {
      final reversed = await reverseRepaymentUseCase!(
        repaymentId: repaymentId,
        reversalReason: reason,
      );

      final index = repayments.indexWhere((r) => r.repaymentId == repaymentId);
      if (index != -1) {
        repayments[index] = reversed;
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم عكس سند السداد بنجاح',
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'فشل العكس',
        message: e.message,
        type: SnackType.error,
      );
      return false;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'خطأ',
        message: AppException.sanitizeMessage(
          e,
          fallback: 'تعذر عكس السند. يرجى المحاولة مجدداً.',
        ),
        type: SnackType.error,
      );
      return false;
    } finally {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
    }
  }
}
