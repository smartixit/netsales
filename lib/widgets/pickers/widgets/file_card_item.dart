import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/models/app_picked_file.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/media_gallery/media_gallery_viewer.dart';

/// بطاقة عرض الملف المرفق الفردي في النظام (FileCardItem)
///
/// تعرض أيقونة نوع الملف الملونة، اسمه، حجمه المنسق، وزر حذفه، مع دعم
/// المعاينة المصغرة للصور بحماية كاملة من انهيار الذاكرة.
class FileCardItem extends StatelessWidget {
  final AppPickedFile file;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final bool readOnly;

  const FileCardItem({
    super.key,
    required this.file,
    this.onRemove,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cardContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1.w,
        ),
        boxShadow: AppElevation.level0(context),
      ),
      child: Row(
        children: [
          // 1. أيقونة الملف أو المعاينة المصغرة
          _FileIconBadge(file: file),

          AppSpacing.hMd,

          // 2. تفاصيل الملف (الاسم والحجم)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.name,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vXxs,
                Row(
                  children: [
                    Text(
                      file.sizeFormatted,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (file.extension.isNotEmpty) ...[
                      Text(
                        ' • ',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.outlineVariant,
                        ),
                      ),
                      Text(
                        file.extension.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 3. زر الحذف في حال عدم تفعيل القراءة فقط
          if (!readOnly && onRemove != null) ...[
            AppSpacing.hSm,
            CustomButton.icon(
              icon: Icons.close_rounded,
              tooltip: 'إزالة الملف',
              iconSize: 16.r,
              dimension: 32.r,
              foregroundColor: colors.error,
              backgroundColor: colors.error.withValues(alpha: 0.08),
              onPressed: onRemove,
            ),
          ],
        ],
      ),
    );

    final effectiveOnTap = onTap ??
        () {
          MediaGalleryViewer.showPickedFiles(context, files: [file]);
        };

    return CustomInteractiveBounce(
      onTap: effectiveOnTap,
      child: cardContent,
    );
  }
}

/// وسم وأيقونة الملف المخصصة بحسب النوع مع حماية الذاكرة للصور
class _FileIconBadge extends StatelessWidget {
  final AppPickedFile file;

  const _FileIconBadge({required this.file});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // إذا كان الملف صورة وموجود محلياً: معاينة حقيقية مقيدة بالذاكرة
    if (file.isImage && File(file.path).existsSync()) {
      return Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Image.file(
            File(file.path),
            fit: BoxFit.cover,
            cacheWidth: (44 * 2.5).toInt(),
            cacheHeight: (44 * 2.5).toInt(),
            errorBuilder: (_, __, ___) => _buildFallbackBadge(colors),
          ),
        ),
      );
    }

    return _buildFallbackBadge(colors);
  }

  Widget _buildFallbackBadge(AppColors colors) {
    final (iconData, badgeColor) = _resolveIconAndColor(colors);

    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.25),
        ),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: badgeColor,
          size: 22.r,
        ),
      ),
    );
  }

  (IconData, Color) _resolveIconAndColor(AppColors colors) {
    if (file.isPdf) {
      return (Icons.picture_as_pdf_rounded, colors.error);
    }
    if (file.isSpreadsheet) {
      return (Icons.table_chart_rounded, colors.success);
    }
    if (file.isWord) {
      return (Icons.description_rounded, colors.primary);
    }
    if (file.isArchive) {
      return (Icons.folder_zip_rounded, colors.warning);
    }
    if (file.isImage) {
      return (Icons.image_rounded, colors.primary);
    }
    return (Icons.insert_drive_file_rounded, colors.onSurfaceVariant);
  }
}
