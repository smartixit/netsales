import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/file_picker_service.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_form_items_section.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/containers/custom_section_container.dart';
import 'package:netsales/widgets/forms/custom_checkout_bar.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_field.dart';
import 'package:netsales/widgets/pickers/custom_file_picker.dart';

/// شاشة تسجيل وتعديل سند المصروف التشغيلي (NetworkExpenseFormScreen)
///
/// مبنية على المكونات الموحدة ونمط المقاطع النظيف:
/// - [CustomPageHeroCard] للترويسة القيادية.
/// - [CustomSectionContainer] لتجميع التاريخ، البنود، والمرفقات.
/// - [ExpenseFormItemsSection] لإدارة البنود عبر الورقة السفلية [CustomBottomSheet].
/// - [CustomFilePicker] المطور لعرض المرفقات الموجودة والجديدة بأسلوب قيد.
/// - [CustomCheckoutBar] الموحد مع التفقيط الفوري للمبلغ.
class NetworkExpenseFormScreen extends GetView<NetworkExpenseFormController> {
  const NetworkExpenseFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.totalAmount.value;
      final itemsCount = controller.items.length;

      return CustomAppScaffold(
        appBarTitle: controller.isEditMode
            ? 'تعديل المصروف التشغيلي'
            : 'تسجيل مصروف تشغيلي جديد',
        bottomNavigationBar: CustomCheckoutBar(
          metrics: [
            CheckoutMetricData(
              label: 'إجمالي المصروف',
              value: AmountFormatter.formatValue(total),
              isNet: true,
            ),
          ],
          amountForWords: total,
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
                    AppSpacing.appBarHeight + AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xl,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. ترويسة الصفحة القيادية
                        CustomPageHeroCard(
                          title: controller.isEditMode
                              ? 'تعديل بيانات المصروف التشغيلي'
                              : 'مساحة تسجيل المصروفات التشغيلية',
                          subtitle: controller.isEditMode
                              ? 'عدّل بنود المصروف أو المرفقات؛ سيتم تسوية فارق الرصيد تلقائياً في محفظة الشبكة.'
                              : 'أضف بنود المصروف والمرفقات؛ سيتم الخصم تلقائياً وبشكل فوري من محفظة الشبكة.',
                          icon: Icons.receipt_long_rounded,
                        ),
                        AppSpacing.vLg,

                        // 2. مقطع تاريخ وتوقيت الاستحقاق
                        CustomSectionContainer(
                          icon: Icons.calendar_today_rounded,
                          title: 'تاريخ استحقاق المصروف',
                          child: CustomDatePickerField.single(
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
                        ),
                        AppSpacing.vLg,

                        // 3. مقطع بنود المصروف التفاعلي
                        const ExpenseFormItemsSection(),
                        AppSpacing.vLg,

                        // 4. مقطع المرفقات والمستندات الموحد (موجودة + جديدة)
                        CustomSectionContainer(
                          icon: Icons.attach_file_rounded,
                          title: 'المرفقات والمستندات',
                          child: CustomFilePicker(
                            maxFiles: 8,
                            preset: FileTypePreset.anySafe,
                            displayMode: FilePickerDisplayMode.dropzone,
                            existingFiles: controller.existingAttachmentItems,
                            onExistingFileRemoved: (item) =>
                                controller.removeExistingAttachment(item.id),
                            onFilesChanged: controller.onAttachmentsChanged,
                          ),
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
