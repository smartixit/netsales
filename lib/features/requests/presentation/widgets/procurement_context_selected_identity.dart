import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';

class ProcurementContextSelectedIdentity extends StatelessWidget {
  const ProcurementContextSelectedIdentity({
    super.key,
    required this.name,
    required this.detail,
    required this.logoUrl,
    required this.initial,
    required this.accent,
  });

  final String name;
  final String detail;
  final String? logoUrl;
  final String initial;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            accent.withValues(alpha: .12),
            colors.primary.withValues(alpha: .045),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: .30)),
      ),
      child: Row(
        children: [
          CustomCachedImage.logo(
            url: logoUrl,
            size: 48.r,
            borderRadius: 14.r,
            fallbackText: initial,
            fallbackTextStyle: AppTypography.titleMedium.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_rounded, color: accent, size: 21.r),
        ],
      ),
    );
  }
}
