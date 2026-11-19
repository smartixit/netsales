import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/models/media_gallery_item_model.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/file_size_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/media_gallery/media_gallery_viewer.dart';

/// بطاقة عرض ملف المرفق الرسمي للمصروف متكاملة مع [MediaGalleryViewer]
class ExpenseDetailsAttachmentCard extends StatelessWidget {
  const ExpenseDetailsAttachmentCard({
    super.key,
    required this.attachment,
  });

  final ExpenseAttachmentEntity attachment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: () {
        MediaGalleryViewer.showSingle(
          context,
          MediaGalleryItemModel(
            url: attachment.fileUrl,
            title: attachment.attachmentName,
            subtitle: FileSizeFormatter.format(attachment.attachmentSize),
            heroTag: 'expense_att_${attachment.attachmentId}',
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.insert_drive_file_rounded,
                color: colors.primary,
                size: 20.r,
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    attachment.attachmentName,
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vXxs,
                  Text(
                    FileSizeFormatter.format(attachment.attachmentSize),
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hSm,
            Icon(
              Icons.visibility_outlined,
              size: 20.r,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
