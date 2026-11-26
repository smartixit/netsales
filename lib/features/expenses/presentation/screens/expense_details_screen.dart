import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/presentation/controllers/expense_details_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_attachment_tile.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_card_accordion.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_metric_card_data.dart';
import 'package:netsales/widgets/containers/custom_section_container.dart';
import 'package:netsales/widgets/document_details/custom_document_action_bar.dart';
import 'package:netsales/widgets/document_details/custom_document_details_hero.dart';
import 'package:netsales/widgets/document_details/custom_document_item_card.dart';
import 'package:netsales/widgets/document_details/custom_document_metrics_strip.dart';
import 'package:netsales/widgets/document_details/custom_document_parties_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة تفاصيل سند المصروف التشغيلي ومرفقاته بالمعايير العالمية (ExpenseDetailsScreen)
///
/// تجسد المعمارية المؤسسية النظيفة لشاشات التفاصيل المستندية:
/// - [CustomDocumentDetailsHero] للترويسة القيادية والمرجع والشارات.
/// - [CustomDocumentMetricsStrip] للمؤشرات المالية مع تفعيل التفقيط [amountForWords].
/// - [CustomDocumentPartiesCard] لبيانات الصرف والاعتماد.
/// - [CustomSectionContainer] لبنود المصروف والمستندات والمرفقات.
/// - [CustomCardAccordion] لسجل التواريخ والتدقيق القابل للطي بأسلوب قيد.
/// - [CustomDocumentActionBar] للإجراءات السفلية السريعة.
class ExpenseDetailsScreen extends GetView<ExpenseDetailsController> {
  const ExpenseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoading.value && controller.expense.value == null) {
        return CustomAppScaffold(
          appBarTitle: 'تفاصيل المصروف',
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: const CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 4,
                cardHeight: 140,
              ),
            ),
          ),
        );
      }

      final expense = controller.expense.value;

      if (expense == null) {
        return CustomAppScaffold(
          appBarTitle: 'تفاصيل المصروف',
          body: Center(
            child: CustomEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'المصروف غير موجود',
              subtitle: 'تعذر العثور على بيانات المصروف المحدد أو تم حذفه.',
              actionLabel: 'العودة',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      final displayReference = expense.displayReference;
      const statusPres = EnumPresentation(
        label: 'مصروف تشغيلي مخصوم',
        tone: SemanticTone.info,
        icon: Icons.receipt_long_rounded,
      );

      return CustomAppScaffold(
        appBarTitle: displayReference,
        showBackButton: true,
        bottomNavigationBar: CustomDocumentActionBar(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton.primary(
                      text: 'طباعة السند',
                      icon: Icons.print_rounded,
                      size: AppButtonSize.medium,
                      shape: AppButtonShape.rounded,
                      loading: controller.isPrinting.value,
                      onPressed: controller.printCurrentExpense,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: CustomButton.secondary(
                      text: 'مشاركة PDF',
                      icon: Icons.share_rounded,
                      size: AppButtonSize.medium,
                      shape: AppButtonShape.rounded,
                      loading: controller.isSharing.value,
                      onPressed: controller.shareCurrentExpense,
                    ),
                  ),
                  AppSpacing.hSm,
                  CustomButton.icon(
                    icon: Icons.download_rounded,
                    size: AppButtonSize.medium,
                    shape: AppButtonShape.circle,
                    tooltip: 'حفظ PDF في الجهاز',
                    loading: controller.isExporting.value,
                    onPressed: controller.saveCurrentExpense,
                  ),
                  if (controller.canEditExpense) ...[
                    AppSpacing.hXs,
                    CustomButton.icon(
                      icon: Icons.edit_outlined,
                      size: AppButtonSize.medium,
                      shape: AppButtonShape.circle,
                      tooltip: 'تعديل المصروف',
                      onPressed: controller.onEditCurrentExpense,
                    ),
                  ],
                  if (controller.canDeleteExpense) ...[
                    AppSpacing.hXs,
                    CustomButton.icon(
                      icon: Icons.delete_outline_rounded,
                      size: AppButtonSize.medium,
                      shape: AppButtonShape.circle,
                      backgroundColor: colors.error.withValues(alpha: 0.1),
                      foregroundColor: colors.error,
                      tooltip: 'حذف واسترداد',
                      loading: controller.isDeleting.value,
                      onPressed: () => controller.confirmDelete(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.cardPadding,
            AppSpacing.appBarHeight + AppSpacing.md,
            AppSpacing.cardPadding,
            AppSpacing.xl,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. الترويسة القيادية
                  CustomDocumentDetailsHero(
                    reference: displayReference,
                    statusPresentation: statusPres,
                    dateLabel: expense.formattedExpenseDate,
                    heroTitle: 'سند صرف مصروف تشغيلي معتمد',
                    actorLabel:
                        expense.createdByName != null &&
                            expense.createdByName!.trim().isNotEmpty
                        ? 'سُجل بواسطة: ${expense.createdByName!.trim()}'
                        : null,
                    actorIcon: Icons.verified_user_outlined,
                    actorColor: colors.primary,
                  ),
                  AppSpacing.vMd,

                  // 2. شريط المؤشرات المالية والتفقيط
                  CustomDocumentMetricsStrip(
                    amountForWords: expense.expenseTotalAmount,
                    metrics: [
                      CustomMetricCardData(
                        label: 'إجمالي المصروف',
                        value: AmountFormatter.formatValue(
                          expense.expenseTotalAmount,
                        ),
                        unit: 'ر.ي',
                        icon: Icons.account_balance_wallet_rounded,
                        accentColor: colors.primary,
                        isPrimary: true,
                        caption: 'مخصوم من المحفظة',
                      ),
                      CustomMetricCardData(
                        label: 'عدد البنود',
                        value: '${expense.items.length}',
                        unit: 'بند',
                        icon: Icons.format_list_bulleted_rounded,
                        accentColor: colors.secondary,
                        caption: 'بيانات الصرف',
                      ),
                      CustomMetricCardData(
                        label: 'المرفقات',
                        value: '${expense.attachments.length}',
                        unit: 'ملف',
                        icon: Icons.attach_file_rounded,
                        accentColor: colors.primary,
                        caption: 'إيصالات ومستندات',
                      ),
                    ],
                  ),
                  AppSpacing.vMd,

                  // 3. بطاقة أطراف السند والاعتماد
                  CustomDocumentPartiesCard(
                    title: 'بيانات الصرف والاعتماد',
                    firstParty: DocumentPartyData(
                      roleLabel: 'الجهة المصدرة للسند (الشبكة)',
                      name: expense.networkName ?? 'الشبكة',
                      phoneNumber: expense.networkPhoneNumber,
                      logoUrl: expense.networkLogo,
                      accentColor: colors.primary,
                    ),
                    flowLabel: 'صرف نفقات تشغيلية معتمدة',
                    secondParty: DocumentPartyData(
                      roleLabel: 'المسؤول عن تسجيل الصرف',
                      name: expense.createdByName ?? 'مستخدم النظام',
                      accentColor: colors.secondary,
                    ),
                  ),
                  AppSpacing.vLg,

                  // 4. بنود المصروف التفصيلية داخل CustomSectionContainer
                  CustomSectionContainer(
                    icon: Icons.list_alt_rounded,
                    title: 'بنود المصروف (${expense.items.length})',
                    trailing: Text(
                      '${AmountFormatter.formatValue(expense.expenseTotalAmount)} ر.ي',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < expense.items.length; i++) ...[
                          if (i > 0) AppSpacing.vSm,
                          CustomDocumentItemCard(
                            index: i,
                            title: expense.items[i].itemStatement,
                            subtitle: 'بند صرف تشغيلي',
                            totalAmountFormatted: AmountFormatter.formatValue(
                              expense.items[i].itemAmount,
                            ),
                            totalAmountSubtitle: 'المبلغ المخصوم',
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 5. المرفقات والمستندات داخل CustomSectionContainer
                  if (expense.attachments.isNotEmpty) ...[
                    AppSpacing.vLg,
                    CustomSectionContainer(
                      icon: Icons.attach_file_rounded,
                      title:
                          'المستندات والمرفقات (${expense.attachments.length})',
                      trailing: Text(
                        'اضغط للمعاينة',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (
                            int j = 0;
                            j < expense.attachments.length;
                            j++
                          ) ...[
                            if (j > 0) AppSpacing.vSm,
                            ExpenseAttachmentTile(
                              attachment: expense.attachments[j],
                              onTap: () => controller.openAttachment(context, j),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // 6. سجل التواريخ والتدقيق القابل للطي بأسلوب قيد
                  AppSpacing.vLg,
                  _ExpenseAuditAccordion(
                    expense: expense,
                    isExpanded: controller.isAuditExpanded.value,
                    onToggle: controller.toggleAuditExpanded,
                  ),

                  AppSpacing.vGiant,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// قسم سجل التواريخ والتدقيق القابل للطي في تفاصيل المصروف
class _ExpenseAuditAccordion extends StatelessWidget {
  const _ExpenseAuditAccordion({
    required this.expense,
    required this.isExpanded,
    required this.onToggle,
  });

  final ExpenseEntity expense;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomCardAccordion(
      title: 'سجل التواريخ والتدقيق',
      icon: Icons.history_rounded,
      isExpanded: isExpanded,
      onToggle: onToggle,
      expandLabel: 'عرض السجل',
      collapseLabel: 'إخفاء السجل',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInfoListTile(
            leading: Icon(
              Icons.event_available_rounded,
              size: 18.r,
              color: colors.primary,
            ),
            title: Text(
              'تاريخ استحقاق المصروف',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            subtitle: Text(
              expense.formattedExpenseDate,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (expense.createdAt != null) ...[
            Divider(
              height: AppSpacing.md,
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
            CustomInfoListTile(
              leading: Icon(
                Icons.calendar_today_outlined,
                size: 18.r,
                color: colors.primary,
              ),
              title: Text(
                'تاريخ الإنشاء في النظام',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              subtitle: Text(
                DateFormatter.dateTime(expense.createdAt!),
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (expense.updatedAt != null) ...[
            Divider(
              height: AppSpacing.md,
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
            CustomInfoListTile(
              leading: Icon(
                Icons.update_rounded,
                size: 18.r,
                color: colors.primary,
              ),
              title: Text(
                'آخر تحديث',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              subtitle: Text(
                DateFormatter.dateTime(expense.updatedAt!),
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
