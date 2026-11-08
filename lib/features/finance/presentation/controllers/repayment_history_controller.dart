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

  bool get hasMore => nextCursor.value != null;

  @override
  void onInit() {
    super.onInit();
    loadRepayments(isRefresh: true);
  }

  Future<void> loadRepayments({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading.value = true;
      errorMessage.value = null;
      nextCursor.value = null;
    }

    try {
      final res = await getRepaymentsUseCase(
        status: selectedStatus.value,
        cursor: isRefresh ? null : nextCursor.value,
        perPage: 15,
      );

      if (isRefresh) {
        repayments.assignAll(res.items);
      } else {
        repayments.addAll(res.items);
      }
      nextCursor.value = res.nextCursor;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'خطأ',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      errorMessage.value = 'تعذر استرجاع سجلات السداد: $e';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreRepayments() async {
    if (isLoadingMore.value || !hasMore) return;
    errorMessage.value = null;
    isLoadingMore.value = true;
    await loadRepayments(isRefresh: false);
  }

  void onStatusChanged(String? status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
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
        message: 'تعذر عكس السند: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
    }
  }
}
