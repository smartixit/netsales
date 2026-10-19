import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/features/onboarding/domain/entities/onboarding_item.dart';

/// متحكم جولة التعريف التفاعلية (OnboardingController)
class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  bool get isLastPage => currentPage.value == items.length - 1;

  final List<OnboardingItem> items = const [
    OnboardingItem(
      badge: 'كفاءة تشغيلية',
      title: 'أدِر مبيعات شبكتك بذكاء واحترافية',
      description:
          'منصة مركزية متطورة تمنحك السيطرة المطلقة على باقات الخدمة، تسعير المنتجات، ومتابعة مؤشرات أداء المبيعات لحظة بلحظة.',
      icon: Icons.hub_rounded,
      animationAsset: 'assets/animations/onboarding_network.json',
    ),
    OnboardingItem(
      badge: 'توسع لا محدود',
      title: 'اربط نقاط بيعك، وعزّز انتشارك',
      description:
          'تنسيق لحظي يجمعك بوكلائك ومنافذ التوزيع، مع معالجة ذكية لطلبات التزويد وإدارة فورية للمحافظ الرقمية المشتركة.',
      icon: Icons.storefront_rounded,
      animationAsset: 'assets/animations/onboarding_pos.json',
    ),
    OnboardingItem(
      badge: 'شفافية مالية',
      title: 'فواتير دقيقة، وتقارير ترسم نجاحك',
      description:
          'أصدر الفواتير الرسمية واطبع كشوفات الحسابات المعتمدة، مع رؤية مالية شاملة للإيرادات والأرباح تدعم قراراتك الاستراتيجية.',
      icon: Icons.analytics_rounded,
      animationAsset: 'assets/animations/onboarding_analytics.json',
    ),
  ];

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
    await StorageService.instance.setBool(StorageKeys.isFirstLaunch, false);
    Get.offNamed(AppRoutes.welcome);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
