import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/features/onboarding/domain/entities/onboarding_item_entity.dart';
import 'package:netsales/features/onboarding/domain/usecases/complete_onboarding_use_case.dart';
import 'package:netsales/features/onboarding/domain/usecases/get_onboarding_items_use_case.dart';

/// متحكم جولة التعريف التفاعلية (OnboardingController)
/// يتلقى البيانات وينفذ الإجراءات حصراً عبر حالات الاستخدام (Use Cases)
class OnboardingController extends GetxController {
  final GetOnboardingItemsUseCase _getOnboardingItemsUseCase;
  final CompleteOnboardingUseCase _completeOnboardingUseCase;

  OnboardingController({
    required GetOnboardingItemsUseCase getOnboardingItemsUseCase,
    required CompleteOnboardingUseCase completeOnboardingUseCase,
  })  : _getOnboardingItemsUseCase = getOnboardingItemsUseCase,
        _completeOnboardingUseCase = completeOnboardingUseCase;

  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  late final List<OnboardingItemEntity> items;

  bool get isLastPage => currentPage.value == items.length - 1;

  late ThemeService theme;

  @override
  void onInit() {
    super.onInit();
     theme = ThemeService.to;
    // جلب شرائح العرض من خلال حالة الاستخدام الدومينية
    items = _getOnboardingItemsUseCase();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      completeOnboarding();
    } else {
      pageController.nextPage(
        duration: AppMotion.normal,
        curve: AppMotion.emphasized,
      );
    }
  }

  Future<void> skip() async {
    await completeOnboarding();
  }

  Future<void> completeOnboarding() async {
    await _completeOnboardingUseCase();
    Get.offNamed(AppRoutes.welcome);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
