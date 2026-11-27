import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/presentation/controllers/base_memberships_controller.dart';
import 'package:netsales/features/membership/presentation/widgets/membership_action_dialogs.dart';
import 'package:netsales/features/membership/presentation/widgets/sheets/add_member_sheet.dart';
import 'package:netsales/features/membership/presentation/widgets/sheets/change_member_role_sheet.dart';
import 'package:netsales/features/membership/presentation/widgets/sheets/member_details_sheet.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// تنسيق تدفقات العرض التفاعلية للعضويات دون تحميل Controllers مسؤولية بناء الواجهات.
class MembershipPresentationCoordinator {
  const MembershipPresentationCoordinator(this.controller);

  final BaseMembershipsController controller;

  void showMemberActions({
    required WorkspaceMemberEntity member,
    required bool isNetworkView,
    required VoidCallback onDetails,
    VoidCallback? onChangeRole,
    VoidCallback? onToggleStatus,
    VoidCallback? onRemove,
  }) {
    final actions = <CustomBottomSheetActionItem>[
      CustomBottomSheetActionItem(
        title: 'عرض الملف التعريفي للعضو',
        icon: Icons.badge_outlined,
        onTap: onDetails,
      ),
      if (!member.isOwner) ...[
        if (onChangeRole != null)
          CustomBottomSheetActionItem(
            title: 'تغيير الدور والمسؤوليات',
            icon: Icons.manage_accounts_outlined,
            onTap: onChangeRole,
          ),
        if (onToggleStatus != null)
          CustomBottomSheetActionItem(
            title: member.isActive ? 'تجميد حساب العضو' : 'تنشيط حساب العضو',
            icon: member.isActive
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            onTap: onToggleStatus,
          ),
        if (onRemove != null)
          CustomBottomSheetActionItem(
            title: 'إنهاء العضوية وإزالة المستخدم',
            icon: Icons.person_remove_outlined,
            isDestructive: true,
            onTap: onRemove,
          ),
      ],
    ];

    CustomBottomSheet.showActions<void>(
      title: 'خيارات العضو ${member.displayFullName}',
      leadingIcon: Icons.account_circle_outlined,
      items: actions,
    );
  }

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
    if (!controller.canAddMember) return;

    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController();
    final roleNotifier = ValueNotifier<int?>(
      controller.assignableRoles.isNotEmpty
          ? controller.assignableRoles.first.roleId
          : null,
    );
    final statusNotifier = ValueNotifier<String?>('ACTIVE');
    final isSubmitting = false.obs;

    CustomBottomSheet.show<void>(
      title: 'إضافة عضو جديد',
      subtitle: 'أدخل رقم هاتف العضو المسجل وحدد الدور والصلاحيات',
      leadingIcon: Icons.person_add_alt_1_rounded,
      child: AddMemberSheet(
        assignableRoles: controller.assignableRoles,
        formKey: formKey,
        phoneController: phoneController,
        roleNotifier: roleNotifier,
        statusNotifier: statusNotifier,
        isSubmitting: isSubmitting,
        onSubmit: () async {
          if (!controller.canAddMember) return;
          if (!formKey.currentState!.validate()) return;

          final roleId = roleNotifier.value;
          if (roleId == null) {
            CustomSnackbar.show(
              title: 'تنبيه',
              message: 'يرجى اختيار الدور الوظيفي للعضو.',
              type: SnackType.warning,
            );
            return;
          }

          isSubmitting.value = true;
          try {
            await controller.addMember(
              phoneNumber: phoneController.text.trim(),
              roleId: roleId,
              status: statusNotifier.value,
            );
            Get.back<void>();
            CustomSnackbar.show(
              title: 'تمت الإضافة بنجاح',
              message: controller.isNetworkView
                  ? 'تمت إضافة العضو للشبكة وتعيين الدور بنجاح.'
                  : 'تمت إضافة العضو لنقطة البيع وتعيين الدور بنجاح.',
              type: SnackType.success,
            );
          } catch (error) {
            CustomSnackbar.show(
              title: 'فشلت إضافة العضو',
              message: AppException.sanitizeMessage(error),
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
      isSubmitting.close();
    });
  }

  void openChangeRoleSheet(WorkspaceMemberEntity member) {
    if (!controller.canChangeMemberRole || member.isOwner) return;

    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    final roleNotifier = ValueNotifier<int?>(
      controller.assignableRoles.any((role) => role.roleId == member.roleId)
          ? member.roleId
          : (controller.assignableRoles.isNotEmpty
                ? controller.assignableRoles.first.roleId
                : null),
    );
    final isSubmitting = false.obs;

    CustomBottomSheet.show<void>(
      title: 'تعديل الدور الوظيفي',
      subtitle: 'ترقية أو تغيير صلاحيات ${member.displayFullName}',
      leadingIcon: Icons.manage_accounts_rounded,
      child: ChangeMemberRoleSheet(
        member: member,
        assignableRoles: controller.assignableRoles,
        formKey: formKey,
        reasonController: reasonController,
        roleNotifier: roleNotifier,
        isSubmitting: isSubmitting,
        onSubmit: () async {
          if (!controller.canChangeMemberRole) return;
          if (!formKey.currentState!.validate()) return;

          final roleId = roleNotifier.value;
          if (roleId == null) {
            CustomSnackbar.show(
              title: 'تنبيه',
              message: 'يرجى اختيار الدور الجديد.',
              type: SnackType.warning,
            );
            return;
          }

          isSubmitting.value = true;
          try {
            final reason = reasonController.text.trim();
            await controller.changeMemberRole(
              member,
              roleId,
              reason.isEmpty ? null : reason,
            );
            Get.back<void>();
            CustomSnackbar.show(
              title: 'تم تحديث الدور',
              message: 'تم تحديث دور وصلاحيات العضو ${member.displayFullName} بنجاح.',
              type: SnackType.success,
            );
          } catch (error) {
            CustomSnackbar.show(
              title: 'فشل تحديث الدور',
              message: AppException.sanitizeMessage(error),
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
      isSubmitting.close();
    });
  }

  void showMemberActions(WorkspaceMemberEntity member) {
    final items = <CustomBottomSheetActionItem>[
      CustomBottomSheetActionItem(
        title: 'عرض الملف التعريفي',
        icon: Icons.person_outline_rounded,
        onTap: () => openMemberDetails(member),
      ),
      if (controller.canChangeMemberRole && !member.isOwner)
        CustomBottomSheetActionItem(
          title: 'تغيير الدور الوظيفي',
          icon: Icons.manage_accounts_outlined,
          onTap: () => openChangeRoleSheet(member),
        ),
      if (controller.canChangeMemberStatus && !member.isOwner)
        CustomBottomSheetActionItem(
          title: member.isActive ? 'تجميد العضوية' : 'تنشيط العضوية',
          icon: member.isActive
              ? Icons.pause_circle_outline_rounded
              : Icons.play_circle_outline_rounded,
          onTap: () => promptToggleMemberStatus(member),
        ),
      if (controller.canRemoveMember && !member.isOwner)
        CustomBottomSheetActionItem(
          title: 'إزالة العضو',
          icon: Icons.person_remove_outlined,
          isDestructive: true,
          onTap: () => promptRemoveMember(member),
        ),
    ];

    CustomBottomSheet.showActions<void>(
      title: 'إجراءات العضو: ${member.displayFullName}',
      leadingIcon: Icons.badge_outlined,
      items: items,
    );
  }

  void promptToggleMemberStatus(WorkspaceMemberEntity member) {
    if (!controller.canChangeMemberStatus || member.isOwner) return;
    final nextStatus = member.isActive ? 'SUSPENDED' : 'ACTIVE';

    MembershipActionDialogs.showToggleStatusDialog(
      memberName: member.displayFullName,
      willSuspend: member.isActive,
      onConfirm: (reason) async {
        try {
          await controller.changeMemberStatus(member, nextStatus, reason);
          CustomSnackbar.show(
            title: member.isActive ? 'تم إيقاف العضوية' : 'تم تفعيل العضوية',
            message: member.isActive
                ? 'تم إيقاف صلاحيات ${member.displayFullName} مؤقتاً.'
                : 'تمت إعادة تفعيل حساب ${member.displayFullName} بنجاح.',
            type: SnackType.success,
          );
        } catch (error) {
          CustomSnackbar.show(
            title: 'فشل تعديل حالة العضوية',
            message: AppException.sanitizeMessage(error),
            type: SnackType.error,
          );
        }
      },
    );
  }

  void promptRemoveMember(WorkspaceMemberEntity member) {
    if (!controller.canRemoveMember || member.isOwner) return;

    MembershipActionDialogs.showRemoveMemberDialog(
      memberName: member.displayFullName,
      onConfirm: (reason) async {
        try {
          await controller.removeMember(member, reason);
          CustomSnackbar.show(
            title: 'تم إنهاء العضوية',
            message: controller.isNetworkView
                ? 'تمت إزالة ${member.displayFullName} من قائمة أعضاء الشبكة بنجاح.'
                : 'تمت إزالة ${member.displayFullName} من طاقم نقطة البيع بنجاح.',
            type: SnackType.success,
          );
        } catch (error) {
          CustomSnackbar.show(
            title: 'فشل إنهاء العضوية',
            message: AppException.sanitizeMessage(error),
            type: SnackType.error,
          );
        }
      },
    );
  }
}
