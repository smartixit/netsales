import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/media_gallery/models/media_gallery_item.dart';

/// شريط المصغرات السفلي التفاعلي لمعرض الوسائط (MediaGalleryFilmstrip)
class MediaGalleryFilmstrip extends StatelessWidget {
  final List<MediaGalleryItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemTap;

  const MediaGalleryFilmstrip({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.length <= 1) return const SizedBox.shrink();

    final colors = context.colors;

    return Container(
      height: 76.h,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.2),
            width: 1.w,
          ),
        ),
      ),
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: items.length,
          separatorBuilder: (_, __) => AppSpacing.hSm,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return CustomInteractiveBounce(
              onTap: () => onItemTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: isSelected
                        ? colors.primary
                        : colors.outlineVariant.withValues(alpha: 0.3),
                    width: isSelected ? 2.5.w : 1.w,
                  ),
                  boxShadow: isSelected
                      ? AppElevation.glow(context, colors.primary)
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.55,
                  child: _FilmstripThumbnail(item: item),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ودجت مصغرة العنصر الفردي داخل شريط المصغرات
class _FilmstripThumbnail extends StatelessWidget {
  final MediaGalleryItem item;

  const _FilmstripThumbnail({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (item.isPdf) {
      return Container(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.picture_as_pdf_rounded,
            color: colors.error,
            size: 20.r,
          ),
        ),
      );
    }

    if (item.isSpreadsheet) {
      return Container(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.table_chart_rounded,
            color: colors.primary,
            size: 20.r,
          ),
        ),
      );
    }

    if (!item.isImage) {
      return Container(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.insert_drive_file_rounded,
            color: colors.secondary,
            size: 20.r,
          ),
        ),
      );
    }

    if (item.isLocalFile) {
      return Image.file(
        File(item.url),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(colors),
      );
    }

    return CustomCachedImage(
      url: item.url,
      fit: BoxFit.cover,
      fallback: _buildFallback(colors),
    );
  }

  Widget _buildFallback(dynamic colors) {
    return Container(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: colors.onSurfaceVariant.withValues(alpha: 0.4),
          size: 18.r,
        ),
      ),
    );
  }
}
