import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/membership/domain/entities/membership_entity.dart';
import 'package:netsales/features/membership/presentation/controllers/membership_controller.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

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
    final presentation = EnumPresentationRegistry.resolveMembershipStatus(
      MembershipStatus.fromWire(member.status),
    )
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
    final selected = await CustomBottomSheet(
      title: 'تغيير الدور التشغيلي',
      subtitle: 'اختر الدور الجديد لهذا العضو.',
      leadingIcon: Icons.badge_outlined,
      scrollable: true,
      child: Column(mainAxisSize: MainAxisSize.min, children: controller.roles.map((role) => ListTile(
        title: Text(role.name),
        trailing: role.roleId == member.roleId ? const Icon(Icons.check_circle_rounded) : null,
        onTap: () => Get.back<int>(role.roleId),
      )).toList()),
    ).show<int>();
    if (selected != null && selected != member.roleId) await controller.changeRole(member, selected);
  }

  Future<void> _confirmRemove(MembershipEntity member) async {
    final confirmed = await CustomDialog.showDanger(title: 'إزالة العضو', message: 'سيتم إنهاء عضوية ${member.fullName} في هذه المنشأة. لن يتم حذف حساب المستخدم.', confirmLabel: 'إزالة العضوية');
    if (confirmed == true) await controller.remove(member);
  }
}
