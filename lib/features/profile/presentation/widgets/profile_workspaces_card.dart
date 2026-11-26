import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/membership_list_tile.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_settings_group.dart';

/// بطاقة بيئات العمل المرتبطة — مبنية على [ProfileSettingsGroup].
class ProfileWorkspacesCard extends GetView<ProfileController> {
  const ProfileWorkspacesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final memberships = controller.profile.value?.memberships ?? const [];
      if (memberships.isEmpty) return const SizedBox.shrink();

      return ProfileSettingsGroup(
        title: 'بيئات العمل المرتبطة (${memberships.length})',
        children: memberships
            .map(
              (m) => MembershipListTile(
                membership: m,
                onTap: () => controller.openMembership(m),
              ),
            )
            .toList(growable: false),
      );
    });
  }
}
