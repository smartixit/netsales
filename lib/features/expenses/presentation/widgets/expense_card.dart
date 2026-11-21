import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card_actions.dart';
import 'package:netsales/widgets/cards/custom_executive_transaction_card.dart';

/// بطاقة المصروف التشغيلي المتطورة بنظام الأكورديون الأنيق (ExpenseCard)
///
/// تجسد المعمارية الموحدة للمصروفات عبر استهلاك المكون القيادي الموحد [CustomExecutiveTransactionCard]:
/// حواف 24.r، ظلال مزدوجة بمسحة زمردية، شريط ترويسة بهوية السند وشعار واسم الشبكة
/// مع معرّف الـ UUID كاملاً، أكورديون تفاعلي أنيق للبنود، وسكة قياس مالية متكاملة،
/// وأزرار إجراءات موحدة ومتناسقة.
class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onDetails,
    this.isExpanded = false,
    this.onToggleExpand,
    this.onEdit,
    this.onPrint,
    this.onShare,
    this.onDelete,
    this.actions,
  });

  final ExpenseEntity expense;
  final VoidCallback onDetails;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onEdit;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    const status = EnumPresentation(
      label: 'مصروف تشغيلي',
      tone: SemanticTone.info,
      icon: Icons.receipt_long_rounded,
    );

    final actorLabel =
        expense.createdByName != null &&
            expense.createdByName!.trim().isNotEmpty
        ? 'سُجل بواسطة: ${expense.createdByName}'
        : null;

    return CustomExecutiveTransactionCard(
      reference: expense.displayReference,
      dateLabel: expense.formattedExpenseDate,
      partyName: expense.networkName ?? 'الشبكة',
      partyLogoUrl: expense.networkLogo,
      partyPhone: expense.networkPhoneNumber,
      isPartyVerified: false,
      actorLabel: actorLabel,
      statusPresentation: status,
      items: expense.items
          .map(
            (item) => ExecutiveCardItemData(
              title: item.itemStatement,
              subtitle: 'بند صرف تشغيلي',
              totalAmount: item.itemAmount,
            ),
          )
          .toList(),
      itemsHeaderTitle: 'بنود المصروف (${expense.items.length})',
      visibleItemNames: expense.items
          .map((item) => item.itemStatement)
          .toList(),
      metrics: [
        ExecutiveCardMetricData(
          label: 'إجمالي المصروف',
          value: AmountFormatter.formatValue(expense.expenseTotalAmount),
          isEmphasized: true,
        ),
        ExecutiveCardMetricData(
          label: 'عدد البنود',
          value: '${expense.items.length} بنود',
        ),
        ExecutiveCardMetricData(
          label: 'المرفقات',
          value: '${expense.attachments.length} ملفات',
        ),
      ],
      actions:
          actions ??
          ExpenseCardActions(
            expense: expense,
            onDetails: onDetails,
            onEdit: onEdit,
            onPrint: onPrint,
            onShare: onShare,
            onDelete: onDelete,
          ),
      isExpanded: isExpanded,
      onToggleExpand: onToggleExpand,
      onTap: onDetails,
    );
  }
}
