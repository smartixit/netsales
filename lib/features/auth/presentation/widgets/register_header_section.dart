import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ترويسة شاشة تسجيل مزود شبكة جديد (RegisterHeaderSection)
class RegisterHeaderSection extends StatelessWidget {
  const RegisterHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Container(
          width: 64.r,
          height: 64.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withValues(alpha: 0.1),
            boxShadow: AppElevation.glow(
              context,
              colors.primary,
              blur: 16.r,
            ),
          ),
          child: Icon(
            Icons.wifi_tethering_rounded,
            color: colors.primary,
            size: 32.r,
          ),
        ),
        AppSpacing.vMd,
        Text(
          'تسجيل مزود شبكة جديد',
          style: AppTypography.headlineSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vXxs,
        Text(
          'انضم لشبكة موفري خدمات الإنترنت وقم بإدارة كروتك ونقاط بيعك باحترافية',
          style: AppTypography.bodyMedium.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}
