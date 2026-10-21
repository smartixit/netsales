import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/media_gallery/models/media_gallery_item.dart';

/// ترويسة وشريط إجراءات معرض الوسائط التفاعلي (MediaGalleryHeaderOverlay)
class MediaGalleryHeaderOverlay extends StatelessWidget {
  final MediaGalleryItem currentItem;
  final int currentIndex;
  final int totalCount;
  final String? defaultTitle;
  final VoidCallback onClose;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final bool isDownloading;
  final bool isSharing;
  final bool isPrinting;

  const MediaGalleryHeaderOverlay({
    super.key,
    required this.currentItem,
    required this.currentIndex,
    required this.totalCount,
    this.defaultTitle,
    required this.onClose,
    required this.onDownload,
    required this.onShare,
    required this.onPrint,
    this.isDownloading = false,
    this.isSharing = false,
    this.isPrinting = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleText = currentItem.title.isNotEmpty
        ? currentItem.title
        : (defaultTitle ?? 'المستند');

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        bottom: AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.scrim.withValues(alpha: 0.85),
            colors.scrim.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Row(
        children: [
          // 1. زر الإغلاق والرجوع
          CustomButton.icon(
            icon: Icons.close_rounded,
            tooltip: 'إغلاق',
            dimension: 38.r,
            iconSize: 20.r,
            foregroundColor: colors.onSurface,
            backgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
            onPressed: onClose,
          ),

          AppSpacing.hMd,

          // 2. العنوان وعداد الصفحات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                if (totalCount > 1) ...[
                  AppSpacing.vXxs,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      '${currentIndex + 1} من $totalCount',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 3. أزرار الإجراءات السريعة (حفظ، مشاركة، طباعة)
          CustomButton.icon(
            icon: Icons.file_download_outlined,
            tooltip: 'حفظ بالجهاز',
            dimension: 38.r,
            iconSize: 18.r,
            loading: isDownloading,
            foregroundColor: colors.onSurface,
            backgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
            onPressed: isDownloading ? null : onDownload,
          ),

          AppSpacing.hSm,

          CustomButton.icon(
            icon: Icons.share_outlined,
            tooltip: 'مشاركة',
            dimension: 38.r,
            iconSize: 18.r,
            loading: isSharing,
            foregroundColor: colors.onSurface,
            backgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
            onPressed: isSharing ? null : onShare,
          ),

          AppSpacing.hSm,

          CustomButton.icon(
            icon: Icons.print_outlined,
            tooltip: 'طباعة',
            dimension: 38.r,
            iconSize: 18.r,
            loading: isPrinting,
            foregroundColor: colors.onSurface,
            backgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
            onPressed: isPrinting ? null : onPrint,
          ),
        ],
      ),
    );
  }
}
