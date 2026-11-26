import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/entities/update_profile_params.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';

/// حالة استخدام: تحديث بيانات الملف الشخصي.
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call(UpdateProfileParams params) {
    return _repository.updateProfile(params);
  }
}

/// حالة استخدام: رفع الصورة الشخصية.
class UpdateAvatarUseCase {
  const UpdateAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  Future<String> call(UpdateAvatarParams params) {
    return _repository.updateAvatar(params);
  }
}
