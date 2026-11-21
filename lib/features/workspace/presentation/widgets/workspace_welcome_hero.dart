import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

enum WorkspaceWelcomeArtwork { network, pos }

/// Shared welcome banner used by both mobile workspaces.
///
/// The AppBar remains responsible for the active entity and user avatar;
/// this banner is intentionally dedicated to the personal welcome message.
class WorkspaceWelcomeHero extends StatelessWidget {
  const WorkspaceWelcomeHero({
    super.key,
    required this.userName,
    required this.role,
    required this.artwork,
    this.dateText,
    this.actionLabel,
    this.onAction,
  });

  final String userName;
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
        decoration: BoxDecoration(
          gradient: colors.executiveHeroGradient,
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _HeroNetworkPatternPainter()),
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
                    child: _WelcomeDetails(
                      userName: userName,
                      role: role,
                      dateText: dateText,
                      actionLabel: actionLabel,
                      onAction: onAction,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 142.h,
                      child: CustomPaint(
                        painter: _WorkspaceHeroArtworkPainter(
                          artwork: artwork,
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

class _WelcomeDetails extends StatelessWidget {
  const _WelcomeDetails({
    required this.userName,
    required this.role,
    this.dateText,
    this.actionLabel,
    this.onAction,
  });

  final String userName;
  final String role;
  final String? dateText;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'مرحباً بعودتك',
          maxLines: 1,
          textAlign: TextAlign.end,
          style: AppTypography.titleSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.94),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 7.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.90),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 5.w),
            Icon(
              Icons.verified_user_rounded,
              size: 13.r,
              color: Colors.white.withValues(alpha: 0.92),
            ),
            SizedBox(width: 7.w),
            Container(
              width: 3.r,
              height: 3.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 7.w),
            Text(
              'جلسة نشطة',
              maxLines: 1,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ],
        ),
        if (dateText != null) ...[
          SizedBox(height: 9.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  dateText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.calendar_month_rounded,
                size: 14.r,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ],
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: 10.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CustomInteractiveBounce(
              onTap: onAction,
              child: Container(
                constraints: BoxConstraints(minHeight: 35.h),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: const Color(0xFF63E6D0).withValues(alpha: 0.82),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 19.r,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroNetworkPatternPainter extends CustomPainter {
  const _HeroNetworkPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final nodes = <Offset>[
      Offset(size.width * 0.07, size.height * 0.17),
      Offset(size.width * 0.25, size.height * 0.10),
      Offset(size.width * 0.42, size.height * 0.22),
      Offset(size.width * 0.15, size.height * 0.55),
      Offset(size.width * 0.43, size.height * 0.68),
      Offset(size.width * 0.73, size.height * 0.12),
      Offset(size.width * 0.88, size.height * 0.42),
    ];

    for (final pair in const <(int, int)>[
      (0, 1),
      (0, 3),
      (1, 2),
      (2, 4),
      (2, 5),
      (3, 4),
      (4, 6),
    ]) {
      canvas.drawLine(nodes[pair.$1], nodes[pair.$2], linePaint);
    }

    final nodePaint = Paint()
      ..color = const Color(0xFF7FE7D5).withValues(alpha: 0.45);
    for (final node in nodes) {
      canvas.drawCircle(node, 2.1, nodePaint);
    }

    final goldPaint = Paint()
      ..color = const Color(0xFFFFD98A).withValues(alpha: 0.92)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final goldCurve = Path()
      ..moveTo(-size.width * 0.04, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 1.02,
        size.width * 0.46,
        size.height * 0.91,
      )
      ..quadraticBezierTo(
        size.width * 0.66,
        size.height * 0.82,
        size.width * 0.94,
        size.height * 0.96,
      );
    canvas.drawPath(goldCurve, goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WorkspaceHeroArtworkPainter extends CustomPainter {
  const _WorkspaceHeroArtworkPainter({required this.artwork});

  final WorkspaceWelcomeArtwork artwork;

  @override
  void paint(Canvas canvas, Size size) {
    if (artwork == WorkspaceWelcomeArtwork.network) {
      _paintNetworkBuildings(canvas, size);
    } else {
      _paintPosStore(canvas, size);
    }
  }

  void _paintNetworkBuildings(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shadow = Paint()
      ..color = const Color(0xFF021F2C).withValues(alpha: 0.32);
    canvas.drawOval(
      Rect.fromLTWH(w * 0.04, h * 0.83, w * 0.90, h * 0.12),
      shadow,
    );

    final rearFace = Path()
      ..moveTo(w * 0.06, h * 0.42)
      ..lineTo(w * 0.26, h * 0.29)
      ..lineTo(w * 0.26, h * 0.86)
      ..lineTo(w * 0.06, h * 0.94)
      ..close();
    canvas.drawPath(
      rearFace,
      Paint()..color = const Color(0xFF0A7890),
    );

    final mainFace = Path()
      ..moveTo(w * 0.25, h * 0.23)
      ..lineTo(w * 0.56, h * 0.08)
      ..lineTo(w * 0.56, h * 0.84)
      ..lineTo(w * 0.25, h * 0.94)
      ..close();
    canvas.drawPath(
      mainFace,
      Paint()..color = const Color(0xFF83D9E8),
    );

    final sideFace = Path()
      ..moveTo(w * 0.56, h * 0.08)
      ..lineTo(w * 0.76, h * 0.20)
      ..lineTo(w * 0.76, h * 0.76)
      ..lineTo(w * 0.56, h * 0.84)
      ..close();
    canvas.drawPath(
      sideFace,
      Paint()..color = const Color(0xFF167D91),
    );

    final glassPaint = Paint()
      ..color = const Color(0xFF07536C)
      ..style = PaintingStyle.fill;
    for (var row = 0; row < 5; row++) {
      for (var column = 0; column < 3; column++) {
        final left = w * (0.30 + column * 0.075);
        final top = h * (0.30 + row * 0.105);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, w * 0.045, h * 0.065),
            Radius.circular(1.5),
          ),
          glassPaint,
        );
      }
    }

    final sideWindowPaint = Paint()
      ..color = const Color(0xFFB8F0F2).withValues(alpha: 0.72);
    for (var row = 0; row < 4; row++) {
      canvas.drawRect(
        Rect.fromLTWH(
          w * 0.61,
          h * (0.25 + row * 0.12),
          w * 0.095,
          h * 0.055,
        ),
        sideWindowPaint,
      );
    }

    final smallBuilding = Path()
      ..moveTo(w * 0.73, h * 0.50)
      ..lineTo(w * 0.88, h * 0.42)
      ..lineTo(w * 0.97, h * 0.48)
      ..lineTo(w * 0.97, h * 0.83)
      ..lineTo(w * 0.73, h * 0.88)
      ..close();
    canvas.drawPath(
      smallBuilding,
      Paint()..color = const Color(0xFF0B6676),
    );
    for (var row = 0; row < 3; row++) {
      canvas.drawRect(
        Rect.fromLTWH(
          w * 0.78,
          h * (0.56 + row * 0.085),
          w * 0.055,
          h * 0.045,
        ),
        sideWindowPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          w * 0.87,
          h * (0.55 + row * 0.085),
          w * 0.055,
          h * 0.045,
        ),
        sideWindowPaint,
      );
    }

    final ground = Paint()
      ..color = const Color(0xFF063C3F).withValues(alpha: 0.72);
    canvas.drawOval(
      Rect.fromLTWH(w * 0.00, h * 0.84, w * 0.98, h * 0.13),
      ground,
    );
  }

  void _paintPosStore(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final shadow = Paint()
      ..color = const Color(0xFF021F2C).withValues(alpha: 0.30);
    canvas.drawOval(
      Rect.fromLTWH(w * 0.07, h * 0.82, w * 0.88, h * 0.12),
      shadow,
    );

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.43, w * 0.68, h * 0.43),
      const Radius.circular(4),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFDDF5E9));

    final side = Path()
      ..moveTo(w * 0.77, h * 0.43)
      ..lineTo(w * 0.88, h * 0.50)
      ..lineTo(w * 0.88, h * 0.85)
      ..lineTo(w * 0.77, h * 0.86)
      ..close();
    canvas.drawPath(side, Paint()..color = const Color(0xFF8CCCB5));

    final windowPaint = Paint()..color = const Color(0xFF0B6470);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.55, w * 0.31, h * 0.24),
        const Radius.circular(2),
      ),
      windowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.60, h * 0.59, w * 0.10, h * 0.27),
      Paint()..color = const Color(0xFF0B5262),
    );
    canvas.drawCircle(
      Offset(w * 0.67, h * 0.73),
      1.5,
      Paint()..color = const Color(0xFFCFF7E7),
    );

    final awning = Path()
      ..moveTo(w * 0.12, h * 0.45)
      ..lineTo(w * 0.26, h * 0.29)
      ..lineTo(w * 0.82, h * 0.29)
      ..lineTo(w * 0.94, h * 0.45)
      ..lineTo(w * 0.91, h * 0.53)
      ..lineTo(w * 0.84, h * 0.56)
      ..lineTo(w * 0.77, h * 0.52)
      ..lineTo(w * 0.70, h * 0.56)
      ..lineTo(w * 0.63, h * 0.52)
      ..lineTo(w * 0.56, h * 0.56)
      ..lineTo(w * 0.49, h * 0.52)
      ..lineTo(w * 0.42, h * 0.56)
      ..lineTo(w * 0.35, h * 0.52)
      ..lineTo(w * 0.28, h * 0.56)
      ..lineTo(w * 0.20, h * 0.52)
      ..close();
    canvas.drawPath(awning, Paint()..color = const Color(0xFFE8FFFA));

    final stripePaint = Paint()..color = const Color(0xFF19B99A);
    for (var i = 0; i < 5; i++) {
      final left = w * (0.23 + i * 0.13);
      canvas.drawPath(
        Path()
          ..moveTo(left, h * 0.31)
          ..lineTo(left + w * 0.10, h * 0.31)
          ..lineTo(left + w * 0.11, h * 0.52)
          ..lineTo(left + w * 0.06, h * 0.55)
          ..close(),
        stripePaint,
      );
    }

    final framePaint = Paint()
      ..color = const Color(0xFFB6EFE1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.29, h * 0.58, w * 0.25, h * 0.18),
      framePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WorkspaceHeroArtworkPainter oldDelegate) =>
      oldDelegate.artwork != artwork;
}
