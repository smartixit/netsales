import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/usecases/network/add_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/network/get_network_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/network/get_network_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/network/remove_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/network/update_network_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/network/update_network_member_status_use_case.dart';
import 'package:netsales/features/membership/presentation/widgets/membership_action_dialogs.dart';
import 'package:netsales/features/membership/presentation/widgets/sheets/add_member_sheet.dart';
import 'package:netsales/features/membership/presentation/widgets/sheets/change_member_role_sheet.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم إدارة أعضاء وفريق شبكة التزويد (NetworkMembersController)
///
/// المالك الحصري لكافة المتغيرات وحالات التحميل والنماذج والمنطق التشغيلي.
class NetworkMembersController extends GetxController {
  NetworkMembersController({
    required this.getMyNetworksUseCase,
    required this.getNetworkMembersUseCase,
    required this.getNetworkAssignableRolesUseCase,
    required this.addNetworkMemberUseCase,
    required this.updateNetworkMemberRoleUseCase,
    required this.updateNetworkMemberStatusUseCase,
    required this.removeNetworkMemberUseCase,
  });

  final GetMyNetworksUseCase getMyNetworksUseCase;
  final GetNetworkMembersUseCase getNetworkMembersUseCase;
  final GetNetworkAssignableRolesUseCase getNetworkAssignableRolesUseCase;
  final AddNetworkMemberUseCase addNetworkMemberUseCase;
  final UpdateNetworkMemberRoleUseCase updateNetworkMemberRoleUseCase;
  final UpdateNetworkMemberStatusUseCase updateNetworkMemberStatusUseCase;
  final RemoveNetworkMemberUseCase removeNetworkMemberUseCase;

  // ── الحالة الأساسية والبيانات ──
  final members = <WorkspaceMemberEntity>[].obs;
  final roles = <MembershipRoleEntity>[].obs;
  final authorizedNetworks = <NetworkEntity>[].obs;
  final selectedNetworkId = RxnInt();

  // ── حالات التحميل والأخطاء ──
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  // ── البحث والتصفية ──
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnString();

  // ── حالة الأكورديون التفاعلي ──
  final expandedMemberId = RxnInt();

  // ── إدارة نماذج الإدخال المركزية ──
  final addMemberFormKey = GlobalKey<FormState>();
  final changeRoleFormKey = GlobalKey<FormState>();
  final phoneInputController = TextEditingController();
  final selectedRoleId = RxnInt();

  int _memberListRevision = 0;

  // ── صلاحيات التحكم التشغيلية ──
  bool get canManageMembers =>
      PermissionService.to.can(AppPermissions.usersCreate);

  // ── مؤشرات الأداء المحسوبة (KPI Counters) بنمط تسمية موحد مع وحدة الطلبات ──
  int get totalMembersCount => members.length;
  int get activeMembersCount => members.where((m) => m.isActive).length;
  int get suspendedMembersCount => members.where((m) => m.isSuspended).length;
  int get invitedMembersCount => members.where((m) => m.isInvited).length;

  /// القائمة المصفاة لحظياً وفق التصفية والبحث
  List<WorkspaceMemberEntity> get filteredMembers {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = statusFilter.value;

    return members.where((m) {
      if (filter != null && m.statusRaw != filter) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchName = m.fullName.toLowerCase().contains(query);
        final matchPhone = m.phoneNumber.toLowerCase().contains(query);
        final matchRole = m.roleLabel?.toLowerCase().contains(query) ?? false;
        return matchName || matchPhone || matchRole;
      }
      return true;
    }).toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    loadNetworks();
  }

  @override
  void onClose() {
    _memberListRevision++;
    searchController.dispose();
    phoneInputController.dispose();
    super.onClose();
  }

  /// تحميل شبكات المستخدم وتحديد الشبكة النشطة من WorkspaceService
  Future<void> loadNetworks() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final list = await getMyNetworksUseCase();
      authorizedNetworks.assignAll(list);

      final activeId = WorkspaceService.to.savedActiveNetworkId;
      if (activeId != null && list.any((n) => n.networkId == activeId)) {
        selectedNetworkId.value = activeId;
      } else if (list.isNotEmpty) {
        selectedNetworkId.value = list.first.networkId;
      }

      if (selectedNetworkId.value != null) {
        await loadMembers();
      }
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر استرجاع شبكات التزويد المخولة.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير الشبكة المختارة
  Future<void> onNetworkChanged(int? networkId) async {
    if (networkId == null || selectedNetworkId.value == networkId) return;
    selectedNetworkId.value = networkId;
    members.clear();
    roles.clear();
    expandedMemberId.value = null;
    await loadMembers();
  }

  /// تحديث قائمة الأعضاء
  Future<void> refreshMembers() => loadMembers(isRefresh: true);

  /// جلب أعضاء الشبكة والأدوار المسموح بإسنادها
  Future<void> loadMembers({bool isRefresh = false}) async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;

    final revision = ++_memberListRevision;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final results = await Future.wait([
        getNetworkMembersUseCase(networkId),
        getNetworkAssignableRolesUseCase(networkId),
      ]);

      if (revision != _memberListRevision) return;

      members.assignAll(results[0] as List<WorkspaceMemberEntity>);
      roles.assignAll(results[1] as List<MembershipRoleEntity>);
    } catch (error) {
      if (revision == _memberListRevision) {
        errorMessage.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر استرجاع فريق عمل الشبكة.',
        );
      }
    } finally {
      if (revision == _memberListRevision) {
        isLoading.value = false;
      }
    }
  }

  /// ضبط فلتر الحالة
  void setStatusFilter(String? status) {
    statusFilter.value = statusFilter.value == status ? null : status;
  }

  /// إعادة تعيين كافة الفلاتر والبحث
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
  }

  /// فتح/طي أكورديون بطاقة العضو
  void toggleAccordion(int userId) {
    expandedMemberId.value =
        expandedMemberId.value == userId ? null : userId;
  }

  /// فتح شيت إضافة عضو جديد
  void openAddMemberSheet() {
    final networkId = selectedNetworkId.value;
    if (networkId == null) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يرجى تحديد الشبكة أولاً.',
        type: SnackType.warning,
      );
      return;
    }

    phoneInputController.clear();
    selectedRoleId.value = roles.isNotEmpty ? roles.first.roleId : null;

    CustomBottomSheet.show<void>(
      title: 'إضافة عضو جديد للشبكة',
      subtitle: 'أدخل رقم هاتف المستخدم وحدد الدور الوظيفي المعتمد',
      child: AddMemberSheet(
        formKey: addMemberFormKey,
        phoneController: phoneInputController,
        selectedRoleId: selectedRoleId,
        roles: roles,
        isSubmitting: isSubmitting,
        onSubmit: submitAddMember,
      ),
    );
  }

  /// إرسال نموذج إضافة عضو
  Future<void> submitAddMember() async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;

    if (!addMemberFormKey.currentState!.validate()) return;
    final roleId = selectedRoleId.value;
    if (roleId == null) {
      CustomSnackbar.show(
        title: 'بيانات ناقصة',
        message: 'يرجى تحديد الدور الوظيفي للعضو.',
        type: SnackType.warning,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final newMember = await addNetworkMemberUseCase(
        networkId: networkId,
        phoneNumber: phoneInputController.text.trim(),
        roleId: roleId,
      );

      Get.back<void>();
      members.removeWhere((m) => m.userId == newMember.userId);
      members.insert(0, newMember);

      CustomSnackbar.show(
        title: 'تمت الإضافة بنجاح',
        message: 'تمت إضافة "${newMember.fullName}" إلى فريق عمل الشبكة.',
        type: SnackType.success,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'تعذر إضافة العضو',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'تأكد من رقم هاتف المستخدم وأعد المحاولة.',
        ),
        type: SnackType.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// فتح شيت تعديل دور العضو
  void openChangeRoleSheet(WorkspaceMemberEntity member) {
    if (member.isOwner) {
      CustomSnackbar.show(
        title: 'إجراء غير متاح',
        message: 'لا يمكن تعديل الدور الوظيفي للمالك الرئيسي للشبكة.',
        type: SnackType.warning,
      );
      return;
    }

    selectedRoleId.value = member.roleId;

    CustomBottomSheet.show<void>(
      title: 'تعديل دور العضو',
      subtitle: 'تعديل الصلاحيات الوظيفية لـ "${member.fullName}"',
      child: ChangeMemberRoleSheet(
        formKey: changeRoleFormKey,
        selectedRoleId: selectedRoleId,
        roles: roles,
        isSubmitting: isSubmitting,
        onSubmit: () => submitChangeRole(member),
      ),
    );
  }

  /// إرسال نموذج تعديل دور العضو
  Future<void> submitChangeRole(WorkspaceMemberEntity member) async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;

    final newRoleId = selectedRoleId.value;
    if (newRoleId == null) return;

    if (newRoleId == member.roleId) {
      Get.back<void>();
      return;
    }

    try {
      isSubmitting.value = true;
      final updated = await updateNetworkMemberRoleUseCase(
        networkId: networkId,
        userId: member.userId,
        roleId: newRoleId,
      );

      Get.back<void>();
      final index = members.indexWhere((m) => m.userId == member.userId);
      if (index != -1) {
        members[index] = updated;
      }

      CustomSnackbar.show(
        title: 'تم تعديل الدور',
        message: 'تم تحديث صلاحيات العضو "${member.fullName}" بنجاح.',
        type: SnackType.success,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'تعذر تعديل الدور',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'حدث خطأ أثناء تعديل دور العضو.',
        ),
        type: SnackType.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// حوار تأكيد وتغيير حالة العضوية
  Future<void> promptToggleMemberStatus(WorkspaceMemberEntity member) async {
    if (member.isOwner) {
      CustomSnackbar.show(
        title: 'إجراء غير متاح',
        message: 'لا يمكن تجميد أو إيقاف حساب المالك الرئيسي للشبكة.',
        type: SnackType.warning,
      );
      return;
    }

    final networkId = selectedNetworkId.value;
    if (networkId == null) return;

    await MembershipActionDialogs.showToggleStatusDialog(
      memberName: member.fullName,
      isCurrentlyActive: member.isActive,
      onConfirm: () async {
        try {
          final updated = await updateNetworkMemberStatusUseCase(
            networkId: networkId,
            userId: member.userId,
            status: member.isActive
                ? MembershipStatus.suspended.wireValue
                : MembershipStatus.active.wireValue,
          );

          final index = members.indexWhere((m) => m.userId == member.userId);
          if (index != -1) {
            members[index] = updated;
          }

          CustomSnackbar.show(
            title: 'تم تحديث الحالة',
            message: member.isActive
                ? 'تم تجميد عضوية "${member.fullName}" بنجاح.'
                : 'تمت إعادة تفعيل عضوية "${member.fullName}" بنجاح.',
            type: SnackType.success,
          );
        } catch (error) {
          CustomSnackbar.show(
            title: 'فشل تحديث الحالة',
            message: AppException.sanitizeMessage(
              error,
              fallback: 'تعذر تحديث حالة العضوية.',
            ),
            type: SnackType.error,
          );
        }
      },
    );
  }

  /// حوار تأكيد وحذف العضو
  Future<void> promptRemoveMember(WorkspaceMemberEntity member) async {
    if (member.isOwner) {
      CustomSnackbar.show(
        title: 'إجراء غير متاح',
        message: 'لا يمكن حذف المالك الرئيسي من شبكة التزويد.',
        type: SnackType.warning,
      );
      return;
    }

    final networkId = selectedNetworkId.value;
    if (networkId == null) return;

    await MembershipActionDialogs.showRemoveMemberDialog(
      memberName: member.fullName,
      onConfirm: () async {
        try {
          await removeNetworkMemberUseCase(
            networkId: networkId,
            userId: member.userId,
          );

          members.removeWhere((m) => m.userId == member.userId);
          if (expandedMemberId.value == member.userId) {
            expandedMemberId.value = null;
          }

          CustomSnackbar.show(
            title: 'تم الحذف',
            message: 'تم استبعاد "${member.fullName}" من شبكة التزويد.',
            type: SnackType.info,
          );
        } catch (error) {
          CustomSnackbar.show(
            title: 'تعذر حذف العضو',
            message: AppException.sanitizeMessage(
              error,
              fallback: 'حدث خطأ أثناء محاولة استبعاد العضو.',
            ),
            type: SnackType.error,
          );
        }
      },
    );
  }
}
