import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/file_size_formatter.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// قسم إضافة وإدارة المرفقات المحلية داخل نموذج المصروف
class ExpenseFormAttachmentsSection extends StatelessWidget {
  const ExpenseFormAttachmentsSection({super.key, required this.controller});

  final NetworkExpenseFormController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ترويسة قسم المرفقات
        Row(
          children: [
            Icon(
              Icons.attach_file_rounded,
              size: 18.r,
              color: colors.primary,
            ),
            AppSpacing.hXs,
            Obx(
              () => Text(
                'المرفقات والوثائق (${controller.attachmentPaths.length})',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            CustomButton.outline(
              text: 'إرفاق ملفات +',
              icon: Icons.upload_file_rounded,
              size: AppButtonSize.small,
              onPressed: controller.pickAttachments,
            ),
          ],
        ),
        AppSpacing.vSm,

        // قائمة الملفات المرفقة
        Obx(() {
          final paths = controller.attachmentPaths;
          if (paths.isEmpty) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'لم يتم إرفاق أي ملفات أو سندات بعد (اختياري).',
                style: AppTypography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: paths.map((path) {
              final file = File(path);
              final name = path.split(Platform.pathSeparator).last;
              int sizeBytes = 0;
              try {
                if (file.existsSync()) {
                  sizeBytes = file.lengthSync();
                }
              } catch (_) {}

              return Container(
                margin: EdgeInsets.only(bottom: AppSpacing.xs),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.insert_drive_file_rounded,
                        color: colors.primary,
                        size: 16.r,
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (sizeBytes > 0)
                            Text(
                              FileSizeFormatter.format(sizeBytes),
                              style: AppTypography.caption.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    AppSpacing.hSm,
                    CustomButton.icon(
                      icon: Icons.close_rounded,
                      tooltip: 'حذف المرفق',
                      iconSize: 14.r,
                      dimension: 28.r,
                      foregroundColor: colors.error,
                      backgroundColor: colors.error.withValues(alpha: 0.08),
                      onPressed: () => controller.removeAttachment(path),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
