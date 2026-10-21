import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/app_cache_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/media_gallery/models/media_gallery_item.dart';
import 'package:open_filex/open_filex.dart';

/// بطاقة عرض المستندات وجداول البيانات (Excel / Word / Documents) داخل المعرض
class MediaDocumentViewerCard extends StatelessWidget {
  final MediaGalleryItem item;

  const MediaDocumentViewerCard({
    super.key,
    required this.item,
  });

  Future<void> _openDocument() async {
    try {
      if (item.isLocalFile) {
        await OpenFilex.open(item.url);
      } else {
        final file = await AppCacheService.instance.getFile(item.url);
        await OpenFilex.open(file.path);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSpreadsheet = item.isSpreadsheet;

    final iconColor = isSpreadsheet ? colors.primary : colors.secondary;
    final iconData = isSpreadsheet
        ? Icons.table_chart_rounded
        : Icons.insert_drive_file_rounded;

    return Center(
      child: Container(
        margin: EdgeInsets.all(AppSpacing.xl),
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            width: 1.w,
          ),
          boxShadow: AppElevation.level2(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 52.r,
                color: iconColor,
              ),
            ),
            AppSpacing.vLg,
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            if (item.subtitle != null) ...[
              AppSpacing.vXs,
              Text(
                item.subtitle!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            AppSpacing.vXl,
            CustomButton.primary(
              text: isSpreadsheet
                  ? 'فتح جدول البيانات في تطبيق خارجي'
                  : 'فتح المستند في تطبيق خارجي',
              icon: Icons.open_in_new_rounded,
              onPressed: _openDocument,
            ),
          ],
        ),
      ),
    );
  }
}
