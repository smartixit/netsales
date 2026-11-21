import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/models/media_gallery_item_model.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/media_gallery/media_gallery_viewer.dart';

/// مكون عرض الوسائط والمرفقات داخل بطاقة الإشعار (NotificationCardMedia)
///
/// يدعم وضعين متكيفين:
/// 1. وضع مصغر مدمج (Thumbnail) عند طي الإشعار (56x56dp) مع أيقونة تكبير.
/// 2. وضع لافتة كاملة (Full Banner) عند توسيع الإشعار بعرض كامل ونسبة أبعاد متناسقة.
/// النقر على أي من الوضعين يفتح عارض الوسائط الموحد [MediaGalleryViewer].
class NotificationCardMedia extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final int notificationId;
  final bool isExpanded;

  const NotificationCardMedia({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    required this.notificationId,
    this.isExpanded = false,
  });

  void _openMediaViewer(BuildContext context) {
    MediaGalleryViewer.showSingle(
      context,
      MediaGalleryItemModel(
        url: imageUrl,
        title: title,
        subtitle: subtitle,
        type: MediaGalleryType.image,
        heroTag: 'notification_media_$notificationId',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isExpanded) {
      // ── لافتة وسائط عريضة عالية الجودة ──
      return CustomInteractiveBounce(
        onTap: () => _openMediaViewer(context),
        child: Container(
          width: double.infinity,
          height: 150.h,
          margin: EdgeInsets.only(top: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomCachedImage(
                url: imageUrl,
                fit: BoxFit.cover,
                borderRadius: AppRadius.md,
                fallback: Container(
                  color: colors.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: colors.onSurfaceVariant,
                      size: 32.r,
                    ),
                  ),
                ),
              ),
              // تدرج ظل سفلي خفيف لإبراز التسمية
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 16.r,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'انقر للمعاينة بالحجم الكامل',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

    // ── مصغرة وسائط مدمجة أنيقة ──
    return CustomInteractiveBounce(
      onTap: () => _openMediaViewer(context),
      child: Container(
        width: 56.r,
        height: 56.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomCachedImage(
              url: imageUrl,
              fit: BoxFit.cover,
              borderRadius: AppRadius.sm,
              fallback: Container(
                color: colors.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.image_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20.r,
                  ),
                ),
              ),
            ),
            // مؤشر تكبير مائي في الزاوية
            Positioned(
              bottom: 2.r,
              left: 2.r,
              child: Container(
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 12.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
