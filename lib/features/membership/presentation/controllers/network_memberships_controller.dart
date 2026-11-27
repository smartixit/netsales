import 'dart:async';

import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
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
import 'package:netsales/features/membership/presentation/widgets/membership_action_dialogs.dart';
import 'package:netsales/features/membership/presentation/widgets/sheets/add_member_sheet.dart';
import 'package:netsales/features/membership/presentation/widgets/sheets/change_member_role_sheet.dart';
import 'package:netsales/features/membership/presentation/widgets/sheets/member_details_sheet.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

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

  int get totalMembersCount => _allMembers.length;
  int get activeMembersCount => _allMembers.where((m) => m.isActive).length;
  int get suspendedMembersCount =>
      _allMembers.where((m) => m.isSuspended).length;
  int get invitedMembersCount => _allMembers.where((m) => m.isInvited).length;

  bool get canViewMembers =>
      PermissionService.to.can(AppPermissions.networkMembersView);
  bool get canAddMember =>
      PermissionService.to.can(AppPermissions.networkMembersCreate);
  bool get canChangeMemberRole =>
      PermissionService.to.can(AppPermissions.networkMembersChangeRole);
  bool get canChangeMemberStatus =>
      PermissionService.to.can(AppPermissions.networkMembersChangeStatus);
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
  void openMemberDetails(WorkspaceMemberEntity member) {
    CustomBottomSheet.show<void>(
      title: 'الملف التعريفي للعضو',
      subtitle: 'تفاصيل الحساب والصلاحيات وتاريخ الانضمام',
      leadingIcon: Icons.badge_outlined,
      child: MemberDetailsSheet(
        member: member,
        onClose: () => Get.back<void>(),
      ),
    );
  }

  void openAddMemberSheet() {
    if (!canAddMember) return;
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController();
    final roleNotifier = ValueNotifier<int?>(
      assignableRoles.isNotEmpty ? assignableRoles.first.roleId : null,
    );
    final statusNotifier = ValueNotifier<String?>('ACTIVE');
    final isSubmitting = false.obs;

    CustomBottomSheet.show<void>(
      title: 'إضافة عضو جديد',
      subtitle: 'أدخل رقم هاتف العضو المسجل وحدد الدور والصلاحيات',
      leadingIcon: Icons.person_add_alt_1_rounded,
      child: AddMemberSheet(
        assignableRoles: assignableRoles,
        formKey: formKey,
        phoneController: phoneController,
        roleNotifier: roleNotifier,
        statusNotifier: statusNotifier,
        isSubmitting: isSubmitting,
        onSubmit: () async {
          if (!canAddMember) return;
          if (!formKey.currentState!.validate()) return;
          if (roleNotifier.value == null) {
            CustomSnackbar.show(
              title: 'تنبيه',
              message: 'يرجى اختيار الدور الوظيفي للعضو.',
              type: SnackType.warning,
            );
            return;
          }

          final networkId = resolvedNetworkId;
          if (networkId == null) return;

          isSubmitting.value = true;
          try {
            await addNetworkMemberUseCase(
              networkId: networkId,
              phoneNumber: phoneController.text.trim(),
              roleId: roleNotifier.value!,
              status: statusNotifier.value,
            );
            Get.back<void>();
            CustomSnackbar.show(
              title: 'تمت الإضافة بنجاح',
              message: 'تمت إضافة العضو للشبكة وتعيين الدور بنجاح.',
              type: SnackType.success,
            );
            await loadMembers();
          } catch (e) {
            CustomSnackbar.show(
              title: 'فشلت إضافة العضو',
              message: e.toString(),
              type: SnackType.error,
            );
          } finally {
            isSubmitting.value = false;
          }
        },
      ),
    ).whenComplete(() {
      phoneController.dispose();
      roleNotifier.dispose();
      statusNotifier.dispose();
    });
  }

  void openChangeRoleSheet(WorkspaceMemberEntity member) {
    if (!canChangeMemberRole) return;
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    final roleNotifier = ValueNotifier<int?>(
      assignableRoles.any((r) => r.roleId == member.roleId)
          ? member.roleId
          : (assignableRoles.isNotEmpty ? assignableRoles.first.roleId : null),
    );
    final isSubmitting = false.obs;

    CustomBottomSheet.show<void>(
      title: 'تعديل الدور الوظيفي',
      subtitle: 'ترقية أو تغيير صلاحيات ${member.displayFullName}',
      leadingIcon: Icons.manage_accounts_rounded,
      child: ChangeMemberRoleSheet(
        member: member,
        assignableRoles: assignableRoles,
        formKey: formKey,
        reasonController: reasonController,
        roleNotifier: roleNotifier,
        isSubmitting: isSubmitting,
        onSubmit: () async {
          if (!canChangeMemberRole) return;
          if (!formKey.currentState!.validate()) return;
          if (roleNotifier.value == null) {
            CustomSnackbar.show(
              title: 'تنبيه',
              message: 'يرجى اختيار الدور الجديد.',
              type: SnackType.warning,
            );
            return;
          }

          final networkId = resolvedNetworkId;
          if (networkId == null) return;

          isSubmitting.value = true;
          try {
            await updateNetworkMemberRoleUseCase(
              networkId: networkId,
              userId: member.userId,
              roleId: roleNotifier.value!,
              reason: reasonController.text.trim().isNotEmpty
                  ? reasonController.text.trim()
                  : null,
            );
            Get.back<void>();
            CustomSnackbar.show(
              title: 'تم تحديث الدور',
              message:
                  'تم تحديث دور وصلاحيات العضو ${member.displayFullName} بنجاح.',
              type: SnackType.success,
            );
            await loadMembers();
          } catch (e) {
            CustomSnackbar.show(
              title: 'فشل تحديث الدور',
              message: e.toString(),
              type: SnackType.error,
            );
          } finally {
            isSubmitting.value = false;
          }
        },
      ),
    ).whenComplete(() {
      reasonController.dispose();
      roleNotifier.dispose();
    });
  }

  void promptToggleMemberStatus(WorkspaceMemberEntity member) {
    if (!canChangeMemberStatus) return;
    final willSuspend = member.isActive;
    final nextStatus = willSuspend ? 'SUSPENDED' : 'ACTIVE';

    MembershipActionDialogs.showToggleStatusDialog(
      memberName: member.displayFullName,
      willSuspend: willSuspend,
      onConfirm: (reason) async {
          if (!canChangeMemberStatus) return;
        final networkId = resolvedNetworkId;
        if (networkId == null) return;

        try {
          await updateNetworkMemberStatusUseCase(
            networkId: networkId,
            userId: member.userId,
            status: nextStatus,
            reason: reason,
          );
          CustomSnackbar.show(
            title: willSuspend ? 'تم إيقاف العضوية' : 'تم تفعيل العضوية',
            message: willSuspend
                ? 'تم إيقاف صلاحيات ${member.displayFullName} مؤقتاً.'
                : 'تمت إعادة تفعيل حساب ${member.displayFullName} بنجاح.',
            type: SnackType.success,
          );
          await loadMembers();
        } catch (e) {
          CustomSnackbar.show(
            title: 'فشل تعديل حالة العضوية',
            message: e.toString(),
            type: SnackType.error,
          );
        }
      },
    );
  }

  void promptRemoveMember(WorkspaceMemberEntity member) {
    if (!canRemoveMember) return;
    MembershipActionDialogs.showRemoveMemberDialog(
      memberName: member.displayFullName,
      onConfirm: (reason) async {
          if (!canRemoveMember) return;
        final networkId = resolvedNetworkId;
        if (networkId == null) return;

        try {
          await removeNetworkMemberUseCase(
            networkId: networkId,
            userId: member.userId,
            reason: reason,
          );
          CustomSnackbar.show(
            title: 'تم إنهاء العضوية',
            message:
                'تمت إزالة ${member.displayFullName} من قائمة أعضاء الشبكة بنجاح.',
            type: SnackType.success,
          );
          await loadMembers();
        } catch (e) {
          CustomSnackbar.show(
            title: 'فشل إنهاء العضوية',
            message: e.toString(),
            type: SnackType.error,
          );
        }
      },
    );
  }
}
