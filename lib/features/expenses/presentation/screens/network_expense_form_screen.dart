import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/file_picker_service.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_form_item_row.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/forms/custom_checkout_bar.dart';
import 'package:netsales/widgets/forms/custom_section_heading.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_field.dart';
import 'package:netsales/widgets/pickers/custom_file_picker.dart';

/// شاشة تسجيل وتعديل سند المصروف التشغيلي (NetworkExpenseFormScreen)
///
/// تجسد المعمارية المؤسسية النظيفة لشاشات النماذج والطلبات:
/// - استهلاك مباشر للمكونات العامة [CustomPageHeroCard], [CustomCheckoutBar], [CustomSectionHeading], [CustomFilePicker].
/// - تفويض كامل لحالة الحقول والإرسال والتحقق للمتحكم [NetworkExpenseFormController].
/// - تفريغ بنود الإدخال في ودجت منفصل [ExpenseFormItemRow] التزاماً بميثاق Clean Architecture وخلو تام من Helper Methods.
/// - استخدام [CustomDatePickerField.single] الموحد في النظام.
class NetworkExpenseFormScreen extends GetView<NetworkExpenseFormController> {
  const NetworkExpenseFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final total = controller.totalAmount.value;
      final itemsCount = controller.statementControllers.length;

      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(
            controller.isEditMode
                ? 'تعديل المصروف التشغيلي'
                : 'تسجيل مصروف تشغيلي جديد',
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        bottomNavigationBar: CustomCheckoutBar(
          metrics: [
            CheckoutMetricData(
              label: 'إجمالي المصروف',
              value: AmountFormatter.formatValue(total),
              isNet: true,
            ),
          ],
          itemCount: itemsCount,
          itemCountLabel: 'بند مصروف',
          actionLabel: controller.isEditMode
              ? 'حفظ وتعديل المصروف'
              : 'تسجيل وخصم المصروف',
          actionIcon: Icons.check_circle_rounded,
          isLoading: controller.isSubmitting.value,
          isActionEnabled: controller.canSubmit,
          onAction: controller.canSubmit ? controller.submitExpense : null,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth < AppBreakpoints.mobileSmallMax
                ? AppSpacing.sm
                : AppSpacing.cardPadding;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.maxFormWidth,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xl,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. ترويسة الصفحة القيادية (CustomPageHeroCard)
                        CustomPageHeroCard(
                          title: controller.isEditMode
                              ? 'تعديل بيانات المصروف التشغيلي'
                              : 'مساحة تسجيل المصروفات التشغيلية',
                          subtitle: controller.isEditMode
                              ? 'عدّل بنود المصروف أو المرفقات؛ سيتم تسوية فارق الرصيد تلقائياً في محفظة الشبكة.'
                              : 'أدخل بنود المصروف والمبالغ والمرفقات؛ سيتم الخصم تلقائياً وبشكل فوري من محفظة الشبكة.',
                          icon: Icons.receipt_long_rounded,
                        ),
                        AppSpacing.vMd,

                        // 2. تاريخ وتوقيت المصروف
                        const CustomSectionHeading(
                          title: 'تاريخ استحقاق المصروف',
                          subtitle: 'حدد تاريخ صرف النفقات التشغيلية',
                          icon: Icons.calendar_today_rounded,
                        ),
                        AppSpacing.vXs,
                        CustomDatePickerField.single(
                          label: 'تاريخ ووقت استحقاق المصروف',
                          hint: 'اختر تاريخ استحقاق المصروف...',
                          value: controller.selectedDate.value,
                          enableTime: true,
                          isRequired: true,
                          dialogTitle: 'اختر تاريخ استحقاق المصروف',
                          onChanged: (picked) {
                            if (picked != null) {
                              controller.setDate(picked);
                            }
                          },
                        ),
                        AppSpacing.vLg,

                        // 3. بنود المصروف التفصيلية (مستقلة في ExpenseFormItemRow)
                        CustomSectionHeading(
                          title: 'بنود المصروف التفصيلية ($itemsCount)',
                          subtitle:
                              'أضف بياناً ومبلغاً لكل بند من بنود المصروف',
                          icon: Icons.list_alt_rounded,
                          trailing: CustomButton.secondary(
                            text: 'إضافة بند +',
                            icon: Icons.add_rounded,
                            size: AppButtonSize.small,
                            shape: AppButtonShape.pill,
                            onPressed: controller.addItemRow,
                          ),
                        ),
                        AppSpacing.vXs,

                        for (int i = 0; i < itemsCount; i++) ...[
                          if (i > 0) AppSpacing.vSm,
                          ExpenseFormItemRow(
                            statementController:
                                controller.statementControllers[i],
                            amountController: controller.amountControllers[i],
                            index: i,
                            onRemove: itemsCount > 1
                                ? () => controller.removeItemRow(i)
                                : null,
                          ),
                        ],
                        AppSpacing.vLg,

                        // 4. المرفقات الثبوتية عبر المكون الموحد CustomFilePicker
                        CustomSectionHeading(
                          title:
                              'المرفقات والمستندات الثبوتية (${controller.attachments.length})',
                          subtitle:
                              'أرفق صور الفواتير أو الإيصالات أو مستندات الصرف الرسمية',
                          icon: Icons.attach_file_rounded,
                        ),
                        AppSpacing.vXs,

                        CustomFilePicker(
                          maxFiles: 8,
                          preset: FileTypePreset.anySafe,
                          displayMode: FilePickerDisplayMode.dropzone,
                          hint:
                              'اسحب المستندات هنا أو اضغط لاختيار الملفات (PDF / صور)',
                          onFilesChanged: controller.onAttachmentsChanged,
                        ),
                        AppSpacing.vXxl,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
