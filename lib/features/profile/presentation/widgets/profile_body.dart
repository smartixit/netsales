import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_appearance_card.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_identity_card.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_logout_tile.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_security_card.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_workspaces_card.dart';

/// جسم صفحة الملف الشخصي — يُركّب البطاقات المعيارية دون أي منطق.
class ProfileBody extends GetView<ProfileController> {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileIdentityCard(),
        AppSpacing.vLg,
        const ProfileSecurityCard(),
        AppSpacing.vLg,
        Obx(() {
          final hasMemberships =
              controller.profile.value?.hasOperationalMemberships ?? false;
          if (!hasMemberships) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileWorkspacesCard(),
              AppSpacing.vLg,
            ],
          );
        }),
        const ProfileAppearanceCard(),
        AppSpacing.vLg,
        const ProfileLogoutTile(),
        AppSpacing.vXxl,
      ],
    );
  }
}
