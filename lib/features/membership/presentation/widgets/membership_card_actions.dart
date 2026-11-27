import 'package:flutter/material.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/presentation/widgets/membership_card_action_bar.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// شريط الإجراءات التفاعلية الموحد لبطاقة العضو (Membership Card Actions)
class MembershipCardActions extends StatelessWidget {
  const MembershipCardActions({
    super.key,
    required this.member,
    required this.onDetails,
    this.isNetworkView = false,
    this.onChangeRole,
    this.onToggleStatus,
    this.onRemove,
  });

  final WorkspaceMemberEntity member;
  final VoidCallback onDetails;
  final bool isNetworkView;
  final VoidCallback? onChangeRole;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onRemove;

  Future<void> _showMoreActions() async {
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
            onTap: onChangeRole!,
          ),
        if (onToggleStatus != null)
          CustomBottomSheetActionItem(
            title: member.isActive ? 'تجميد حساب العضو' : 'تنشيط حساب العضو',
            icon: member.isActive
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            onTap: onToggleStatus!,
          ),
        if (onRemove != null)
          CustomBottomSheetActionItem(
            title: 'إنهاء العضوية وإزالة المستخدم',
            icon: Icons.person_remove_outlined,
            isDestructive: true,
            onTap: onRemove!,
          ),
      ],
    ];

    await CustomBottomSheet.showActions<void>(
      title: 'خيارات العضو ${member.displayFullName}',
      leadingIcon: Icons.account_circle_outlined,
      items: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MembershipCardActionBar(
      isNetworkView: isNetworkView,
      isActive: member.isActive,
      isOwner: member.isOwner,
      onDetails: onDetails,
      onChangeRole: onChangeRole,
      onToggleStatus: onToggleStatus,
      onRemove: onRemove,
      onMoreActions: _showMoreActions,
    );
  }
}
