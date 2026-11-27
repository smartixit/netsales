import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/usecases/add_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_pos_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_pos_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/remove_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_pos_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_pos_member_status_use_case.dart';
import 'package:netsales/features/membership/presentation/controllers/base_memberships_controller.dart';

class PosMembershipsController extends BaseMembershipsController {
  PosMembershipsController({
    required this.getPosMembersUseCase,
    required this.getPosAssignableRolesUseCase,
    required this.addPosMemberUseCase,
    required this.updatePosMemberRoleUseCase,
    required this.updatePosMemberStatusUseCase,
    required this.removePosMemberUseCase,
    this.initialPosId,
  });

  final GetPosMembersUseCase getPosMembersUseCase;
  final GetPosAssignableRolesUseCase getPosAssignableRolesUseCase;
  final AddPosMemberUseCase addPosMemberUseCase;
  final UpdatePosMemberRoleUseCase updatePosMemberRoleUseCase;
  final UpdatePosMemberStatusUseCase updatePosMemberStatusUseCase;
  final RemovePosMemberUseCase removePosMemberUseCase;
  final int? initialPosId;

  @override
  String get pageTitle => 'إدارة طاقم نقطة البيع';
  @override
  String get pageSubtitle => 'متابعة وإدارة حسابات العاملين بنقطة البيع، صلاحيات التشغيل، وتفعيل العضويات فورياً.';
  @override
  IconData get pageIcon => Icons.storefront_rounded;
  @override
  bool get isNetworkView => false;
  @override
  bool get canViewMembers => PermissionService.to.can(AppPermissions.posMembersView);
  @override
  bool get canAddMember => PermissionService.to.can(AppPermissions.posMembersCreate);
  @override
  bool get canChangeMemberRole => PermissionService.to.can(AppPermissions.posMembersChangeRole);
  @override
  bool get canChangeMemberStatus => PermissionService.to.can(AppPermissions.posMembersChangeStatus);
  @override
  bool get canRemoveMember => PermissionService.to.can(AppPermissions.posMembersDelete);
  @override
  String get searchHint => 'بحث باسم العضو، رقم الهاتف، أو المعرف...';
  @override
  int? get resolvedTenantId => initialPosId ?? WorkspaceService.to.savedActivePosId;

  @override
  Future<PaginatedList<WorkspaceMemberEntity>> fetchMembersPage(
    int tenantId, {
    required String? search,
    required String? status,
    required String? cursor,
    required int perPage,
  }) => getPosMembersUseCase(tenantId, search: search, status: status, cursor: cursor, perPage: perPage);

  @override
  Future<List<MembershipRoleEntity>> fetchAssignableRolesForTenant(int tenantId) =>
      getPosAssignableRolesUseCase(tenantId);

  @override
  Future<void> addMemberToTenant(int tenantId, {required String phoneNumber, required int roleId, String? status}) async {
    await addPosMemberUseCase(posId: tenantId, phoneNumber: phoneNumber, roleId: roleId, status: status);
  }

  @override
  Future<void> changeMemberRoleForTenant(int tenantId, WorkspaceMemberEntity member, int roleId, String? reason) async {
    await updatePosMemberRoleUseCase(posId: tenantId, userId: member.userId, roleId: roleId, reason: reason);
  }

  @override
  Future<void> changeMemberStatusForTenant(int tenantId, WorkspaceMemberEntity member, String status, String? reason) async {
    await updatePosMemberStatusUseCase(posId: tenantId, userId: member.userId, status: status, reason: reason);
  }

  @override
  Future<void> removeMemberFromTenant(int tenantId, WorkspaceMemberEntity member, String? reason) async {
    await removePosMemberUseCase(posId: tenantId, userId: member.userId, reason: reason);
  }
}
