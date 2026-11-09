import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/membership/domain/entities/membership_entity.dart';
import 'package:netsales/features/membership/presentation/controllers/membership_controller.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';

class MembershipList extends StatelessWidget {
  const MembershipList({super.key, required this.controller});
  final MembershipController controller;
  @override
  Widget build(BuildContext context) => Column(children: controller.members.map((member) => Padding(padding: EdgeInsets.only(bottom: AppSpacing.sm), child: _MembershipTile(member: member, controller: controller))).toList());
}

class _MembershipTile extends StatelessWidget {
  const _MembershipTile({required this.member, required this.controller});
  final MembershipEntity member;
  final MembershipController controller;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = member.isActive;
    final presentation = EnumPresentation(
      label: member.status == 'ACTIVE' ? 'نشط' : member.status == 'SUSPENDED' ? 'موقوف' : member.status == 'INVITED' ? 'بانتظار التفعيل' : 'غير معروف',
      tone: active ? SemanticTone.success : member.status == 'SUSPENDED' ? SemanticTone.warning : SemanticTone.neutral,
      icon: active ? Icons.check_circle_rounded : Icons.pause_circle_outline_rounded,
    );
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.outlineVariant.withValues(alpha: .45))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 22, child: Text(member.fullName.isEmpty ? '؟' : member.fullName.characters.first)),
          AppSpacing.hSm,
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(member.fullName, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(member.phoneNumber, style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant)),
          ])),
          CustomStatusBadge.fromPresentation(presentation, isCompact: true),
        ]),
        AppSpacing.vSm,
        Row(children: [
          Icon(Icons.badge_outlined, size: 16, color: colors.onSurfaceVariant), AppSpacing.hXs,
          Expanded(child: Text(member.roleLabel, style: AppTypography.bodyMedium)),
          if (member.isOwner) const CustomStatusBadge(label: 'المالك', tone: SemanticTone.primary, isCompact: true),
        ]),
        if (!member.isOwner) ...[
          AppSpacing.vSm,
          Wrap(alignment: WrapAlignment.end, spacing: AppSpacing.xs, runSpacing: AppSpacing.xs, children: [
            CustomButton.text(text: active ? 'إيقاف' : 'تفعيل', icon: active ? Icons.pause_rounded : Icons.play_arrow_rounded, foregroundColor: active ? colors.error : colors.success, onPressed: controller.isMutating.value ? null : () => controller.toggleStatus(member)),
            CustomButton.text(text: 'تغيير الدور', icon: Icons.swap_horiz_rounded, onPressed: controller.roles.isEmpty ? null : () => _chooseRole(context, member)),
            CustomButton.text(text: 'إزالة', icon: Icons.person_remove_alt_1_rounded, foregroundColor: colors.error, onPressed: () => _confirmRemove(member)),
          ]),
        ],
      ]),
    );
  }

  Future<void> _chooseRole(BuildContext context, MembershipEntity member) async {
    final selected = await Get.bottomSheet<int>(SafeArea(child: Material(color: context.colors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), child: Padding(padding: EdgeInsets.all(AppSpacing.lg), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('تغيير الدور التشغيلي', style: AppTypography.titleLarge), AppSpacing.vMd,
      ...controller.roles.map((role) => ListTile(title: Text(role.name), trailing: role.roleId == member.roleId ? const Icon(Icons.check_circle_rounded) : null, onTap: () => Get.back<int>(role.roleId))),
    ])))), isScrollControlled: true);
    if (selected != null && selected != member.roleId) await controller.changeRole(member, selected);
  }

  Future<void> _confirmRemove(MembershipEntity member) async {
    final confirmed = await CustomDialog.showDanger(title: 'إزالة العضو', message: 'سيتم إنهاء عضوية ${member.fullName} في هذه المنشأة. لن يتم حذف حساب المستخدم.', confirmLabel: 'إزالة العضوية');
    if (confirmed == true) await controller.remove(member);
  }
}
