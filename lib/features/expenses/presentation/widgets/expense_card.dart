import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card/expense_card_accordion.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card/expense_card_actions.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card/expense_card_header.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card/expense_card_metrics_bar.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة المصروف التشغيلي المتطورة (Operating Expense Card - Executive Edition)
class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
    this.isExpanded = false,
    this.onToggleExpansion,
    this.onDelete,
    this.canDelete = false,
  });

  final ExpenseEntity expense;
  final VoidCallback onTap;
  final bool isExpanded;
  final VoidCallback? onToggleExpansion;
  final VoidCallback? onDelete;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: colors.primary.withValues(alpha: .15),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.emeraldDeep.withValues(alpha: .065),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. ترويسة هوية المصروف
            ExpenseCardHeader(expense: expense),

            // 2. المحتوى الداخلي للبطاقة
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // شريط قياس المبالغ والبنود
                  ExpenseCardMetricsBar(expense: expense),
                  AppSpacing.vSm,

                  // أكورديون البنود التفاعلي
                  if (onToggleExpansion != null)
                    ExpenseCardAccordion(
                      expense: expense,
                      isExpanded: isExpanded,
                      onToggle: onToggleExpansion!,
                    ),

                  // أزرار الإجراءات السريعة
                  ExpenseCardActions(
                    expense: expense,
                    onTapDetails: onTap,
                    onDelete: onDelete,
                    canDelete: canDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
