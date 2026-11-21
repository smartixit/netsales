import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';
class GetProfileUseCase {
  const GetProfileUseCase(this.repository);
  final ProfileRepository repository;
  Future<ProfileEntity> call() => repository.getProfile();
}
