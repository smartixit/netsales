import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';

/// بطاقة عرض مرفق المصروف التشغيلي المتجاوبة (ExpenseAttachmentTile)
///
/// تمثل مرفقاً واحداً (صورة أو PDF أو مستند) وتفتح عارض الوسائط الموحد [MediaGalleryViewer] عند النقر.
class ExpenseAttachmentTile extends StatelessWidget {
  const ExpenseAttachmentTile({
    super.key,
    required this.attachment,
    required this.onTap,
  });

  final ExpenseAttachmentEntity attachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPdf = attachment.isPdf;
    final isImage = attachment.isImage;

    final IconData icon = isPdf
        ? Icons.picture_as_pdf_rounded
        : (isImage ? Icons.image_rounded : Icons.insert_drive_file_rounded);

    final Color iconColor = isPdf
        ? colors.error
        : (isImage ? colors.primary : colors.secondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 24.w),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      attachment.attachmentName,
                      style: AppTypography.labelLarge.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      attachment.formattedSize.isNotEmpty
                          ? attachment.formattedSize
                          : (isPdf ? 'مستند PDF' : 'ملف مرفق'),
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.w,
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
