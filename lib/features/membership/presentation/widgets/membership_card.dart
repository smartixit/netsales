import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/widgets/cards/custom_executive_transaction_card.dart';

/// بطاقة عضو مساحة العمل بنظام الأكورديون القيادي (Membership Card - Executive Edition)
///
/// تستهلك المكون القيادي الموحد [CustomExecutiveTransactionCard]:
/// حواف 24.r، ظلال مزدوجة بمسحة زمردية، شريط ترويسة بمعرف العضو ورقم الهاتف
/// وشارات الحالة المعتمدة من [EnumPresentationRegistry]، وأكورديون تفاعلي أنيق.
class MembershipCard extends StatelessWidget {
  const MembershipCard({
    super.key,
    required this.member,
    required this.onDetails,
    this.isNetworkView = false,
    this.isExpanded = false,
    this.onToggleExpand,
    this.onChangeRole,
    this.onToggleStatus,
    this.onRemove,
    this.onMoreActions,
    this.actions,
  });

  final WorkspaceMemberEntity member;
  final VoidCallback onDetails;
  final bool isNetworkView;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onChangeRole;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onRemove;
  final VoidCallback? onMoreActions;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final status = EnumPresentationRegistry.resolveMembershipStatus(
      member.status,
      serverLabel: member.statusLabel,
    );
    final role = EnumPresentationRegistry.resolveRoleKey(
      member.typedRoleKey,
      serverLabel: member.displayRoleName,
    );

    final actorLabel = member.isOwner ? 'المالك المعتمد لمساحة العمل' : null;
    final displayName = TextFormatter.twoNames(
      member.displayFullName,
      fallback: member.displayFullName,
    );

    return CustomExecutiveTransactionCard(
      reference: member.displayReference,
      dateLabel: member.formattedJoinedDate,
      partyName: displayName,
      partyLogoUrl: member.user?.profilePictureUrl,
      partyPhone: member.displayPhoneNumber,
      isPartyVerified: member.isOwner,
      actorLabel: actorLabel,
      statusPresentation: status,
      typePresentation: role,
      secondaryReference: 'عضوية #${member.id}',
      items: const [],
      metrics: [
        ExecutiveCardMetricData(
          label: 'الدور الوظيفي',
          value: member.displayRoleName,
        ),
        ExecutiveCardMetricData(
          label: 'رقم الهاتف',
          value: member.displayPhoneNumber,
        ),
        ExecutiveCardMetricData(
          label: 'حالة العضوية',
          value: status.label,
          isEmphasized: true,
          textColor: status.tone.color(context),
        ),
      ],
      actions: actions,
      onTap: onDetails,
      isExpanded: isExpanded,
      onToggleExpand: onToggleExpand,
    );
  }
}
