import 'package:netsales/features/profile/domain/entities/profile_entity.dart';

/// Domain contract for retrieving the authenticated user's profile.
abstract interface class ProfileRepository {
  Future<ProfileEntity> getProfile();
}
