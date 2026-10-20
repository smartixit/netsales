import 'package:netsales/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:netsales/features/onboarding/domain/entities/onboarding_item_entity.dart';
import 'package:netsales/features/onboarding/domain/repositories/onboarding_repository.dart';

/// تطبيق مستودع جولة التعريف بالاعتماد على مصدر البيانات المحلي
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _dataSource;

  const OnboardingRepositoryImpl(this._dataSource);

  @override
  List<OnboardingItemEntity> getOnboardingItems() {
    return _dataSource.getOnboardingItems();
  }

  @override
  Future<void> completeOnboarding() {
    return _dataSource.completeOnboarding();
  }
}
