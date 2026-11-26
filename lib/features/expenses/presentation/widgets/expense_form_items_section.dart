import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_form_item_row.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_item_bottom_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/containers/custom_section_container.dart';

/// مقطع بنود المصروف التفصيلية بأسلوب الفواتير في قيد (ExpenseFormItemsSection)
///
/// يجمع داخل [CustomSectionContainer]:
/// - حالة الفراغ التفاعلية عند عدم وجود بنود.
/// - قائمة بطاقات البنود المضافة مع النقر للتعديل والسحب للحذف.
/// - شريط ملخص عدد البنود والإجمالي.
/// - زر إضافة بند جديد بعرض كامل يفتح [ExpenseItemBottomSheet].
class ExpenseFormItemsSection extends GetView<NetworkExpenseFormController> {
  const ExpenseFormItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.items;
      final total = controller.totalAmount.value;

      return CustomSectionContainer(
        icon: Icons.list_alt_rounded,
        title: 'بنود المصروف (${items.length})',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (items.isEmpty)
              _EmptyExpenseItemsBox(
                onTap: () => _openAddSheet(context),
              )
            else ...[
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) AppSpacing.vSm,
                ExpenseFormItemCard(
                  item: items[i],
                  index: i,
                  onEdit: () => _openEditSheet(context, i),
                  onRemove: () => controller.removeItem(i),
                ),
              ],
              AppSpacing.vMd,
              _ExpenseItemsSummaryBanner(
                itemsCount: items.length,
                totalAmount: total,
              ),
            ],
            AppSpacing.vMd,
            CustomButton.outline(
              text: 'إضافة بند جديد',
              icon: Icons.add_rounded,
              width: double.infinity,
              shape: AppButtonShape.rounded,
              onPressed: () => _openAddSheet(context),
            ),
          ],
        ),
      );
    });
  }

  void _openAddSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    ExpenseItemBottomSheet.show(context, controller: controller);
  }

  void _openEditSheet(BuildContext context, int index) {
    HapticFeedback.lightImpact();
    ExpenseItemBottomSheet.show(
      context,
      controller: controller,
      editIndex: index,
    );
  }
}

/// صندوق حالة الفراغ التفاعلي عند عدم وجود بنود مصروف
class _EmptyExpenseItemsBox extends StatelessWidget {
  const _EmptyExpenseItemsBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 44.r,
              color: colors.outline,
            ),
            AppSpacing.vMd,
            Text(
              'لا توجد بنود بعد',
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vXs,
            Text(
              'أضف بنداً واحداً على الأقل لإكمال سند المصروف',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شريط ملخص عدد البنود وإجمالي مبالغها
class _ExpenseItemsSummaryBanner extends StatelessWidget {
  const _ExpenseItemsSummaryBanner({
    required this.itemsCount,
    required this.totalAmount,
  });

  final int itemsCount;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 18.r,
            color: colors.primary,
          ),
          AppSpacing.hXs,
          Text(
            '$itemsCount بند مسجل',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          Text(
            'الإجمالي: ${AmountFormatter.formatValue(totalAmount)} ر.ي',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
