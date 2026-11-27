import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/membership/data/models/membership_role_model.dart';
import 'package:netsales/features/membership/data/models/workspace_member_model.dart';

/// واجهة مصدر البيانات البعيد لعضويات مساحات العمل
abstract interface class MembershipRemoteDataSource {
  // ── مساحة عمل الشبكة (Network Workspace) ──
  Future<ApiResponse<List<WorkspaceMemberModel>>> getNetworkMembers(
    int networkId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  });

  Future<ApiResponse<List<MembershipRoleModel>>> getNetworkAssignableRoles(
    int networkId,
  );

  Future<ApiResponse<WorkspaceMemberModel>> addNetworkMember(
    int networkId, {
    required Map<String, dynamic> data,
  });

  Future<ApiResponse<WorkspaceMemberModel>> updateNetworkMemberRole(
    int networkId,
    int userId, {
    required Map<String, dynamic> data,
  });

  Future<ApiResponse<WorkspaceMemberModel>> updateNetworkMemberStatus(
    int networkId,
    int userId, {
    required Map<String, dynamic> data,
  });

  Future<ApiResponse<dynamic>> removeNetworkMember(
    int networkId,
    int userId, {
    Map<String, dynamic>? data,
  });

  // ── مساحة عمل نقطة البيع (POS Workspace) ──
  Future<ApiResponse<List<WorkspaceMemberModel>>> getPosMembers(
    int posId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  });

  Future<ApiResponse<List<MembershipRoleModel>>> getPosAssignableRoles(
    int posId,
  );

  Future<ApiResponse<WorkspaceMemberModel>> addPosMember(
    int posId, {
    required Map<String, dynamic> data,
  });

  Future<ApiResponse<WorkspaceMemberModel>> updatePosMemberRole(
    int posId,
    int userId, {
    required Map<String, dynamic> data,
  });

  Future<ApiResponse<WorkspaceMemberModel>> updatePosMemberStatus(
    int posId,
    int userId, {
    required Map<String, dynamic> data,
  });

  Future<ApiResponse<dynamic>> removePosMember(
    int posId,
    int userId, {
    Map<String, dynamic>? data,
  });
}
