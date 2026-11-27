import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// مكون عرض الصورة المرفقة بالإشعار (مصغرة على البطاقة أو بانر في ورقة التفاصيل).
///
/// نقي تماماً — يستقبل [onTap] لفتح عارض الوسائط [MediaGalleryViewer].
class NotificationCardMedia extends StatelessWidget {
  const NotificationCardMedia({
    super.key,
    required this.imageUrl,
    required this.notificationId,
    required this.onTap,
    this.isBanner = false,
  });

  final String imageUrl;
  final int notificationId;
  final VoidCallback onTap;
  final bool isBanner;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isBanner) {
      return CustomInteractiveBounce(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 170.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'notification_media_$notificationId',
                child: CustomCachedImage(
                  url: imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: AppRadius.lg,
                  fallback: _MediaFallback(iconSize: 32.r),
                ),
              ),
              PositionedDirectional(
                bottom: AppSpacing.sm,
                end: AppSpacing.sm,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_out_map_rounded,
                        size: 14.sp,
                        color: colors.primary,
                      ),
                      AppSpacing.hXs,
                      Text(
                        'معاينة الصورة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: 58.r,
        height: 58.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'notification_media_$notificationId',
              child: CustomCachedImage(
                url: imageUrl,
                fit: BoxFit.cover,
                borderRadius: AppRadius.md,
                fallback: _MediaFallback(iconSize: 22.r),
              ),
            ),
            PositionedDirectional(
              bottom: 3.r,
              end: 3.r,
              child: Container(
                padding: EdgeInsets.all(3.r),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.zoom_in_rounded,
                  size: 12.sp,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colors.onSurfaceVariant,
          size: iconSize,
        ),
      ),
    );
  }
}
