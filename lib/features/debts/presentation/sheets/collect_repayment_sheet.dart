import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/debts/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/debts/presentation/controllers/network_debts_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class CollectRepaymentSheet extends StatefulWidget {
  final PosDebtBreakdownEntity pos;

  const CollectRepaymentSheet({super.key, required this.pos});

  static Future<void> show(BuildContext context, PosDebtBreakdownEntity pos) {
    return CustomBottomSheet.show<void>(
      title: 'تحصيل سداد مديونية',
      subtitle: '${pos.posName} • سداد الفواتير الآجلة وتغذية السيولة',
      leadingIcon: Icons.payments_rounded,
      scrollable: true,
      child: CollectRepaymentSheet(pos: pos),
    );
  }

  @override
  State<CollectRepaymentSheet> createState() => _CollectRepaymentSheetState();
}

class _CollectRepaymentSheetState extends State<CollectRepaymentSheet> {
  final NetworkDebtsController controller = Get.find<NetworkDebtsController>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController refController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedPaymentMethod = 'CASH';
  List<Map<String, dynamic>> fifoAllocations = [];

  static const List<Map<String, String>> paymentMethods = [
    {'key': 'CASH', 'label': 'نقداً (كاش)'},
    {'key': 'BANK_TRANSFER', 'label': 'تحويل بنكي'},
    {'key': 'CHEQUE', 'label': 'شيك'},
    {'key': 'OTHER', 'label': 'أخرى'},
  ];

  @override
  void initState() {
    super.initState();
    controller.loadOutstandingInvoices(widget.pos.posId);
  }

  @override
  void dispose() {
    amountController.dispose();
    refController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final amount = double.tryParse(val) ?? 0.0;
    setState(() {
      fifoAllocations = controller.previewFifoAllocation(amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalDebt = widget.pos.outstandingDebt;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // إجمالي المديونية المستحقة
          Container(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: colors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إجمالي المديونية المستحقة', style: AppTypography.labelSmall.copyWith(color: colors.error)),
                    Text(
                      '${AmountFormatter.formatValue(totalDebt, decimalPlaces: 0)} ر.ي',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.error,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.receipt_long_rounded, color: colors.error, size: 28.r),
              ],
            ),
          ),
          AppSpacing.vMd,
          // اختيار طريقة الدفع
          Text(
            'طريقة الدفع والتسليم',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.vSm,
          Wrap(
            spacing: 8.w,
            children: paymentMethods.map((m) {
              final isSelected = selectedPaymentMethod == m['key'];
              return ChoiceChip(
                label: Text(m['label']!),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => selectedPaymentMethod = m['key']!);
                },
              );
            }).toList(),
          ),
          AppSpacing.vMd,
          // إدخال المبلغ
          CustomTextField(
            controller: amountController,
            label: 'مبلغ السداد المقبوض (ر.ي)',
            hint: 'أدخل المبلغ المحصل...',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.attach_money_rounded),
            onChanged: _onAmountChanged,
          ),
          AppSpacing.vXs,
          Text(
            'الحد الأقصى المسموح به: ${AmountFormatter.formatValue(totalDebt, decimalPlaces: 0)} ر.ي',
            style: AppTypography.labelSmall.copyWith(color: colors.primary),
          ),
          AppSpacing.vSm,
          // زر سداد كامل المديونية دفعة واحدة
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                amountController.text = totalDebt.toStringAsFixed(0);
                _onAmountChanged(totalDebt.toStringAsFixed(0));
              },
              icon: const Icon(Icons.all_inclusive_rounded, size: 16),
              label: const Text('سداد كامل المبلغ دفعة واحدة'),
            ),
          ),
          // معاينة التوزيع الحتمي (FIFO Preview)
          if (fifoAllocations.isNotEmpty) ...[
            AppSpacing.vSm,
            Text(
              'معاينة التوزيع الحتمي على الفواتير الأقدم (FIFO Preview):',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            AppSpacing.vXs,
            Container(
              constraints: BoxConstraints(maxHeight: 180.h),
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: fifoAllocations.length,
                separatorBuilder: (ctx, idx) => const Divider(height: 8),
                itemBuilder: (context, index) {
                  final item = fifoAllocations[index];
                  final uuid = item['invoice_uuid']?.toString() ?? '';
                  final days = (item['days_outstanding'] as num?)?.toInt() ?? 0;
                  final isFull = item['is_fully_paid'] == true;
                  final allocated = (item['allocated_amount'] as num?)?.toDouble() ?? 0.0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            uuid,
                            style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'العمر: $days يوم (${isFull ? "سداد كامل" : "سداد جزئي"})',
                            style: AppTypography.labelSmall.copyWith(
                              color: isFull ? const Color(0xFF10B981) : colors.warning,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${AmountFormatter.formatValue(allocated, decimalPlaces: 0)} ر.ي',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          AppSpacing.vMd,
          CustomTextField(
            controller: refController,
            label: 'رقم السند المرجعي / الإشعار (اختياري)',
            hint: 'مثال: REF-987654',
            isRequired: false,
            prefixIcon: const Icon(Icons.tag_rounded),
          ),
          AppSpacing.vSm,
          CustomTextField(
            controller: notesController,
            label: 'ملاحظات وتفاصيل إضافية (اختياري)',
            hint: 'أي بيان بخصوص السداد...',
            isRequired: false,
            prefixIcon: const Icon(Icons.notes_rounded),
            maxLines: 2,
          ),
          AppSpacing.vLg,
          Obx(() => CustomButton(
                text: 'تأكيد وقيد سند السداد',
                icon: Icons.check_circle_rounded,
                loading: controller.isSubmittingPayment.value,
                onPressed: () async {
                  final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                  if (amount <= 0) {
                    CustomSnackbar.show(
                      title: 'تنبيه',
                      message: 'يجب إدخال مبلغ سداد أكبر من الصفر',
                      type: SnackType.warning,
                    );
                    return;
                  }
                  if (amount > totalDebt + 0.001) {
                    CustomSnackbar.show(
                      title: 'خطأ محاسبي',
                      message: 'لا يمكن سداد مبلغ أكبر من إجمالي المديونية المستحقة',
                      type: SnackType.error,
                    );
                    return;
                  }

                  final success = await controller.collectRepayment(
                    posId: widget.pos.posId,
                    amount: amount,
                    paymentMethod: selectedPaymentMethod,
                    referenceNumber: refController.text.trim().isNotEmpty ? refController.text.trim() : null,
                    notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                  );

                  if (success) {
                    Get.back<void>();
                  }
                },
              )),
          AppSpacing.vMd,
        ],
      ),
    );
  }
}
