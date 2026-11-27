import 'package:flutter/material.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/presentation/widgets/membership_card_action_bar.dart';

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
    required this.onMoreActions,
  });

  final WorkspaceMemberEntity member;
  final VoidCallback onDetails;
  final bool isNetworkView;
  final VoidCallback? onChangeRole;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onRemove;
  final VoidCallback onMoreActions;

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
      onMoreActions: onMoreActions,
    );
  }
}
