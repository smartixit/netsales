import 'dart:async';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/usecases/get_profile_use_case.dart';
class ProfileController extends GetxController {
  ProfileController({required this.getProfileUseCase});
  final GetProfileUseCase getProfileUseCase;
  final Rxn<ProfileEntity> profile = Rxn<ProfileEntity>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  int _revision = 0;
  @override
  void onInit() { super.onInit(); unawaited(loadProfile()); }
  Future<void> loadProfile() async {
    final revision = ++_revision;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await getProfileUseCase();
      if (revision != _revision || isClosed) return;
      profile.value = result;
    } catch (error) {
      if (revision != _revision || isClosed) return;
      errorMessage.value = AppException.sanitizeMessage(error, fallback: 'تعذر تحميل بيانات الحساب.');
    } finally {
      if (revision == _revision && !isClosed) isLoading.value = false;
    }
  }
  void openSecuritySettings() => Get.toNamed<void>(AppRoutes.securitySettings);
  void openActiveSessions() => Get.toNamed<void>(AppRoutes.activeSessions);
  @override
  void onClose() { _revision++; super.onClose(); }
}
