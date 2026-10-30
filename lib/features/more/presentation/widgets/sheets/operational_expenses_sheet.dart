import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/features/more/presentation/widgets/sheets/components/create_expense_form.dart';
import 'package:netsales/features/more/presentation/widgets/sheets/components/operational_expenses_history_view.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// نافذة المصروفات التشغيلية والنفقات (OperationalExpensesSheet)
/// ============================================================================
/// مجمع تركيبي رشيق: يحتضن شريط التبديل بين سجل المصروفات واستمارة القيد،
/// ويحتفظ فقط بدورة حياة حقول الإدخال النصية ([TextEditingController]).
/// لا تُجرى أي عمليات حسابية أو تراكمات مالية على مستوى الفرونت إند.
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

  /// إرسال مدخلات المستخدم فقط إلى المتحكم (الخادم يعيد حساب كافة القيم).
  Future<void> _submitExpense() async {
    final controller = Get.find<MoreController>();
    final networkId = controller.selectedExpenseNetworkId.value;
    if (networkId == null) {
      CustomSnackbar.show(
        title: 'تحديد الشبكة',
        message: 'يرجى اختيار الشبكة التابع لها المصروف أولاً.',
        type: SnackType.warning,
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      CustomSnackbar.show(
        title: 'تنبيه إدخال',
        message: 'يرجى إدخال مبلغ مصروف صحيح.',
        type: SnackType.warning,
      );
      return;
    }

    final notes = _notesController.text.trim();
    final success = await controller.createExpense(
      networkId: networkId,
      totalAmount: amount,
      notes: notes.isNotEmpty ? notes : null,
    );

    if (success && mounted) {
      _amountController.clear();
      _notesController.clear();
      setState(() => _selectedTab = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // شريط التبديل بين العرض والإضافة
        CustomSegmentedBar(
          selectedIndex: _selectedTab,
          onSegmentChanged: (index) => setState(() => _selectedTab = index),
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
          const OperationalExpensesHistoryView()
        else
          CreateExpenseForm(
            amountController: _amountController,
            notesController: _notesController,
            onSubmit: _submitExpense,
          ),
      ],
    );
  }
}
