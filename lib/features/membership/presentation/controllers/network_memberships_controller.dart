import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
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
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// متحكم إدارة أعضاء وموظفي الشبكة (Network Memberships Controller)
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
  String get pageSubtitle =>
      'إدارة وتعيين صلاحيات موظفي ومشغلي الشبكة، والتحكم بحالات تفعيل العضويات فورياً.';

  @override
  IconData get pageIcon => Icons.people_alt_rounded;

  @override
  bool get isNetworkView => true;

  @override
  String get searchHint => 'بحث باسم العضو، رقم الهاتف، أو المعرف...';

  @override
  List<CustomSearchFilterOption<String?>> buildFilterOptions() {
    return [
      const CustomSearchFilterOption<String?>(
        label: 'جميع الحالات',
        value: null,
        icon: Icons.all_inbox_rounded,
      ),
      for (final MembershipStatus status in MembershipStatus.values.where(
        (MembershipStatus s) => s != MembershipStatus.unknown,
      ))
        CustomSearchFilterOption<String?>(
          label: EnumPresentationRegistry.resolveMembershipStatus(status).label,
          value: status.wireValue,
          icon: EnumPresentationRegistry.resolveMembershipStatus(status).icon ??
              Icons.label_outline_rounded,
        ),
    ];
  }

  // ── الحالة التفاعلية ──
  final _allMembers = <WorkspaceMemberEntity>[].obs;
  @override
  final members = <WorkspaceMemberEntity>[].obs;
  @override
  final assignableRoles = <MembershipRoleEntity>[].obs;

  @override
  final isLoading = true.obs;
  @override
  final errorMessage = RxnString();
  @override
  final statusFilter = RxnString();
  @override
  final searchQuery = ''.obs;
  @override
  final searchController = TextEditingController();
  @override
  final expandedMemberId = RxnInt();

  int _listRevision = 0;

  @override
  int get totalMembersCount => _allMembers.length;
  @override
  int get activeMembersCount => _allMembers.where((m) => m.isActive).length;
  @override
  int get suspendedMembersCount =>
      _allMembers.where((m) => m.isSuspended).length;
  @override
  int get invitedMembersCount => _allMembers.where((m) => m.isInvited).length;

  bool get canViewMembers =>
      PermissionService.to.can(AppPermissions.networkMembersView);
  @override
  bool get canAddMember =>
      PermissionService.to.can(AppPermissions.networkMembersCreate);
  @override
  bool get canChangeMemberRole =>
      PermissionService.to.can(AppPermissions.networkMembersChangeRole);
  @override
  bool get canChangeMemberStatus =>
      PermissionService.to.can(AppPermissions.networkMembersChangeStatus);
  @override
  bool get canRemoveMember =>
      PermissionService.to.can(AppPermissions.networkMembersDelete);

  int? get resolvedNetworkId => initialNetworkId ?? WorkspaceService.to.savedActiveNetworkId;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    debounce(
      searchQuery,
      (_) => _applyFilters(),
      time: const Duration(milliseconds: 350),
    );
    loadInitialData();
  }

  @override
  void onClose() {
    _listRevision++;
    searchController.dispose();
    super.onClose();
  }

  @override
  Future<void> refreshMembers() async {
    await Future.wait([loadMembers(), loadAssignableRoles()]);
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = null;
    await refreshMembers();
  }

  Future<void> loadMembers() async {
    final revision = ++_listRevision;
    final networkId = resolvedNetworkId;
    if (networkId == null) {
      isLoading.value = false;
      errorMessage.value = 'لم يتم تحديد شبكة نشطة لعرض أعضائها.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await getNetworkMembersUseCase(networkId);
      if (revision != _listRevision) return;
      _allMembers.assignAll(result);
      _applyFilters();
    } catch (e) {
      if (revision != _listRevision) return;
      errorMessage.value = 'تعذر استرجاع أعضاء الشبكة: ${e.toString()}';
    } finally {
      if (revision == _listRevision) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadAssignableRoles() async {
    final networkId = resolvedNetworkId;
    if (networkId == null) return;

    try {
      final roles = await getNetworkAssignableRolesUseCase(networkId);
      assignableRoles.assignAll(
        roles.where(
          (role) =>
              role.typedScope == RoleScope.network &&
              (role.typedRoleKey == RoleKey.networkUser ||
                  role.typedRoleKey == RoleKey.networkAccountant),
        ),
      );
    } catch (_) {
      // Fallback
    }
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = statusFilter.value;

    final filtered = _allMembers
        .where((member) {
          final matchesStatus =
              filter == null || member.status.wireValue == filter;
          final matchesQuery =
              query.isEmpty ||
              member.displayFullName.toLowerCase().contains(query) ||
              member.displayPhoneNumber.contains(query) ||
              member.displayReference.toLowerCase().contains(query) ||
              member.displayRoleName.toLowerCase().contains(query);

          return matchesStatus && matchesQuery;
        })
        .toList(growable: false);

    members.assignAll(filtered);
  }

  @override
  void setStatusFilter(String? status) {
    statusFilter.value = status;
    _applyFilters();
  }

  @override
  void resetFilters() {
    statusFilter.value = null;
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  @override
  void toggleAccordion(int memberId) {
    if (expandedMemberId.value == memberId) {
      expandedMemberId.value = null;
    } else {
      expandedMemberId.value = memberId;
    }
  }

  @override
  Future<void> addMember({
    required String phoneNumber,
    required int roleId,
    String? status,
  }) async {
    if (!canAddMember) {
      throw const AppException('لا تملك صلاحية إضافة أعضاء إلى شبكة.');
    }
    final networkId = resolvedNetworkId;
    if (networkId == null) {
      throw const AppException('تعذر تحديد شبكة النشطة.');
    }
    await addNetworkMemberUseCase(
      networkId: networkId,
      phoneNumber: phoneNumber,
      roleId: roleId,
      status: status,
    );
    await loadMembers();
  }

  @override
  Future<void> changeMemberRole(
    WorkspaceMemberEntity member,
    int roleId,
    String? reason,
  ) async {
    if (!canChangeMemberRole || member.isOwner) {
      throw const AppException('لا تملك صلاحية تغيير دور هذا العضو.');
    }
    final networkId = resolvedNetworkId;
    if (networkId == null) {
      throw const AppException('تعذر تحديد شبكة النشطة.');
    }
    await updateNetworkMemberRoleUseCase(
      networkId: networkId,
      userId: member.userId,
      roleId: roleId,
      reason: reason,
    );
    await loadMembers();
  }

  @override
  Future<void> changeMemberStatus(
    WorkspaceMemberEntity member,
    String status,
    String? reason,
  ) async {
    if (!canChangeMemberStatus || member.isOwner) {
      throw const AppException('لا تملك صلاحية تغيير حالة هذا العضو.');
    }
    final networkId = resolvedNetworkId;
    if (networkId == null) {
      throw const AppException('تعذر تحديد شبكة النشطة.');
    }
    await updateNetworkMemberStatusUseCase(
      networkId: networkId,
      userId: member.userId,
      status: status,
      reason: reason,
    );
    await loadMembers();
  }

  @override
  Future<void> removeMember(
    WorkspaceMemberEntity member,
    String? reason,
  ) async {
    if (!canRemoveMember || member.isOwner) {
      throw const AppException('لا تملك صلاحية إنهاء عضوية هذا العضو.');
    }
    final networkId = resolvedNetworkId;
    if (networkId == null) {
      throw const AppException('تعذر تحديد شبكة النشطة.');
    }
    await removeNetworkMemberUseCase(
      networkId: networkId,
      userId: member.userId,
      reason: reason,
    );
    await loadMembers();
  }

}
