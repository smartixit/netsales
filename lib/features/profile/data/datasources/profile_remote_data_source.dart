import 'package:netsales/core/models/user_model.dart';

/// Remote contract for the authenticated account profile.
abstract interface class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
}
