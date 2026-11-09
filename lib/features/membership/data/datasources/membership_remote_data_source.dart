import 'package:netsales/features/membership/data/models/membership_model.dart';
import 'package:netsales/features/membership/data/models/membership_role_model.dart';

abstract interface class MembershipRemoteDataSource {
  const MembershipRemoteDataSource();

  Future<List<MembershipModel>> getMembers(bool isNetwork, int id);

  Future<List<MembershipRoleModel>> getRoles(bool isNetwork, int id);

  Future<MembershipModel> add(bool isNetwork, int id, String phone, int roleId);

  Future<MembershipModel> updateRole(
    bool isNetwork,
    int id,
    int userId,
    int roleId,
  );

  Future<MembershipModel> updateStatus(
    bool isNetwork,
    int id,
    int userId,
    String status,
  );

  Future<void> remove(bool isNetwork, int id, int userId);
}
