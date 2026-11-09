import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/subscription/domain/entities/provider_subscription_entity.dart';
import 'package:netsales/features/subscription/domain/usecases/activate_early_subscription_use_case.dart';
import 'package:netsales/features/subscription/domain/usecases/consume_feature_use_case.dart';
import 'package:netsales/features/subscription/domain/usecases/get_active_network_subscription_use_case.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم اشتراك مزود الشبكة وتتبع الحصص (NetworkSubscriptionController)
class NetworkSubscriptionController extends GetxController {
  NetworkSubscriptionController({
    required this.getActiveSubscriptionUseCase,
    required this.activateEarlyUseCase,
    required this.consumeFeatureUseCase,
  });

  final GetActiveNetworkSubscriptionUseCase getActiveSubscriptionUseCase;
  final ActivateEarlySubscriptionUseCase activateEarlyUseCase;
  final ConsumeFeatureUseCase consumeFeatureUseCase;

  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final Rxn<ProviderSubscriptionEntity> subscription =
      Rxn<ProviderSubscriptionEntity>();
  final RxnString errorMessage = RxnString();
  final RxnInt selectedNetworkId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['network_id'] is int) {
      selectedNetworkId.value = args['network_id'] as int;
    } else if (Get.isRegistered<NetworkWorkspaceController>() &&
        Get.find<NetworkWorkspaceController>().selectedNetworkId.value !=
            null) {
      selectedNetworkId.value =
          Get.find<NetworkWorkspaceController>().selectedNetworkId.value;
    } else if (Get.isRegistered<SessionService>()) {
      final user = SessionService.to.currentUser;
      final netMembership = user?.workspaceMemberships.firstWhereOrNull(
        (m) => m.isNetwork,
      );
      if (netMembership != null && netMembership.tenantId > 0) {
        selectedNetworkId.value = netMembership.tenantId;
      }
    }
    loadSubscription();
  }

  /// جلب الاشتراك النشط للشبكة المحددة
  Future<void> loadSubscription() async {
    final netId = selectedNetworkId.value;
    if (netId == null || netId <= 0) {
      errorMessage.value = 'لم يتم تحديد شبكة نشطة لاستعراض اشتراكها.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result = await getActiveSubscriptionUseCase.execute(netId);
      subscription.value = result;
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(error);
    } finally {
      isLoading.value = false;
    }
  }

  /// التفعيل المبكر للخطة المجدولة التالية
  Future<bool> activateEarly() async {
    final netId = selectedNetworkId.value;
    if (netId == null || netId <= 0) return false;

    try {
      isActionLoading.value = true;
      await CustomAnimationOverlay.showLoading();

      final updated = await activateEarlyUseCase.execute(netId);
      subscription.value = updated;

      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تم التفعيل المبكر بنجاح',
        message: 'تم تفعيل باقة الاشتراك المجدولة وبدء دورة الحصص الجديدة.',
        type: SnackType.success,
      );
      return true;
    } catch (error) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(error);
      CustomSnackbar.show(
        title: 'تعذر التفعيل المبكر',
        message: cleanMessage,
        type: SnackType.error,
      );
      return false;
    } finally {
      isActionLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// تسجيل استهلاك ميزة للشبكة
  Future<bool> consumeFeature(String featureName, [int amount = 1]) async {
    final netId = selectedNetworkId.value;
    if (netId == null || netId <= 0) return false;

    try {
      isActionLoading.value = true;
      await consumeFeatureUseCase.execute(
        ConsumeFeatureParams(
          networkId: netId,
          featureName: featureName,
          amount: amount,
        ),
      );
      await loadSubscription();
      return true;
    } catch (error) {
      final cleanMessage = AppException.sanitizeMessage(error);
      CustomSnackbar.show(
        title: 'فشل احتساب الاستهلاك',
        message: cleanMessage,
        type: SnackType.error,
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }
}
