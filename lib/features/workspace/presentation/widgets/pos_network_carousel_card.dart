import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

class PosNetworkCarouselCard extends StatelessWidget {
  const PosNetworkCarouselCard({
    super.key,
    required this.link,
    required this.isSelected,
    required this.onTap,
  });

  final NetworkPosLinkEntity link;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final network = link.network;
    final name = network?.networkName ?? 'شبكة #${link.networkId}';
    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isSelected
                ? [colors.primary, colors.secondary]
                : [
                    colors.surfaceContainerHigh,
                    colors.surfaceContainerLow,
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.75)
                : colors.outlineVariant.withValues(alpha: 0.55),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.18),
                    blurRadius: 18.r,
                    offset: Offset(0, 7.h),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: (isSelected ? colors.onPrimary : colors.primary)
                        .withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: network?.networkProfileLogoUrl != null &&
                          network!.networkProfileLogoUrl!.trim().isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: network.networkProfileLogoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                            Icons.hub_rounded,
                            color: isSelected ? colors.onPrimary : colors.primary,
                            size: 24.r,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.hub_rounded,
                            color: isSelected ? colors.onPrimary : colors.primary,
                            size: 24.r,
                          ),
                        )
                      : Icon(
                          Icons.hub_rounded,
                          color: isSelected ? colors.onPrimary : colors.primary,
                          size: 24.r,
                        ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (isSelected ? colors.onPrimary : colors.primary)
                        .withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    isSelected ? 'الحساب المحدد' : 'عرض الحساب',
                    style: AppTypography.badgeText.copyWith(
                      color: isSelected ? colors.onPrimary : colors.primary,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge.copyWith(
                    color: isSelected ? colors.onPrimary : colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'حسابك التجاري لدى الشبكة',
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected
                        ? colors.onPrimary.withValues(alpha: 0.82)
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'استعراض الحساب',
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? colors.onPrimary : colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 5.w),
                Icon(
                  Icons.arrow_back_rounded,
                  size: 17.r,
                  color: isSelected ? colors.onPrimary : colors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
