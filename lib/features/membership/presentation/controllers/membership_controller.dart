import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/membership/domain/entities/membership_entity.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/usecases/membership_use_cases.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class MembershipController extends GetxController {
  MembershipController({
    required this.isNetwork,
    required this.getMyNetworks,
    required this.getMyPos,
    required this.getMembers,
    required this.getRoles,
    required this.addMember,
    required this.updateRole,
    required this.updateStatus,
    required this.removeMember,
  });
  final bool isNetwork;
  final GetMyNetworksUseCase getMyNetworks;
  final GetMyPosUseCase getMyPos;
  final GetMembersUseCase getMembers;
  final GetAssignableMembershipRolesUseCase getRoles;
  final AddMembershipUseCase addMember;
  final UpdateMembershipRoleUseCase updateRole;
  final UpdateMembershipStatusUseCase updateStatus;
  final RemoveMembershipUseCase removeMember;
  final networks = <NetworkEntity>[].obs;
  final positions = <PosEntity>[].obs;
  final members = <MembershipEntity>[].obs;
  final roles = <MembershipRoleEntity>[].obs;
  final RxnInt selectedTenantId = RxnInt();
  final isLoadingTenants = false.obs;
  final isLoading = false.obs;
  final isMutating = false.obs;
  final errorMessage = RxnString();
  final phoneController = TextEditingController();
  final RxnInt selectedRoleId = RxnInt();
  int _loadGeneration = 0;
  String get tenantLabel => isNetwork ? 'الشبكة' : 'نقطة البيع';

  @override
  void onInit() {
    super.onInit();
    loadTenants();
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> loadTenants() async {
    isLoadingTenants.value = true;
    errorMessage.value = null;
    try {
      if (isNetwork) {
        networks.assignAll(await getMyNetworks());
        if (networks.length == 1)
          selectedTenantId.value = networks.first.networkId;
      } else {
        positions.assignAll(await getMyPos());
        if (positions.length == 1)
          selectedTenantId.value = positions.first.posId;
      }
      if (selectedTenantId.value != null) await loadMembers();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل المنشآت التابعة لحسابك.',
      );
    } finally {
      isLoadingTenants.value = false;
    }
  }

  Future<void> selectTenant(int? id) async {
    if (id == null || selectedTenantId.value == id) return;
    selectedTenantId.value = id;
    members.clear();
    roles.clear();
    await loadMembers();
  }

  Future<void> loadMembers() async {
    final id = selectedTenantId.value;
    if (id == null) return;
    final generation = ++_loadGeneration;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final memberRows = await getMembers(isNetwork, id);
      final roleRows = await getRoles(isNetwork, id);
      if (generation != _loadGeneration || selectedTenantId.value != id) return;
      members.assignAll(memberRows);
      roles.assignAll(roleRows);
    } catch (error) {
      if (generation == _loadGeneration) {
        errorMessage.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل أعضاء $tenantLabel.',
        );
      }
    } finally {
      if (generation == _loadGeneration) isLoading.value = false;
    }
  }

  Future<void> add() async {
    final id = selectedTenantId.value;
    final phone = phoneController.text.trim();
    final roleId = selectedRoleId.value;
    if (id == null || phone.isEmpty || roleId == null) {
      CustomSnackbar.show(
        title: 'بيانات ناقصة',
        message: 'أدخل رقم الهاتف وحدد الدور التشغيلي.',
        type: SnackType.warning,
      );
      return;
    }
    await _mutate('جارٍ إضافة العضو...', () async {
      await addMember(isNetwork, id, phone, roleId);
      phoneController.clear();
      selectedRoleId.value = null;
      await loadMembers();
    }, 'تمت إضافة العضو بنجاح.');
  }

  Future<void> changeRole(MembershipEntity member, int roleId) async {
    final id = selectedTenantId.value;
    if (id == null || member.isOwner) return;
    await _mutate('جارٍ تحديث دور العضو...', () async {
      await updateRole(isNetwork, id, member.userId, roleId);
      await loadMembers();
    }, 'تم تحديث دور العضو.');
  }

  Future<void> toggleStatus(MembershipEntity member) async {
    final id = selectedTenantId.value;
    if (id == null || member.isOwner) return;
    await _mutate('جارٍ تحديث حالة العضو...', () async {
      await updateStatus(
        isNetwork,
        id,
        member.userId,
        member.isActive ? 'SUSPENDED' : 'ACTIVE',
      );
      await loadMembers();
    }, member.isActive ? 'تم إيقاف العضوية.' : 'تم تفعيل العضوية.');
  }

  Future<void> remove(MembershipEntity member) async {
    final id = selectedTenantId.value;
    if (id == null || member.isOwner) return;
    await _mutate('جارٍ إزالة العضوية...', () async {
      await removeMember(isNetwork, id, member.userId);
      await loadMembers();
    }, 'تمت إزالة العضوية.');
  }

  Future<void> _mutate(
    String message,
    Future<void> Function() action,
    String success,
  ) async {
    if (isMutating.value) return;
    isMutating.value = true;
    await CustomAnimationOverlay.showLoading(message: message);
    try {
      await action();
      await CustomAnimationOverlay.showSuccess(message: success);
    } catch (error) {
      CustomSnackbar.show(
        title: 'تعذر تنفيذ العملية',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'حدث خطأ غير متوقع.',
        ),
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      isMutating.value = false;
    }
  }
}
