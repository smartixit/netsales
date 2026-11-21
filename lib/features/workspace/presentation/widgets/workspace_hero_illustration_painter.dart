import 'package:flutter/material.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_network_illustration_painter.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_pos_illustration_painter.dart';

/// Delegates the welcome illustration to the painter for the active workspace.
class WorkspaceHeroIllustrationPainter extends CustomPainter {
  const WorkspaceHeroIllustrationPainter({required this.isNetwork});

  final bool isNetwork;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final painter = isNetwork
        ? const WorkspaceNetworkIllustrationPainter()
        : const WorkspacePosIllustrationPainter();
    painter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant WorkspaceHeroIllustrationPainter oldDelegate) {
    return oldDelegate.isNetwork != isNetwork;
  }
}
