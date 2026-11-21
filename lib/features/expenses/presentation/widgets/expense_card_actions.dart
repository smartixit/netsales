import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط أزرار الإجراءات التفاعلية لبطاقة المصروف التشغيلي (ExpenseCardActions)
class ExpenseCardActions extends StatelessWidget {
  const ExpenseCardActions({
    super.key,
    required this.expense,
    required this.onDetails,
    this.onEdit,
    this.onPrint,
    this.onShare,
    this.onDelete,
  });

  final ExpenseEntity expense;
  final VoidCallback onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        // زر التفاصيل الرئيسي
        Expanded(
          child: CustomButton.secondary(
            text: 'تفاصيل المصروف',
            icon: Icons.receipt_long_rounded,
            size: AppButtonSize.small,
            shape: AppButtonShape.pill,
            onPressed: onDetails,
          ),
        ),

        // زر التعديل المعتمد
        if (onEdit != null) ...[
          const SizedBox(width: 8),
          CustomButton.icon(
            icon: Icons.edit_outlined,
            size: AppButtonSize.small,
            shape: AppButtonShape.circle,
            backgroundColor: colors.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            foregroundColor: colors.primary,
            tooltip: 'تعديل المصروف',
            onPressed: onEdit,
          ),
        ],
        if (onPrint != null) ...[
          const SizedBox(width: 8),
          CustomButton.icon(
            icon: Icons.print_outlined,
            size: AppButtonSize.small,
            shape: AppButtonShape.circle,
            backgroundColor: colors.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            foregroundColor: colors.onSurfaceVariant,
            tooltip: 'طباعة السند',
            onPressed: onPrint,
          ),
        ],

        // زر المشاركة السريعة الموحد
        if (onShare != null) ...[
          const SizedBox(width: 6),
          CustomButton.icon(
            icon: Icons.share_outlined,
            size: AppButtonSize.small,
            shape: AppButtonShape.circle,
            backgroundColor: colors.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            foregroundColor: colors.onSurfaceVariant,
            tooltip: 'مشاركة السند',
            onPressed: onShare,
          ),
        ],

        // زر الحذف المعتمد
        if (onDelete != null) ...[
          const SizedBox(width: 6),
          CustomButton.icon(
            icon: Icons.delete_outline_rounded,
            size: AppButtonSize.small,
            shape: AppButtonShape.circle,
            backgroundColor: colors.error.withValues(alpha: 0.08),
            foregroundColor: colors.error,
            tooltip: 'حذف واسترداد',
            onPressed: onDelete,
          ),
        ],
      ],
    );
  }
}
