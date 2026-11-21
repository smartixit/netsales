import 'package:flutter/material.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_welcome_hero.dart';

class ExecutiveWelcomeHeroCard extends StatelessWidget {
  const ExecutiveWelcomeHeroCard({
    super.key,
    required this.controller,
  });

  final NetworkWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    return WorkspaceWelcomeHero(
      userName: controller.userName,
      userAvatarUrl: controller.userProfileLogo,
      userInitials: controller.userInitials,
      role: controller.userRole,
      dateText: controller.todayFormatted,
      artwork: WorkspaceWelcomeArtwork.network,
    );
  }
}
