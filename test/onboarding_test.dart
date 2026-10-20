import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:netsales/features/onboarding/data/models/onboarding_item_model.dart';
import 'package:netsales/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:netsales/features/onboarding/domain/entities/onboarding_item_entity.dart';
import 'package:netsales/features/onboarding/domain/usecases/complete_onboarding_use_case.dart';
import 'package:netsales/features/onboarding/domain/usecases/get_onboarding_items_use_case.dart';

class MockOnboardingLocalDataSource implements OnboardingLocalDataSource {
  bool isCompleted = false;

  @override
  List<OnboardingItemModel> getOnboardingItems() {
    return const [
      OnboardingItemModel(
        title: 'Title 1',
        description: 'Description 1',
        badge: 'Badge 1',
        icon: Icons.star,
      ),
      OnboardingItemModel(
        title: 'Title 2',
        description: 'Description 2',
        badge: 'Badge 2',
        icon: Icons.star,
      ),
    ];
  }

  @override
  Future<void> completeOnboarding() async {
    isCompleted = true;
  }
}

void main() {
  group('Onboarding Clean Architecture Tests', () {
    test('OnboardingItemModel extends OnboardingItemEntity (LSP)', () {
      const model = OnboardingItemModel(
        title: 'Test',
        description: 'Desc',
        badge: 'Badge',
        icon: Icons.star,
      );

      expect(model, isA<OnboardingItemEntity>());
    });

    test('GetOnboardingItemsUseCase retrieves items through repository', () {
      final dataSource = MockOnboardingLocalDataSource();
      final repository = OnboardingRepositoryImpl(dataSource);
      final useCase = GetOnboardingItemsUseCase(repository);

      final items = useCase();
      expect(items.length, 2);
      expect(items.first.title, 'Title 1');
      expect(items.first, isA<OnboardingItemEntity>());
    });

    test('CompleteOnboardingUseCase marks onboarding completed', () async {
      final dataSource = MockOnboardingLocalDataSource();
      final repository = OnboardingRepositoryImpl(dataSource);
      final useCase = CompleteOnboardingUseCase(repository);

      expect(dataSource.isCompleted, isFalse);
      await useCase();
      expect(dataSource.isCompleted, isTrue);
    });
  });
}
