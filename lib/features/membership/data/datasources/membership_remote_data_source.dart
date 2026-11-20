import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/membership/data/models/membership_role_model.dart';
import 'package:netsales/features/membership/data/models/workspace_member_model.dart';

/// واجهة مصدر البيانات عن بُعد لأعضاء مساحات العمل المتطابقة مع معايير ApiResponse
abstract interface class MembershipRemoteDataSource {
  // ── شبكة التزويد ──
  Future<ApiResponse<List<WorkspaceMemberModel>>> getNetworkMembers(
    int networkId,
  );

  Future<ApiResponse<List<MembershipRoleModel>>> getNetworkRoles(
    int networkId,
  );

  Future<ApiResponse<WorkspaceMemberModel>> addNetworkMember(
    int networkId,
    Map<String, dynamic> data,
  );

  Future<ApiResponse<WorkspaceMemberModel>> updateNetworkMemberRole(
    int networkId,
    int userId,
    Map<String, dynamic> data,
  );

  Future<ApiResponse<WorkspaceMemberModel>> updateNetworkMemberStatus(
    int networkId,
    int userId,
    Map<String, dynamic> data,
  );

  Future<ApiResponse<dynamic>> removeNetworkMember(
    int networkId,
    int userId, {
    Map<String, dynamic>? data,
  });

  // ── نقطة البيع ──
  Future<ApiResponse<List<WorkspaceMemberModel>>> getPosMembers(
    int posId,
  );

  Future<ApiResponse<List<MembershipRoleModel>>> getPosRoles(
    int posId,
  );

  Future<ApiResponse<WorkspaceMemberModel>> addPosMember(
    int posId,
    Map<String, dynamic> data,
  );

  Future<ApiResponse<WorkspaceMemberModel>> updatePosMemberRole(
    int posId,
    int userId,
    Map<String, dynamic> data,
  );

  Future<ApiResponse<WorkspaceMemberModel>> updatePosMemberStatus(
    int posId,
    int userId,
    Map<String, dynamic> data,
  );

  Future<ApiResponse<dynamic>> removePosMember(
    int posId,
    int userId, {
    Map<String, dynamic>? data,
  });
}
