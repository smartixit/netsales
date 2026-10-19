import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/features/onboarding/data/datasources/onboarding_local_data_source.dart';

/// تطبيق مصدر البيانات المحلي لجولة التعريف بالاعتماد على StorageService
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  const OnboardingLocalDataSourceImpl();

  @override
  Future<void> completeOnboarding() async {
    await StorageService.instance.setBool(StorageKeys.isFirstLaunch, false);
  }
}
