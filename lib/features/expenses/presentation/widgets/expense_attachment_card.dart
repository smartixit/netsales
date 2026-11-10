import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/models/media_gallery_item_model.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/file_size_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/media_gallery/media_gallery_viewer.dart';

class ExpenseAttachmentCard extends StatelessWidget {
  const ExpenseAttachmentCard({
    super.key,
    required this.attachment,
    this.onDelete,
  });

  final ExpenseAttachmentEntity attachment;
  final VoidCallback? onDelete;

  void _handleOpen(BuildContext context) {
    final url = attachment.fileUrl;
    if (url == null || url.isEmpty) return;

    final isImage = attachment.mimeType?.startsWith('image/') ?? false;
    final isPdf = attachment.mimeType?.contains('pdf') ?? false;

    if (isImage || isPdf) {
      MediaGalleryViewer.show(
        context,
        items: [
          MediaGalleryItemModel(
            url: url,
            title: attachment.name,
            subtitle: attachment.sizeBytes > 0
                ? FileSizeFormatter.format(attachment.sizeBytes)
                : null,
            type: isPdf ? MediaGalleryType.pdf : MediaGalleryType.image,
          ),
        ],
      );
    } else {
      UrlLauncherService.openInExternalBrowser(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isImage = attachment.mimeType?.startsWith('image/') ?? false;
    final isPdf = attachment.mimeType?.contains('pdf') ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isImage
                  ? colors.primaryContainer.withValues(alpha: .5)
                  : isPdf
                      ? colors.error.withValues(alpha: .15)
                      : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isImage
                  ? Icons.image_outlined
                  : isPdf
                      ? Icons.picture_as_pdf_outlined
                      : Icons.attach_file_rounded,
              color: isImage
                  ? colors.primary
                  : isPdf
                      ? colors.error
                      : colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  attachment.sizeBytes > 0
                      ? FileSizeFormatter.format(attachment.sizeBytes)
                      : 'مستند مرفق',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (attachment.fileUrl != null && attachment.fileUrl!.isNotEmpty)
            CustomButton.icon(
              icon: Icons.visibility_outlined,
              tooltip: 'معاينة المرفق',
              onPressed: () => _handleOpen(context),
            ),
          if (onDelete != null)
            CustomButton.icon(
              icon: Icons.delete_outline_rounded,
              foregroundColor: colors.error,
              tooltip: 'حذف المرفق',
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
