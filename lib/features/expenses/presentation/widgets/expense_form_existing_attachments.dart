import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/forms/custom_section_heading.dart';

/// ودجت عرض وإدارة المرفقات المسجلة مسبقاً في شاشة تعديل المصروف (ExpenseFormExistingAttachments)
///
/// يتيح للمستخدم استعراض المرفقات الحالية للمصروف وحذف أي منها بشكل ذري (Atomic API Payload)
/// حيث يتم إرسال معرفات المرفقات المراد حذفها في نفس طلب الحفظ النهائي.
class ExpenseFormExistingAttachments
    extends GetView<NetworkExpenseFormController> {
  const ExpenseFormExistingAttachments({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final attachments = controller.existingAttachments;
      if (attachments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSectionHeading(
            title: 'المرفقات المسجلة حالياً (${attachments.length})',
            subtitle: 'سيتم حذف المرفقات المحددة تلقائياً عند حفظ التعديلات',
            icon: Icons.folder_shared_rounded,
          ),
          AppSpacing.vXs,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attachments.length,
            separatorBuilder: (context, index) => AppSpacing.vSm,
            itemBuilder: (context, index) {
              final att = attachments[index];
              return _ExistingAttachmentItem(
                attachment: att,
                onDelete: () => controller.removeExistingAttachment(att.attachmentId),
              );
            },
          ),
          AppSpacing.vLg,
        ],
      );
    });
  }
}

class _ExistingAttachmentItem extends StatelessWidget {
  const _ExistingAttachmentItem({
    required this.attachment,
    required this.onDelete,
  });

  final ExpenseAttachmentEntity attachment;
  final VoidCallback onDelete;

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

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor, size: 22.w),
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
                      : (isPdf ? 'مستند PDF مسجل' : 'ملف مرفق مسجل'),
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          CustomButton.icon(
            icon: Icons.delete_outline_rounded,
            size: AppButtonSize.small,
            shape: AppButtonShape.circle,
            backgroundColor: colors.error.withValues(alpha: 0.08),
            foregroundColor: colors.error,
            tooltip: 'حذف المرفق',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
