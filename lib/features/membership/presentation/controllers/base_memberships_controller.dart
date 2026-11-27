import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// سلوك مشترك موحد لإدارة العضويات؛ تختلف الشبكة ونقطة البيع فقط في بوابات UseCases.
abstract class BaseMembershipsController extends GetxController {
  static const int pageSize = 20;
  String get pageTitle;
  String get pageSubtitle;
  IconData get pageIcon;
  String get searchHint;
  bool get isNetworkView;
  bool get canViewMembers;
  bool get canAddMember;
  bool get canChangeMemberRole;
  bool get canChangeMemberStatus;
  bool get canRemoveMember;
  int? get resolvedTenantId;

  Future<PaginatedList<WorkspaceMemberEntity>> fetchMembersPage(
    int tenantId, {
    required String? search,
    required String? status,
    required String? cursor,
    required int perPage,
  });
  Future<List<MembershipRoleEntity>> fetchAssignableRolesForTenant(int tenantId);
  Future<void> addMemberToTenant(int tenantId, {
    required String phoneNumber,
    required int roleId,
    String? status,
  });
  Future<void> changeMemberRoleForTenant(int tenantId, WorkspaceMemberEntity member, int roleId, String? reason);
  Future<void> changeMemberStatusForTenant(int tenantId, WorkspaceMemberEntity member, String status, String? reason);
  Future<void> removeMemberFromTenant(int tenantId, WorkspaceMemberEntity member, String? reason);

  final RxList<WorkspaceMemberEntity> members = <WorkspaceMemberEntity>[].obs;
  final RxList<MembershipRoleEntity> assignableRoles = <MembershipRoleEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString loadMoreError = RxnString();
  final RxnString statusFilter = RxnString();
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxnInt expandedMemberId = RxnInt();
  final RxnString _nextCursor = RxnString();

  Worker? _searchWorker;
  int _listRevision = 0;
  String? _lastRequestedSearch;
  String? _lastRequestedStatus;
  int? _lastRequestedTenantId;
  int _totalMembersCount = 0;
  int _activeMembersCount = 0;
  int _suspendedMembersCount = 0;
  int _invitedMembersCount = 0;

  bool get hasMore => _nextCursor.value?.isNotEmpty == true;
  int get totalMembersCount => _totalMembersCount;
  int get activeMembersCount => _activeMembersCount;
  int get suspendedMembersCount => _suspendedMembersCount;
  int get invitedMembersCount => _invitedMembersCount;

  List<CustomSearchFilterOption<String?>> get filterOptions => [
    const CustomSearchFilterOption<String?>(label: 'جميع الحالات', value: null, icon: Icons.all_inbox_rounded),
    for (final status in MembershipStatus.values.where((status) => status != MembershipStatus.unknown))
      CustomSearchFilterOption<String?>(
        label: EnumPresentationRegistry.resolveMembershipStatus(status).label,
        value: status.wireValue,
        icon: EnumPresentationRegistry.resolveMembershipStatus(status).icon ?? Icons.label_outline_rounded,
      ),
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_syncSearchQuery);
    _startSearchDebounce();
    unawaited(loadInitialData());
  }

  @override
  void onClose() {
    _listRevision++;
    _searchWorker?.dispose();
    searchController.removeListener(_syncSearchQuery);
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() => refreshMembers();

  Future<void> refreshMembers() async {
    await Future.wait([loadMembers(), loadAssignableRoles()]);
  }

  Future<void> loadMembers() async {
    final revision = ++_listRevision;
    final tenantId = resolvedTenantId;
    if (tenantId == null) {
      members.clear();
      _nextCursor.value = null;
      _resetSummary();
      isLoading.value = false;
      isLoadingMore.value = false;
      loadMoreError.value = null;
      errorMessage.value = 'لم يتم تحديد ${isNetworkView ? 'شبكة' : 'نقطة بيع'} نشطة لعرض أعضائها.';
      return;
    }

    final search = searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim();
    final status = statusFilter.value;
    final queryChanged = _lastRequestedSearch != search ||
        _lastRequestedStatus != status ||
        _lastRequestedTenantId != tenantId;

    isLoading.value = true;
    errorMessage.value = null;
    loadMoreError.value = null;
    isLoadingMore.value = false;
    if (queryChanged) members.clear();
    _lastRequestedSearch = search;
    _lastRequestedStatus = status;
    _lastRequestedTenantId = tenantId;
    _nextCursor.value = null;

    try {
      final page = await fetchMembersPage(
        tenantId,
        search: search,
        status: status,
        cursor: null,
        perPage: pageSize,
      );
      if (revision != _listRevision ||
          tenantId != resolvedTenantId ||
          search != _currentSearchQuery ||
          status != statusFilter.value) return;
      members.assignAll(page.items);
      _nextCursor.value = page.nextCursor;
      _applySummary(page);
    } catch (error) {
      if (revision != _listRevision ||
          tenantId != resolvedTenantId ||
          search != _currentSearchQuery ||
          status != statusFilter.value) return;
      if (members.isEmpty) {
        errorMessage.value = error.toString();
      } else {
        loadMoreError.value = error.toString();
      }
    } finally {
      if (revision == _listRevision) isLoading.value = false;
    }
  }

  Future<void> loadMoreMembers() async {
    final tenantId = resolvedTenantId;
    final cursor = _nextCursor.value;
    final search = _currentSearchQuery;
    final status = statusFilter.value;
    if (tenantId == null || cursor == null || cursor.isEmpty || isLoading.value || isLoadingMore.value ||
        _lastRequestedSearch != search || _lastRequestedStatus != status) return;
    final revision = _listRevision;
    isLoadingMore.value = true;
    loadMoreError.value = null;
    try {
      final page = await fetchMembersPage(
        tenantId,
        search: search,
        status: status,
        cursor: cursor,
        perPage: pageSize,
      );
      if (revision != _listRevision || tenantId != resolvedTenantId ||
          search != _currentSearchQuery || status != statusFilter.value) return;
      final knownIds = members.map((member) => member.id).toSet();
      members.addAll(page.items.where((member) => knownIds.add(member.id)));
      _nextCursor.value = page.nextCursor == cursor ? null : page.nextCursor;
    } catch (error) {
      if (revision == _listRevision) loadMoreError.value = error.toString();
    } finally {
      if (revision == _listRevision) isLoadingMore.value = false;
    }
  }

  Future<void> loadAssignableRoles() async {
    final tenantId = resolvedTenantId;
    if (tenantId == null) {
      assignableRoles.clear();
      return;
    }
    try {
      final roles = await fetchAssignableRolesForTenant(tenantId);
      if (tenantId != resolvedTenantId) return;
      final scope = isNetworkView ? RoleScope.network : RoleScope.pos;
      final allowed = isNetworkView
          ? {RoleKey.networkUser, RoleKey.networkAccountant}
          : {RoleKey.posUser, RoleKey.posAccountant};
      assignableRoles.assignAll(roles.where((role) => role.typedScope == scope && allowed.contains(role.typedRoleKey)));
    } catch (_) {
      // Keep the last valid role list after a transient failure.
    }
  }

  void setStatusFilter(String? status) {
    if (statusFilter.value == status) return;
    _searchWorker?.dispose();
    statusFilter.value = status;
    _startSearchDebounce();
    unawaited(loadMembers());
  }

  void resetFilters() {
    _searchWorker?.dispose();
    statusFilter.value = null;
    searchController.clear();
    searchQuery.value = '';
    _startSearchDebounce();
    unawaited(loadMembers());
  }

  void toggleAccordion(int memberId) {
    expandedMemberId.value = expandedMemberId.value == memberId ? null : memberId;
  }

  Future<void> addMember({required String phoneNumber, required int roleId, String? status}) async {
    if (!canAddMember) {
      throw AppException('لا تملك صلاحية إضافة أعضاء إلى ${isNetworkView ? 'الشبكة' : 'نقطة البيع'}.');
    }
    await addMemberToTenant(_requireTenantId(), phoneNumber: phoneNumber, roleId: roleId, status: status);
    await loadMembers();
  }

  Future<void> changeMemberRole(WorkspaceMemberEntity member, int roleId, String? reason) async {
    if (!canChangeMemberRole || member.isOwner) throw const AppException('لا تملك صلاحية تغيير دور هذا العضو.');
    await changeMemberRoleForTenant(_requireTenantId(), member, roleId, reason);
    await loadMembers();
  }

  Future<void> changeMemberStatus(WorkspaceMemberEntity member, String status, String? reason) async {
    if (!canChangeMemberStatus || member.isOwner) throw const AppException('لا تملك صلاحية تغيير حالة هذا العضو.');
    await changeMemberStatusForTenant(_requireTenantId(), member, status, reason);
    await loadMembers();
  }

  Future<void> removeMember(WorkspaceMemberEntity member, String? reason) async {
    if (!canRemoveMember || member.isOwner) throw const AppException('لا تملك صلاحية إنهاء عضوية هذا العضو.');
    await removeMemberFromTenant(_requireTenantId(), member, reason);
    await loadMembers();
  }

  int _requireTenantId() {
    final tenantId = resolvedTenantId;
    if (tenantId == null) {
      throw AppException('تعذر تحديد ${isNetworkView ? 'الشبكة' : 'نقطة البيع'} النشطة.');
    }
    return tenantId;
  }

  void _startSearchDebounce() {
    _searchWorker = debounce(
      searchQuery,
      (_) => unawaited(loadMembers()),
      time: const Duration(milliseconds: 350),
    );
  }

  String? get _currentSearchQuery =>
      searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim();

  void _syncSearchQuery() {
    final nextQuery = searchController.text;
    if (searchQuery.value == nextQuery) return;
    searchQuery.value = nextQuery;
    _nextCursor.value = null;
  }

  void _applySummary(PaginatedList<WorkspaceMemberEntity> page) {
    final summary = page.meta?['summary'];
    if (summary is Map) {
      _totalMembersCount = _readCount(summary['total']);
      _activeMembersCount = _readCount(summary['active']);
      _suspendedMembersCount = _readCount(summary['suspended']);
      _invitedMembersCount = _readCount(summary['invited']);
      return;
    }
    _totalMembersCount = page.items.length;
    _activeMembersCount = page.items.where((member) => member.isActive).length;
    _suspendedMembersCount = page.items.where((member) => member.isSuspended).length;
    _invitedMembersCount = page.items.where((member) => member.isInvited).length;
  }

  int _readCount(dynamic value) => value is num ? value.toInt() : 0;

  void _resetSummary() {
    _totalMembersCount = 0;
    _activeMembersCount = 0;
    _suspendedMembersCount = 0;
    _invitedMembersCount = 0;
  }
}
