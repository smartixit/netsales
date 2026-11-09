import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/subscription/data/models/provider_subscription_model.dart';
import 'package:netsales/features/subscription/domain/entities/feature_quota_item_entity.dart';
import 'package:netsales/features/subscription/domain/entities/provider_subscription_entity.dart';
import 'package:netsales/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:netsales/features/subscription/domain/usecases/activate_early_subscription_use_case.dart';
import 'package:netsales/features/subscription/domain/usecases/consume_feature_use_case.dart';
import 'package:netsales/features/subscription/domain/usecases/get_active_network_subscription_use_case.dart';
import 'package:netsales/features/subscription/presentation/controllers/network_subscription_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSubscriptionRepository implements SubscriptionRepository {
  ProviderSubscriptionEntity? mockActiveSubscription;
  ProviderSubscriptionEntity? mockEarlyActivatedSubscription;
  bool shouldThrow = false;
  String throwMessage = 'خطأ في جلب بيانات الاشتراك';

  bool getActiveCalled = false;
  bool activateEarlyCalled = false;
  bool consumeCalled = false;
  String? lastConsumedFeature;
  int? lastConsumedAmount;

  @override
  Future<ProviderSubscriptionEntity?> getActiveForNetwork(int networkId) async {
    getActiveCalled = true;
    if (shouldThrow) throw AppException(throwMessage);
    return mockActiveSubscription;
  }

  @override
  Future<ProviderSubscriptionEntity> activateEarlyForNetwork(
    int networkId,
  ) async {
    activateEarlyCalled = true;
    if (shouldThrow) throw AppException(throwMessage);
    return mockEarlyActivatedSubscription ??
        mockActiveSubscription ??
        const ProviderSubscriptionEntity(
          subscriptionId: 99,
          networkId: 1,
          planId: 2,
          planName: 'باقة جديدة',
          planPrice: 30000,
          planValidity: 30,
          status: 'ACTIVE',
          statusLabel: 'نشط',
        );
  }

  @override
  Future<void> consumeFeature({
    required int networkId,
    required String featureName,
    int amount = 1,
  }) async {
    consumeCalled = true;
    lastConsumedFeature = featureName;
    lastConsumedAmount = amount;
    if (shouldThrow) throw AppException(throwMessage);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSubscriptionRepository mockRepo;
  late GetActiveNetworkSubscriptionUseCase getActiveUseCase;
  late ActivateEarlySubscriptionUseCase activateEarlyUseCase;
  late ConsumeFeatureUseCase consumeUseCase;
  late NetworkSubscriptionController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    mockRepo = MockSubscriptionRepository();
    getActiveUseCase = GetActiveNetworkSubscriptionUseCase(mockRepo);
    activateEarlyUseCase = ActivateEarlySubscriptionUseCase(mockRepo);
    consumeUseCase = ConsumeFeatureUseCase(mockRepo);
  });

  tearDown(() {
    Get.reset();
  });

  Map<String, dynamic> sampleLaravelSubscriptionJson({
    int vouchersLimit = 1000,
    int vouchersConsumed = 850,
  }) {
    return {
      'subscription_id': 10,
      'network_id': 42,
      'plan_id': 3,
      'subscription_start_date': '2026-11-01 00:00:00',
      'subscription_end_date': '2026-12-01 00:00:00',
      'status': 'ACTIVE',
      'status_label': 'نشط ومفعل',
      'plan': {
        'plan_id': 3,
        'plan_name': 'باقة الموزع الذهبية',
        'plan_price': 50000.0,
        'plan_validity': 30,
        'plan_desc': 'باقة شاملة لكافة نقاط البيع',
        'plan_features': [
          {
            'feature_id': 1,
            'plan_feature_value': vouchersLimit.toString(),
            'feature': {
              'feature_id': 1,
              'feature_name': 'vouchers.create',
              'feature_desc': 'توليد كروت الشبكة',
              'feature_value_type': 'NUMERIC',
            },
          },
          {
            'feature_id': 2,
            'plan_feature_value': '-1', // غير محدود
            'feature': {
              'feature_id': 2,
              'feature_name': 'pos.link',
              'feature_desc': 'ربط نقاط البيع',
              'feature_value_type': 'NUMERIC',
            },
          },
        ],
      },
      'consumptions': [
        {
          'consumption_id': 1001,
          'feature_id': 1,
          'consumption_value': vouchersConsumed,
          'last_consumption_at': '2026-11-08 12:00:00',
        },
        {
          'consumption_id': 1002,
          'feature_id': 2,
          'consumption_value': 25,
          'last_consumption_at': '2026-11-09 10:00:00',
        },
      ],
    };
  }

  group('Phase 2.3: Network Provider Subscriptions & Quotas Tests', () {
    test('Scenario 1: Deserializes Laravel JSON and maps quotas and consumptions accurately', () {
      final json = sampleLaravelSubscriptionJson(
        vouchersLimit: 1000,
        vouchersConsumed: 850,
      );
      final model = ProviderSubscriptionModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity.subscriptionId, equals(10));
      expect(entity.networkId, equals(42));
      expect(entity.planName, equals('باقة الموزع الذهبية'));
      expect(entity.planPrice, equals(50000.0));
      expect(entity.isActive, isTrue);
      expect(entity.quotas.length, equals(2));

      // Quota 1: Limited (1000 limit, 850 consumed => 150 remaining, 85%)
      final quota1 = entity.quotas.firstWhere(
        (q) => q.featureName == 'vouchers.create',
      );
      expect(quota1.isUnlimited, isFalse);
      expect(quota1.quotaLimit, equals(1000));
      expect(quota1.consumedValue, equals(850));
      expect(quota1.remainingValue, equals(150));
      expect(quota1.percentage, closeTo(0.85, 0.001));
      expect(quota1.isNearExhaustion, isTrue);
      expect(quota1.isExhausted, isFalse);

      // Quota 2: Unlimited (-1 limit, 25 consumed)
      final quota2 = entity.quotas.firstWhere(
        (q) => q.featureName == 'pos.link',
      );
      expect(quota2.isUnlimited, isTrue);
      expect(quota2.quotaLimit, equals(-1));
      expect(quota2.consumedValue, equals(25));
      expect(quota2.remainingValue, equals(-1));
      expect(quota2.isNearExhaustion, isFalse);
      expect(quota2.isExhausted, isFalse);
    });

    test('Scenario 2: Calculates quota exhaustion states correctly (Normal, Warning, Exhausted)', () {
      // Normal state: 200 consumed of 1000 (20%)
      final normalQuota = const FeatureQuotaItemEntity(
        featureId: 1,
        featureName: 'vouchers',
        isUnlimited: false,
        quotaLimit: 1000,
        consumedValue: 200,
      );
      expect(normalQuota.percentage, closeTo(0.20, 0.001));
      expect(normalQuota.remainingValue, equals(800));
      expect(normalQuota.isNearExhaustion, isFalse);
      expect(normalQuota.isExhausted, isFalse);

      // Warning state: 800 consumed of 1000 (80%)
      final warningQuota = const FeatureQuotaItemEntity(
        featureId: 1,
        featureName: 'vouchers',
        isUnlimited: false,
        quotaLimit: 1000,
        consumedValue: 800,
      );
      expect(warningQuota.percentage, closeTo(0.80, 0.001));
      expect(warningQuota.remainingValue, equals(200));
      expect(warningQuota.isNearExhaustion, isTrue);
      expect(warningQuota.isExhausted, isFalse);

      // Exhausted state: 1000 consumed of 1000 (100%)
      final exhaustedQuota = const FeatureQuotaItemEntity(
        featureId: 1,
        featureName: 'vouchers',
        isUnlimited: false,
        quotaLimit: 1000,
        consumedValue: 1000,
      );
      expect(exhaustedQuota.percentage, equals(1.0));
      expect(exhaustedQuota.remainingValue, equals(0));
      expect(exhaustedQuota.isNearExhaustion, isFalse);
      expect(exhaustedQuota.isExhausted, isTrue);

      // Over-consumed state: 1050 consumed of 1000 (clamped to 1.0, remaining 0)
      final overQuota = const FeatureQuotaItemEntity(
        featureId: 1,
        featureName: 'vouchers',
        isUnlimited: false,
        quotaLimit: 1000,
        consumedValue: 1050,
      );
      expect(overQuota.percentage, equals(1.0));
      expect(overQuota.remainingValue, equals(0));
      expect(overQuota.isExhausted, isTrue);
    });

    test('Scenario 3: Controller loads active subscription on init', () async {
      final sampleEntity = ProviderSubscriptionModel.fromJson(
        sampleLaravelSubscriptionJson(),
      ).toEntity();
      mockRepo.mockActiveSubscription = sampleEntity;

      controller = NetworkSubscriptionController(
        getActiveSubscriptionUseCase: getActiveUseCase,
        activateEarlyUseCase: activateEarlyUseCase,
        consumeFeatureUseCase: consumeUseCase,
      );
      controller.selectedNetworkId.value = 42;

      await controller.loadSubscription();

      expect(mockRepo.getActiveCalled, isTrue);
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isNull);
      expect(controller.subscription.value, isNotNull);
      expect(controller.subscription.value?.subscriptionId, equals(10));
      expect(
        controller.subscription.value?.planName,
        equals('باقة الموزع الذهبية'),
      );
    });

    test(
      'Scenario 4: Handles empty subscription when network has no active plan',
      () async {
        mockRepo.mockActiveSubscription = null;

        controller = NetworkSubscriptionController(
          getActiveSubscriptionUseCase: getActiveUseCase,
          activateEarlyUseCase: activateEarlyUseCase,
          consumeFeatureUseCase: consumeUseCase,
        );
        controller.selectedNetworkId.value = 42;

        await controller.loadSubscription();

        expect(mockRepo.getActiveCalled, isTrue);
        expect(controller.isLoading.value, isFalse);
        expect(controller.errorMessage.value, isNull);
        expect(controller.subscription.value, isNull);
      },
    );

    test(
      'Scenario 5: Handles server error gracefully and surfaces clean message',
      () async {
        mockRepo.shouldThrow = true;
        mockRepo.throwMessage = 'تعذر الاتصال بقاعدة البيانات';

        controller = NetworkSubscriptionController(
          getActiveSubscriptionUseCase: getActiveUseCase,
          activateEarlyUseCase: activateEarlyUseCase,
          consumeFeatureUseCase: consumeUseCase,
        );
        controller.selectedNetworkId.value = 42;

        await controller.loadSubscription();

        expect(mockRepo.getActiveCalled, isTrue);
        expect(controller.isLoading.value, isFalse);
        expect(
          controller.errorMessage.value,
          contains('تعذر الاتصال بقاعدة البيانات'),
        );
        expect(controller.subscription.value, isNull);
      },
    );

    test('Scenario 6: Early activation triggers usecase and updates state with new subscription', () async {
      final currentSub = ProviderSubscriptionModel.fromJson(
        sampleLaravelSubscriptionJson(
          vouchersLimit: 1000,
          vouchersConsumed: 1000,
        ),
      ).toEntity();
      mockRepo.mockActiveSubscription = currentSub;

      final renewedSub = const ProviderSubscriptionEntity(
        subscriptionId: 11,
        networkId: 42,
        planId: 3,
        planName: 'باقة الموزع الذهبية (دورة جديدة)',
        planPrice: 50000,
        planValidity: 30,
        status: 'ACTIVE',
        statusLabel: 'نشط ومجدد',
        quotas: [],
      );
      mockRepo.mockEarlyActivatedSubscription = renewedSub;

      controller = NetworkSubscriptionController(
        getActiveSubscriptionUseCase: getActiveUseCase,
        activateEarlyUseCase: activateEarlyUseCase,
        consumeFeatureUseCase: consumeUseCase,
      );
      controller.selectedNetworkId.value = 42;
      controller.subscription.value = currentSub;

      final success = await controller.activateEarly();

      expect(success, isTrue);
      expect(mockRepo.activateEarlyCalled, isTrue);
      expect(controller.subscription.value?.subscriptionId, equals(11));
      expect(controller.subscription.value?.planName, contains('دورة جديدة'));
    });

    test('Scenario 7: Consuming a feature triggers usecase and reloads subscription', () async {
      final sampleEntity = ProviderSubscriptionModel.fromJson(
        sampleLaravelSubscriptionJson(),
      ).toEntity();
      mockRepo.mockActiveSubscription = sampleEntity;

      controller = NetworkSubscriptionController(
        getActiveSubscriptionUseCase: getActiveUseCase,
        activateEarlyUseCase: activateEarlyUseCase,
        consumeFeatureUseCase: consumeUseCase,
      );
      controller.selectedNetworkId.value = 42;

      final success = await controller.consumeFeature('vouchers.create', 50);

      expect(success, isTrue);
      expect(mockRepo.consumeCalled, isTrue);
      expect(mockRepo.lastConsumedFeature, equals('vouchers.create'));
      expect(mockRepo.lastConsumedAmount, equals(50));
      expect(mockRepo.getActiveCalled, isTrue);
    });
  });
}
