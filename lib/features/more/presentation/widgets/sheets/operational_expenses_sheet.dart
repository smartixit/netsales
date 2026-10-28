import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/more/domain/entities/expense_entity.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// نافذة المصروفات التشغيلية والنفقات (OperationalExpensesSheet)
/// ============================================================================
/// تعرض سجل النفقات التشغيلية المسترجعة من الخادم وتتيح قيد مصروف جديد
/// دون إجراء أي عمليات حسابية أو تراكمات مالية على مستوى الفرونت إند.
class OperationalExpensesSheet extends StatefulWidget {
  const OperationalExpensesSheet({super.key});

  /// فتح النافذة السفلية المنبثقة
  static Future<void> show(BuildContext context) {
    final controller = Get.find<MoreController>();
    controller.loadExpenses();
    controller.loadNetworksForExpenses();

    return CustomBottomSheet.show<void>(
      title: 'المصروفات والنفقات التشغيلية',
      subtitle: 'سجل القيود المالية وتسجيل نفقات وإيصالات المنشأة',
      leadingIcon: Icons.payments_rounded,
      scrollable: true,
      child: const OperationalExpensesSheet(),
    );
  }

  @override
  State<OperationalExpensesSheet> createState() =>
      _OperationalExpensesSheetState();
}

class _OperationalExpensesSheetState extends State<OperationalExpensesSheet> {
  int _selectedTab = 0; // 0: السجل والقائمة، 1: قيد مصروف جديد

  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitExpense(MoreController controller) async {
    final networkId = controller.selectedExpenseNetworkId.value;
    if (networkId == null) {
      CustomSnackbar.show(
        title: 'تحديد الشبكة',
        message: 'يرجى اختيار الشبكة التابع لها المصروف أولاً.',
        type: SnackType.warning,
      );
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      CustomSnackbar.show(
        title: 'تنبيه إدخال',
        message: 'يرجى إدخال مبلغ مصروف صحيح.',
        type: SnackType.warning,
      );
      return;
    }

    final success = await controller.createExpense(
      networkId: networkId,
      totalAmount: amount,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (success) {
      _amountController.clear();
      _notesController.clear();
      setState(() => _selectedTab = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MoreController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // شريط التبديل بين العرض والإضافة
        CustomSegmentedBar(
          selectedIndex: _selectedTab,
          onSegmentChanged: (idx) => setState(() => _selectedTab = idx),
          items: const [
            CustomSegmentItem(
              label: 'سجل المصروفات',
              icon: Icons.receipt_long_rounded,
            ),
            CustomSegmentItem(
              label: 'قيد مصروف جديد',
              icon: Icons.add_circle_outline_rounded,
            ),
          ],
        ),

        AppSpacing.vLg,

        if (_selectedTab == 0)
          _buildExpensesList(context, controller)
        else
          _buildCreateExpenseForm(context, controller),
      ],
    );
  }

  Widget _buildExpensesList(BuildContext context, MoreController controller) {
    final colors = context.colors;

    return Obx(() {
      final isLoading = controller.isLoadingExpenses.value;
      final errorMessage = controller.expensesErrorMessage.value;
      final expenses = controller.expenses;

      if (isLoading && expenses.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const CustomSkeletonFeed(itemCount: 4, cardHeight: 90),
        );
      }

      if (errorMessage.isNotEmpty && expenses.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
          child: Column(
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48.r, color: colors.error),
              AppSpacing.vMd,
              Text(
                errorMessage,
                style: AppTypography.bodyMedium
                    .copyWith(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vLg,
              CustomButton.outline(
                text: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                onPressed: () => controller.loadExpenses(isRefresh: true),
              ),
            ],
          ),
        );
      }

      if (expenses.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Center(
            child: Text(
              'لا توجد مصروفات تشغيلية مسجلة حالياً.',
              style: AppTypography.bodyMedium
                  .copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        );
      }

      return Column(
        children: expenses
            .map(
              (expense) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ExpenseItemCard(expense: expense),
              ),
            )
            .toList(),
      );
    });
  }

  Widget _buildCreateExpenseForm(
    BuildContext context,
    MoreController controller,
  ) {
    final colors = context.colors;

    return Obx(() {
      final isSubmitting = controller.isSubmittingAction.value;
      final networks = controller.availableNetworks;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 0. اختيار الشبكة التابع لها المصروف مطابق لأسلوب sales_sheet
          if (networks.length > 1) ...[
            CustomDropdown<int>(
              label: 'الشبكة التابع لها المصروف',
              hint: 'اختر الشبكة',
              prefixIcon: Icons.cell_tower_rounded,
              valueListenable: controller.selectedExpenseNetworkId,
              items: networks
                  .map(
                    (net) => DropdownItem<int>(
                      value: net.networkId,
                      child: Text(net.networkName),
                    ),
                  )
                  .toList(),
              itemSearchText: (id) =>
                  networks
                      .cast<NetworkEntity?>()
                      .firstWhere((n) => n?.networkId == id, orElse: () => null)
                      ?.networkName ??
                  '',
              onChanged: controller.onExpenseNetworkChanged,
            ),
            AppSpacing.vMd,
          ],

          CustomTextField(
            controller: _amountController,
            label: 'مبلغ المصروف التشغيلي',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.monetization_on_outlined),
            suffixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                'ر.ي',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AppSpacing.vMd,
          CustomTextField(
            controller: _notesController,
            label: 'بيان المصروف والملاحظات',
            hint: 'مثال: إيجار المقر، صيانة شبكة، نثريات...',
            prefixIcon: const Icon(Icons.notes_rounded),
            isRequired: false,
          ),
          AppSpacing.vXl,
          CustomButton.primary(
            text: 'تسجيل وقيد المصروف فورياً',
            icon: Icons.check_circle_outline_rounded,
            loading: isSubmitting,
            onPressed: isSubmitting ? null : () => _submitExpense(controller),
          ),
        ],
      );
    });
  }
}

/// بطاقة تفاصيل قيد المصروف في السجل
class _ExpenseItemCard extends StatelessWidget {
  final ExpenseEntity expense;

  const _ExpenseItemCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateStr = expense.expenseDate != null
        ? DateFormat('yyyy/MM/dd').format(expense.expenseDate!)
        : 'اليوم';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: colors.error,
              size: 20.r,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قيد مصروف #${expense.expenseId}',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vXs,
                Text(
                  '$dateStr • ${expense.createdByName ?? "الإدارة"}',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- ${AmountFormatter.format(expense.expenseTotalAmount.toStringAsFixed(2))} ر.ي',
            style: AppTypography.titleSmall.copyWith(
              color: colors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
