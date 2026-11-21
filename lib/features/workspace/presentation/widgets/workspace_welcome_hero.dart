import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_hero_backdrop_painter.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_hero_ribbon_painter.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_hero_illustration_painter.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_welcome_details.dart';

enum WorkspaceWelcomeArtwork { network, pos }

/// Shared welcome banner used by both mobile workspaces.
///
/// The avatar is sourced from the authenticated user's profile, never from
/// the active network/POS entity logo displayed by the workspace selector.
class WorkspaceWelcomeHero extends StatelessWidget {
  const WorkspaceWelcomeHero({
    super.key,
    required this.userName,
    required this.userAvatarUrl,
    required this.userInitials,
    required this.role,
    required this.artwork,
    this.dateText,
    this.actionLabel,
    this.onAction,
  });

  final String userName;
  final String? userAvatarUrl;
  final String userInitials;
  final String role;
  final WorkspaceWelcomeArtwork artwork;
  final String? dateText;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        constraints: BoxConstraints(minHeight: 174.h),
        decoration: BoxDecoration(gradient: colors.executiveHeroGradient),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: WorkspaceHeroBackdropPainter()),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: WorkspaceHeroRibbonPainter()),
              ),
            ),
            Positioned(
              left: -26.w,
              bottom: -48.h,
              child: IgnorePointer(
                child: Container(
                  width: 190.w,
                  height: 110.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.11),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2DD4BF).withValues(alpha: 0.16),
                        blurRadius: 42.r,
                        spreadRadius: 12.r,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: WorkspaceWelcomeDetails(
                      userName: userName,
                      userAvatarUrl: userAvatarUrl,
                      userInitials: userInitials,
                      role: role,
                      dateText: dateText,
                      actionLabel: actionLabel,
                      onAction: onAction,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 142.h,
                      child: CustomPaint(
                        painter: WorkspaceHeroIllustrationPainter(
                          isNetwork: artwork == WorkspaceWelcomeArtwork.network,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
