import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

/// Feature-specific visual identity for a workspace transaction.
class WorkspaceTransactionLeading extends StatelessWidget {
  const WorkspaceTransactionLeading({
    super.key,
    required this.icon,
    required this.accentColor,
    this.initials,
    this.imageUrl,
  });

  final IconData? icon;
  final Color? accentColor;
  final String? initials;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (initials != null && initials!.trim().isNotEmpty) {
      return CustomAvatarBadge(
        initials: initials!,
        imageUrl: imageUrl,
        size: AvatarBadgeSize.sm,
        customDimension: 34,
        hasPulse: false,
        borderRadius: BorderRadius.circular(AppRadius.md),
      );
    }

    final colors = context.colors;
    final foreground = accentColor ?? colors.primary;
    return Container(
      width: 34.r,
      height: 34.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        icon ?? Icons.receipt_long_rounded,
        color: foreground,
        size: 18.r,
      ),
    );
  }
}
