import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/presentation/widgets/member_card/member_card_accordion.dart';
import 'package:netsales/features/membership/presentation/widgets/member_card/member_card_header.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// بطاقة عضو مساحة العمل التفاعلية (MemberCard)
///
/// تستند إلى [CustomSurfaceCard] لتوحيد مظهر البطاقات وحوافها وظلالها عبر المنصة.
class MemberCard extends StatelessWidget {
  const MemberCard({
    super.key,
    required this.member,
    this.isExpanded = false,
    this.onToggleExpansion,
    required this.onUpdateRole,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final WorkspaceMemberEntity member;
  final bool isExpanded;
  final VoidCallback? onToggleExpansion;
  final VoidCallback onUpdateRole;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return CustomSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MemberCardHeader(
            member: member,
            isExpanded: isExpanded,
            onToggleExpansion: onToggleExpansion,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: MemberCardAccordion(
              member: member,
              isExpanded: isExpanded,
              onToggleExpansion: onToggleExpansion ?? () {},
              onUpdateRole: onUpdateRole,
              onToggleStatus: onToggleStatus,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
