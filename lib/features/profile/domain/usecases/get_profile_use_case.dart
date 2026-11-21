import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';

/// Retrieves the authenticated account profile.
class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call() {
    return _repository.getProfile();
  }
}
