import 'package:flutter/material.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_welcome_hero.dart';

class PosWelcomeHeader extends StatelessWidget {
  const PosWelcomeHeader({
    super.key,
    required this.controller,
    required this.onQrTap,
  });

  final PosWorkspaceController controller;
  final VoidCallback onQrTap;

  @override
  Widget build(BuildContext context) {
    return WorkspaceWelcomeHero(
      userName: controller.userName,
      role: controller.userRole,
      artwork: WorkspaceWelcomeArtwork.pos,
      actionLabel: 'ربط شبكة',
      onAction: onQrTap,
    );
  }
}
