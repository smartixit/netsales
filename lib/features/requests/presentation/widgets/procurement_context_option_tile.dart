import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_context_option.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';

class ProcurementContextOptionTile extends StatelessWidget {
  const ProcurementContextOptionTile({
    super.key,
    required this.option,
    required this.accent,
  });

  final ProcurementContextOption option;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: option.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: option.selected
                ? accent.withValues(alpha: .105)
                : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: option.selected
                  ? accent.withValues(alpha: .62)
                  : colors.outlineVariant.withValues(alpha: .34),
              width: option.selected ? 1.35 : 1,
            ),
          ),
          child: Row(
            children: [
              CustomCachedImage.logo(
                url: option.logoUrl,
                size: 38.r,
                borderRadius: 11.r,
                fallbackText: option.initial,
              ),
              AppSpacing.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      option.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (option.selected)
                Icon(Icons.check_circle_rounded, color: accent, size: 20.r),
            ],
          ),
        ),
      ),
    );
  }
}
