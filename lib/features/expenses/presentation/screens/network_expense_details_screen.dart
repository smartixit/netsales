import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_operating_expenses_controller.dart';
import 'package:netsales/features/expenses/presentation/screens/network_expense_form_screen.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_attachment_card.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_item_row.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class NetworkExpenseDetailsScreen
    extends GetView<NetworkOperatingExpensesController> {
  const NetworkExpenseDetailsScreen({super.key, required this.expenseId});

  final int expenseId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      showBackButton: true,
      appBarTitle: 'تفاصيل المصروف #$expenseId',
      appBarSubtitle: 'بيانات سند الصرف والبنود والمرفقات',
      actions: [
        if (controller.canDelete)
          Padding(
            padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
            child: CustomButton.icon(
              icon: Icons.delete_outline_rounded,
              foregroundColor: colors.error,
              tooltip: 'حذف المصروف',
              onPressed: () => controller.confirmAndDeleteExpense(expenseId),
            ),
          ),
      ],
      body: Obx(() {
        if (controller.isLoadingDetails.value) {
          return const CustomSkeletonFeed(itemCount: 4);
        }

        final expense = controller.selectedExpense.value;
        if (expense == null) {
          return CustomErrorState.compact(
            title: 'تعذر عرض المصروف',
            subtitle: 'لم يتم تحميل تفاصيل هذا السجل أو تم نقله للمهملات.',
            onRetry: () => controller.loadDetails(expenseId),
          );
        }

        return ListView(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          children: [
            // 1. بطاقة الرصيد الإجمالي ومحدد التاريخ
            Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.primary.withValues(alpha: .85),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إجمالي المصروف المعتمد',
                        style: AppTypography.labelLarge.copyWith(
                          color: colors.onPrimary.withValues(alpha: .85),
                        ),
                      ),
                      if (expense.createdByName != null)
                        Text(
                          'بواسطة: ${expense.createdByName}',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onPrimary.withValues(alpha: .75),
                          ),
                        ),
                    ],
                  ),
                  AppSpacing.vXs,
                  Text(
                    AmountFormatter.formatValue(expense.totalAmount),
                    style: AppTypography.headlineMedium.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vXs,
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: colors.onPrimary.withValues(alpha: .85),
                      ),
                      AppSpacing.hXs,
                      Text(
                        expense.expenseDate ?? '—',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onPrimary.withValues(alpha: .9),
                        ),
                      ),
                      if (expense.networkName != null) ...[
                        AppSpacing.hMd,
                        Icon(
                          Icons.account_tree_outlined,
                          size: 14,
                          color: colors.onPrimary.withValues(alpha: .85),
                        ),
                        AppSpacing.hXs,
                        Text(
                          expense.networkName!,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onPrimary.withValues(alpha: .9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            AppSpacing.vLg,

            // 2. تفاصيل بنود المصروف
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تفاصيل البنود (${expense.items.length})',
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'الإجمالي: ${AmountFormatter.formatValue(expense.totalAmount)}',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            AppSpacing.vSm,
            if (expense.items.isEmpty)
              const CustomEmptyState.compact(
                title: 'لا توجد بنود مفصلة',
                icon: Icons.receipt_outlined,
              )
            else
              ...List.generate(
                expense.items.length,
                (i) => ExpenseItemRow(item: expense.items[i], index: i),
              ),

            AppSpacing.vLg,

            // 3. المرفقات والمستندات الداعمة
            Text(
              'المرفقات والمستندات (${expense.attachments.length})',
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vSm,
            if (expense.attachments.isEmpty)
              const CustomEmptyState.compact(
                title: 'لا توجد مرفقات داعمة',
                icon: Icons.attach_file_rounded,
              )
            else
              ...expense.attachments.map(
                (att) => ExpenseAttachmentCard(
                  attachment: att,
                  onDelete: controller.canDeleteAttachment
                      ? () => controller.confirmAndDeleteAttachment(att)
                      : null,
                ),
              ),

            // 4. إجراء التعديل
            if (controller.canEdit) ...[
              AppSpacing.vLg,
              CustomButton.primary(
                width: double.infinity,
                text: 'تعديل المصروف',
                prefix: Icons.edit_outlined,
                onPressed: () {
                  controller.prepareEditForm(expense);
                  Get.to<void>(() => const NetworkExpenseFormScreen());
                },
              ),
            ],
          ],
        );
      }),
    );
  }
}
