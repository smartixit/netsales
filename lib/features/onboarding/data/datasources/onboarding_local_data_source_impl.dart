import 'package:flutter/material.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:netsales/features/onboarding/data/models/onboarding_item_model.dart';

/// تطبيق مصدر البيانات المحلي لجولة التعريف بالاعتماد على StorageService
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  const OnboardingLocalDataSourceImpl();

  @override
  List<OnboardingItemModel> getOnboardingItems() {
    return const [
      OnboardingItemModel(
        badge: 'كفاءة تشغيلية',
        title: 'أدِر مبيعات شبكتك بذكاء واحترافية',
        description:
            'نظام مركزية متطورة تمنحك السيطرة المطلقة على باقات الخدمة، تسعير المنتجات، ومتابعة مؤشرات أداء المبيعات لحظة بلحظة.',
        icon: Icons.hub_rounded,
        animationAsset: 'assets/animations/onboarding_network.json',
      ),
      OnboardingItemModel(
        badge: 'توسع لا محدود',
        title: 'اربط نقاط بيعك، وعزّز انتشارك',
        description:
            'تنسيق لحظي يجمعك بوكلائك ومنافذ التوزيع، مع معالجة ذكية لطلبات التزويد وإدارة فورية للمحافظ الرقمية المشتركة.',
        icon: Icons.storefront_rounded,
        animationAsset: 'assets/animations/onboarding_pos.json',
      ),
      OnboardingItemModel(
        badge: 'شفافية مالية',
        title: 'فواتير دقيقة، وتقارير ترسم نجاحك',
        description:
            'أصدر الفواتير الرسمية واطبع كشوفات الحسابات المعتمدة، مع رؤية مالية شاملة للإيرادات والأرباح تدعم قراراتك الاستراتيجية.',
        icon: Icons.analytics_rounded,
        animationAsset: 'assets/animations/onboarding_analytics.json',
      ),
    ];
  }

  @override
  Future<void> completeOnboarding() async {
    await StorageService.instance.setBool(StorageKeys.isFirstLaunch, false);
  }
}
