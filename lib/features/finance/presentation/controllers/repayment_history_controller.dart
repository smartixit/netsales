import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/usecases/repayment_use_cases.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class RepaymentHistoryController extends GetxController {
  final GetRepaymentsUseCase getRepaymentsUseCase;
  final GetMyNetworksUseCase getMyNetworksUseCase;
  final ReverseRepaymentUseCase? reverseRepaymentUseCase;

  RepaymentHistoryController({
    required this.getRepaymentsUseCase,
    required this.getMyNetworksUseCase,
    this.reverseRepaymentUseCase,
  });

  final networks = <NetworkEntity>[].obs;
  final selectedNetworkId = RxnInt();
  final isLoadingNetworks = false.obs;
  final networkErrorMessage = RxnString();

  final repayments = <PosRepaymentEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final nextCursor = RxnString();
  final selectedStatus = RxnString('ALL');
  final errorMessage = RxnString();

  int _networksRequestVersion = 0;
  int _requestVersion = 0;

  bool get hasMore => nextCursor.value?.trim().isNotEmpty ?? false;
  bool get hasSelectedNetwork => selectedNetworkId.value != null;

  NetworkEntity? get selectedNetwork {
    final id = selectedNetworkId.value;
    if (id == null) return null;
    return networks.firstWhereOrNull((network) => network.networkId == id);
  }

  @override
  void onInit() {
    super.onInit();
    initializeNetworks();
  }

  Future<void> initializeNetworks() async {
    if (isLoadingNetworks.value) return;

    final requestVersion = ++_networksRequestVersion;
    ++_requestVersion;
    isLoadingNetworks.value = true;
    networkErrorMessage.value = null;
    selectedNetworkId.value = null;
    networks.clear();
    repayments.clear();
    nextCursor.value = null;
    errorMessage.value = null;

    var autoSelectNetworkId = 0;
    try {
      final result = await getMyNetworksUseCase();
      if (requestVersion != _networksRequestVersion) return;

      final uniqueNetworks = <NetworkEntity>[];
      final seenIds = <int>{};
      for (final network in result) {
        if (network.networkId > 0 && seenIds.add(network.networkId)) {
          uniqueNetworks.add(network);
        }
      }
      networks.assignAll(uniqueNetworks);

      if (uniqueNetworks.length == 1) {
        autoSelectNetworkId = uniqueNetworks.single.networkId;
      }
    } on AppException catch (e) {
      if (requestVersion == _networksRequestVersion) {
        networkErrorMessage.value = e.message;
      }
    } catch (e) {
      if (requestVersion == _networksRequestVersion) {
        networkErrorMessage.value = AppException.sanitizeMessage(
          e,
          fallback: 'تعذر تحميل الشبكات المتاحة لسجل السداد. يرجى المحاولة مجدداً.',
        );
      }
    } finally {
      if (requestVersion == _networksRequestVersion) {
        isLoadingNetworks.value = false;
      }
    }

    if (requestVersion == _networksRequestVersion &&
        autoSelectNetworkId > 0) {
      await selectNetwork(autoSelectNetworkId);
    }
  }

  Future<void> selectNetwork(int networkId) async {
    if (!networks.any((network) => network.networkId == networkId) ||
        selectedNetworkId.value == networkId) {
      return;
    }

    selectedNetworkId.value = networkId;
    ++_requestVersion;
    repayments.clear();
    nextCursor.value = null;
    errorMessage.value = null;
    await loadRepayments(isRefresh: true);
  }

  @override
  Future<void> refresh() async {
    if (!hasSelectedNetwork) {
      if (networks.isEmpty) await initializeNetworks();
      return;
    }
    await loadRepayments(isRefresh: true);
  }

  Future<void> loadRepayments({bool isRefresh = false}) async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;

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
    final statusFilter =
        requestedStatus == null || requestedStatus == 'ALL'
            ? null
            : requestedStatus;

    try {
      final result = await getRepaymentsUseCase(
        networkId: networkId,
        status: statusFilter,
        cursor: requestedCursor,
        perPage: 15,
      );

      if (requestVersion != _requestVersion ||
          selectedNetworkId.value != networkId ||
          selectedStatus.value != requestedStatus) {
        return;
      }

      if (isRefresh) {
        repayments.assignAll(result.items);
      } else {
        final existingIds = repayments
            .map((repayment) => repayment.repaymentId)
            .toSet();
        repayments.addAll(
          result.items.where(
            (repayment) => existingIds.add(repayment.repaymentId),
          ),
        );
      }
      nextCursor.value = result.nextCursor;
      errorMessage.value = null;
    } on AppException catch (e) {
      if (requestVersion != _requestVersion ||
          selectedNetworkId.value != networkId ||
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
          selectedNetworkId.value != networkId ||
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
    final normalized = status == null || status.isEmpty ? 'ALL' : status;
    if (selectedStatus.value == normalized) return;
    selectedStatus.value = normalized;
    repayments.clear();
    nextCursor.value = null;
    if (hasSelectedNetwork) {
      loadRepayments(isRefresh: true);
    }
  }

  Future<bool> reverseRepayment(int repaymentId, String reason) async {
    if (reverseRepaymentUseCase == null || !hasSelectedNetwork) return false;

    final networkId = selectedNetworkId.value;
    final repayment = repayments.firstWhereOrNull(
      (item) =>
          item.repaymentId == repaymentId && item.networkId == networkId,
    );
    if (repayment == null) return false;

    await CustomAnimationOverlay.showLoading(message: 'جاري عكس سند السداد...');
    try {
      await reverseRepaymentUseCase!(
        repaymentId: repaymentId,
        reversalReason: reason,
      );

      if (selectedNetworkId.value == networkId) {
        await loadRepayments(isRefresh: true);
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
