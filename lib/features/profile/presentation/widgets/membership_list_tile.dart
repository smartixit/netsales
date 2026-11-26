import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_seetings_tile.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';

/// صف عضوية واحدة في بيئة عمل — مبني على [ProfileSettingsTile].
class MembershipListTile extends StatelessWidget {
  const MembershipListTile({
    super.key,
    required this.membership,
    this.onTap,
  });

  final ProfileMembershipEntity membership;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetwork = membership.isNetwork;
    final tint = isNetwork ? colors.primary : colors.tertiary;

    return ProfileSettingsTile(
      icon: isNetwork ? Icons.hub_outlined : Icons.store_outlined,
      title: membership.roleName,
      subtitle: membership.scopeLabel,
      color: tint,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomChip(
            label: '#${membership.tenantId}',
            backgroundColor: tint.withValues(alpha: 0.10),
            foregroundColor: tint,
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
