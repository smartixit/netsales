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
/// Built strictly using centralized core tokens and canonical widgets:
/// - The avatar is sourced from the authenticated user's profile, never from
///   the active network/POS entity logo displayed by the workspace selector.
/// - The illustration is rendered in the background layer of the Stack as an
///   artistic watermark, allowing the foreground details to occupy full width
///   with generous breathing room and crystal-clear contrast.
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
        constraints: BoxConstraints(minHeight: 168.h),
        decoration: BoxDecoration(gradient: colors.executiveHeroGradient),
        child: Stack(
          children: [
            // 1. خلفية التدرج والشبكة الهندسية
            const Positioned.fill(
              child: CustomPaint(painter: WorkspaceHeroBackdropPainter()),
            ),
            // 2. الشريط التموجي المضيء
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: WorkspaceHeroRibbonPainter()),
              ),
            ),
            // 3. التوهج النيوني المحيطي بألوان النظام المركزية
            Positioned(
              left: -AppSpacing.xxl,
              bottom: -AppSpacing.giant,
              child: IgnorePointer(
                child: Container(
                  width: 190.w,
                  height: 110.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.secondary.withValues(alpha: 0.11),
                    boxShadow: [
                      BoxShadow(
                        color: colors.secondary.withValues(alpha: 0.16),
                        blurRadius: AppSpacing.huge,
                        spreadRadius: AppSpacing.md,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 4. الرسمة التعبيرية المخصصة كخلفية فنية مائية (Background Artistic Watermark)
            PositionedDirectional(
              end: -AppSpacing.sm,
              bottom: -AppSpacing.cardPadding,
              top: AppSpacing.xs,
              width: 175.w,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.38,
                  child: CustomPaint(
                    painter: WorkspaceHeroIllustrationPainter(
                      isNetwork: artwork == WorkspaceWelcomeArtwork.network,
                    ),
                  ),
                ),
              ),
            ),
            // 5. محتوى الكرت الترحيبي القيادي في الواجهة (Foreground Content)
            Padding(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
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
          ],
        ),
      ),
    );
  }
}
