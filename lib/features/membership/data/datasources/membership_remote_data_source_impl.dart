import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source.dart';
import 'package:netsales/features/membership/data/models/membership_role_model.dart';
import 'package:netsales/features/membership/data/models/workspace_member_model.dart';

/// تطبيق مصدر البيانات البعيد لعضويات مساحات العمل عبر ApiService وApiConstants
class MembershipRemoteDataSourceImpl implements MembershipRemoteDataSource {
  const MembershipRemoteDataSourceImpl();

  // ── مساحة عمل الشبكة (Network Workspace) ──

  @override
  Future<ApiResponse<List<WorkspaceMemberModel>>> getNetworkMembers(
    int networkId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  }) {
    return ApiService.instance.getList<WorkspaceMemberModel>(
      ApiConstants.networkMembers(networkId),
      fromJson: (item) => WorkspaceMemberModel.fromJson(
        item as Map<String, dynamic>,
        defaultTenantId: networkId,
      ),
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
      },
      cursor: cursor,
      perPage: perPage,
    );
  }

  @override
  Future<ApiResponse<List<MembershipRoleModel>>> getNetworkAssignableRoles(
    int networkId,
  ) {
    return ApiService.instance.get<List<MembershipRoleModel>>(
      ApiConstants.networkMemberRoles(networkId),
      fromJson: (data) {
        if (data is List) {
          return data
              .map(
                (item) =>
                    MembershipRoleModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> addNetworkMember(
    int networkId, {
    required Map<String, dynamic> data,
  }) {
    return ApiService.instance.post<WorkspaceMemberModel>(
      ApiConstants.networkMembers(networkId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
        defaultTenantId: networkId,
      ),
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> updateNetworkMemberRole(
    int networkId,
    int userId, {
    required Map<String, dynamic> data,
  }) {
    return ApiService.instance.put<WorkspaceMemberModel>(
      ApiConstants.networkMemberRole(networkId, userId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
        defaultTenantId: networkId,
      ),
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> updateNetworkMemberStatus(
    int networkId,
    int userId, {
    required Map<String, dynamic> data,
  }) {
    return ApiService.instance.put<WorkspaceMemberModel>(
      ApiConstants.networkMemberStatus(networkId, userId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
        defaultTenantId: networkId,
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

  // ── مساحة عمل نقطة البيع (POS Workspace) ──

  @override
  Future<ApiResponse<List<WorkspaceMemberModel>>> getPosMembers(
    int posId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  }) {
    return ApiService.instance.getList<WorkspaceMemberModel>(
      ApiConstants.posMembers(posId),
      fromJson: (item) => WorkspaceMemberModel.fromJson(
        item as Map<String, dynamic>,
        defaultTenantId: posId,
      ),
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
      },
      cursor: cursor,
      perPage: perPage,
    );
  }

  @override
  Future<ApiResponse<List<MembershipRoleModel>>> getPosAssignableRoles(
    int posId,
  ) {
    return ApiService.instance.get<List<MembershipRoleModel>>(
      ApiConstants.posMemberRoles(posId),
      fromJson: (data) {
        if (data is List) {
          return data
              .map(
                (item) =>
                    MembershipRoleModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> addPosMember(
    int posId, {
    required Map<String, dynamic> data,
  }) {
    return ApiService.instance.post<WorkspaceMemberModel>(
      ApiConstants.posMembers(posId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
        defaultTenantId: posId,
      ),
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> updatePosMemberRole(
    int posId,
    int userId, {
    required Map<String, dynamic> data,
  }) {
    return ApiService.instance.put<WorkspaceMemberModel>(
      ApiConstants.posMemberRole(posId, userId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
        defaultTenantId: posId,
      ),
    );
  }

  @override
  Future<ApiResponse<WorkspaceMemberModel>> updatePosMemberStatus(
    int posId,
    int userId, {
    required Map<String, dynamic> data,
  }) {
    return ApiService.instance.put<WorkspaceMemberModel>(
      ApiConstants.posMemberStatus(posId, userId),
      data: data,
      fromJson: (resData) => WorkspaceMemberModel.fromJson(
        resData as Map<String, dynamic>,
        defaultTenantId: posId,
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
