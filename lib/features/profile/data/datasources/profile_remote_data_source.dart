import 'package:netsales/core/models/user_model.dart';
abstract interface class ProfileRemoteDataSource { Future<UserModel> getProfile(); }
