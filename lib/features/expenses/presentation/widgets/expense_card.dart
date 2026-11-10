import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
    this.onDelete,
  });

  final ExpenseEntity expense;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomButton.outline(
      width: double.infinity,
      onPressed: onTap,
      padding: EdgeInsets.all(AppSpacing.md),
      borderColor: colors.outlineVariant.withValues(alpha: .55),
      foregroundColor: colors.onSurface,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: colors.onPrimaryContainer,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'سند صرف #${expense.expenseId}',
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      AmountFormatter.formatValue(expense.totalAmount),
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vXs,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        expense.expenseDate ?? '—',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (expense.attachments.isNotEmpty) ...[
                      Icon(
                        Icons.attach_file_rounded,
                        size: 14,
                        color: colors.onSurfaceVariant,
                      ),
                      AppSpacing.hXs,
                      Text(
                        '${expense.attachments.length}',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                if (expense.items.isNotEmpty) ...[
                  AppSpacing.vXs,
                  Text(
                    expense.items.first.statement,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null) ...[
            AppSpacing.hSm,
            CustomButton.icon(
              icon: Icons.delete_outline_rounded,
              foregroundColor: colors.error,
              tooltip: 'حذف المصروف',
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

