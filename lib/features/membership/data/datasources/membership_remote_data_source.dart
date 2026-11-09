import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/membership/data/models/membership_model.dart';
import 'package:netsales/features/membership/data/models/membership_role_model.dart';

class MembershipRemoteDataSource {
  const MembershipRemoteDataSource();

  String _membersPath(bool isNetwork, int id) =>
      isNetwork ? ApiConstants.networkMembers(id) : ApiConstants.posMembers(id);
  String _rolesPath(bool isNetwork, int id) =>
      isNetwork ? ApiConstants.networkMemberRoles(id) : ApiConstants.posMemberRoles(id);
  String _rolePath(bool isNetwork, int id, int userId) =>
      isNetwork ? ApiConstants.networkMemberRole(id, userId) : ApiConstants.posMemberRole(id, userId);
  String _statusPath(bool isNetwork, int id, int userId) =>
      isNetwork ? ApiConstants.networkMemberStatus(id, userId) : ApiConstants.posMemberStatus(id, userId);
  String _memberPath(bool isNetwork, int id, int userId) =>
      isNetwork ? ApiConstants.networkMember(id, userId) : ApiConstants.posMember(id, userId);

  Future<List<MembershipModel>> getMembers(bool isNetwork, int id) async {
    final response = await ApiService.instance.get<List<MembershipModel>>(
      _membersPath(isNetwork, id),
      fromJson: (data) => (data as List).map((e) =>
          MembershipModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );
    if (!response.success || response.data == null) throw Exception(response.message);
    return response.data!;
  }

  Future<List<MembershipRoleModel>> getRoles(bool isNetwork, int id) async {
    final response = await ApiService.instance.get<List<MembershipRoleModel>>(
      _rolesPath(isNetwork, id),
      fromJson: (data) => (data as List).map((e) =>
          MembershipRoleModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );
    if (!response.success || response.data == null) throw Exception(response.message);
    return response.data!;
  }

  Future<MembershipModel> add(bool isNetwork, int id, String phone, int roleId) async {
    final response = await ApiService.instance.post<MembershipModel>(
      _membersPath(isNetwork, id),
      data: {'user_phone_number': phone, 'role_id': roleId},
      fromJson: (data) => MembershipModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
    if (!response.success || response.data == null) throw Exception(response.message);
    return response.data!;
  }

  Future<MembershipModel> updateRole(bool isNetwork, int id, int userId, int roleId) async {
    final response = await ApiService.instance.put<MembershipModel>(
      _rolePath(isNetwork, id, userId),
      data: {'role_id': roleId},
      fromJson: (data) => MembershipModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
    if (!response.success || response.data == null) throw Exception(response.message);
    return response.data!;
  }

  Future<MembershipModel> updateStatus(bool isNetwork, int id, int userId, String status) async {
    final response = await ApiService.instance.put<MembershipModel>(
      _statusPath(isNetwork, id, userId),
      data: {'status': status},
      fromJson: (data) => MembershipModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
    if (!response.success || response.data == null) throw Exception(response.message);
    return response.data!;
  }

  Future<void> remove(bool isNetwork, int id, int userId) async {
    final response = await ApiService.instance.delete<void>(_memberPath(isNetwork, id, userId));
    if (!response.success) throw Exception(response.message);
  }
}
