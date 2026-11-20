import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source.dart';
import 'package:netsales/features/membership/data/models/membership_role_model.dart';
import 'package:netsales/features/membership/data/models/workspace_member_model.dart';

/// تطبيق مصدر البيانات عن بُعد لإدارة أعضاء مساحات العمل عبر ApiService
class MembershipRemoteDataSourceImpl implements MembershipRemoteDataSource {
  const MembershipRemoteDataSourceImpl();

  // ── شبكة التزويد (Network Workspace) ──

  @override
  Future<ApiResponse<List<WorkspaceMemberModel>>> getNetworkMembers(
    int networkId,
  ) {
    return ApiService.instance.get<List<WorkspaceMemberModel>>(
      ApiConstants.networkMembers(networkId),
      fromJson: (data) {
        if (data is List) {
          return data
              .map(
                (item) => WorkspaceMemberModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<List<MembershipRoleModel>>> getNetworkRoles(
    int networkId,
  ) {
    return ApiService.instance.get<List<MembershipRoleModel>>(
      ApiConstants.networkMemberRoles(networkId),
      fromJson: (data) {
        if (data is List) {
          return data
              .map(
                (item) => MembershipRoleModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> addNetworkMember(
    int networkId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.post<WorkspaceMemberModel>(
      ApiConstants.networkMembers(networkId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> updateNetworkMemberRole(
    int networkId,
    int userId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.put<WorkspaceMemberModel>(
      ApiConstants.networkMemberRole(networkId, userId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> updateNetworkMemberStatus(
    int networkId,
    int userId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.put<WorkspaceMemberModel>(
      ApiConstants.networkMemberStatus(networkId, userId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<ApiResponse<dynamic>> removeNetworkMember(
    int networkId,
    int userId, {
    Map<String, dynamic>? data,
  }) {
    return ApiService.instance.delete<dynamic>(
      ApiConstants.networkMember(networkId, userId),
      data: data,
    );
  }

  // ── نقطة البيع (POS Workspace) ──

  @override
  Future<ApiResponse<List<WorkspaceMemberModel>>> getPosMembers(
    int posId,
  ) {
    return ApiService.instance.get<List<WorkspaceMemberModel>>(
      ApiConstants.posMembers(posId),
      fromJson: (data) {
        if (data is List) {
          return data
              .map(
                (item) => WorkspaceMemberModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<List<MembershipRoleModel>>> getPosRoles(
    int posId,
  ) {
    return ApiService.instance.get<List<MembershipRoleModel>>(
      ApiConstants.posMemberRoles(posId),
      fromJson: (data) {
        if (data is List) {
          return data
              .map(
                (item) => MembershipRoleModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> addPosMember(
    int posId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.post<WorkspaceMemberModel>(
      ApiConstants.posMembers(posId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> updatePosMemberRole(
    int posId,
    int userId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.put<WorkspaceMemberModel>(
      ApiConstants.posMemberRole(posId, userId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> updatePosMemberStatus(
    int posId,
    int userId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.put<WorkspaceMemberModel>(
      ApiConstants.posMemberStatus(posId, userId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<ApiResponse<dynamic>> removePosMember(
    int posId,
    int userId, {
    Map<String, dynamic>? data,
  }) {
    return ApiService.instance.delete<dynamic>(
      ApiConstants.posMember(posId, userId),
      data: data,
    );
  }
}
