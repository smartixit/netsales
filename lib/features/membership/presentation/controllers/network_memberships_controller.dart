import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/usecases/add_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_network_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_network_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/remove_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_network_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_network_member_status_use_case.dart';
import 'package:netsales/features/membership/presentation/controllers/base_memberships_controller.dart';

class NetworkMembershipsController extends BaseMembershipsController {
  NetworkMembershipsController({
    required this.getNetworkMembersUseCase,
    required this.getNetworkAssignableRolesUseCase,
    required this.addNetworkMemberUseCase,
    required this.updateNetworkMemberRoleUseCase,
    required this.updateNetworkMemberStatusUseCase,
    required this.removeNetworkMemberUseCase,
    this.initialNetworkId,
  });

  final GetNetworkMembersUseCase getNetworkMembersUseCase;
  final GetNetworkAssignableRolesUseCase getNetworkAssignableRolesUseCase;
  final AddNetworkMemberUseCase addNetworkMemberUseCase;
  final UpdateNetworkMemberRoleUseCase updateNetworkMemberRoleUseCase;
  final UpdateNetworkMemberStatusUseCase updateNetworkMemberStatusUseCase;
  final RemoveNetworkMemberUseCase removeNetworkMemberUseCase;
  final int? initialNetworkId;

  @override
  String get pageTitle => 'إدارة أعضاء الشبكة';
  @override
  String get pageSubtitle => 'إدارة وتعيين صلاحيات موظفي ومشغلي الشبكة، والتحكم بحالات تفعيل العضويات فورياً.';
  @override
  IconData get pageIcon => Icons.people_alt_rounded;
  @override
  bool get isNetworkView => true;
  @override
  bool get canViewMembers => PermissionService.to.can(AppPermissions.networkMembersView);
  @override
  bool get canAddMember => PermissionService.to.can(AppPermissions.networkMembersCreate);
  @override
  bool get canChangeMemberRole => PermissionService.to.can(AppPermissions.networkMembersChangeRole);
  @override
  bool get canChangeMemberStatus => PermissionService.to.can(AppPermissions.networkMembersChangeStatus);
  @override
  bool get canRemoveMember => PermissionService.to.can(AppPermissions.networkMembersDelete);
  @override
  String get searchHint => 'بحث باسم العضو، رقم الهاتف، أو المعرف...';
  @override
  int? get resolvedTenantId => initialNetworkId ?? WorkspaceService.to.savedActiveNetworkId;

  @override
  Future<PaginatedList<WorkspaceMemberEntity>> fetchMembersPage(
    int tenantId, {
    required String? search,
    required String? status,
    required String? cursor,
    required int perPage,
  }) => getNetworkMembersUseCase(tenantId, search: search, status: status, cursor: cursor, perPage: perPage);

  @override
  Future<List<MembershipRoleEntity>> fetchAssignableRolesForTenant(int tenantId) =>
      getNetworkAssignableRolesUseCase(tenantId);

  @override
  Future<void> addMemberToTenant(int tenantId, {required String phoneNumber, required int roleId, String? status}) async {
    await addNetworkMemberUseCase(networkId: tenantId, phoneNumber: phoneNumber, roleId: roleId, status: status);
  }

  @override
  Future<void> changeMemberRoleForTenant(int tenantId, WorkspaceMemberEntity member, int roleId, String? reason) async {
    await updateNetworkMemberRoleUseCase(networkId: tenantId, userId: member.userId, roleId: roleId, reason: reason);
  }

  @override
  Future<void> changeMemberStatusForTenant(int tenantId, WorkspaceMemberEntity member, String status, String? reason) async {
    await updateNetworkMemberStatusUseCase(networkId: tenantId, userId: member.userId, status: status, reason: reason);
  }

  @override
  Future<void> removeMemberFromTenant(int tenantId, WorkspaceMemberEntity member, String? reason) async {
    await removeNetworkMemberUseCase(networkId: tenantId, userId: member.userId, reason: reason);
  }
}
