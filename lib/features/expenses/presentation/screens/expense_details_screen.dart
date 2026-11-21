import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/presentation/controllers/expense_details_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_attachment_tile.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_metric_card_data.dart';
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
/// - استهلاك مباشر وموحد للمكونات القيادية العامة [CustomDocumentDetailsHero],
///   [CustomDocumentMetricsStrip], [CustomDocumentPartiesCard], [CustomDocumentItemCard], [CustomDocumentActionBar].
/// - دمج المعرض التفاعلي الموحد [MediaGalleryViewer] لعرض ومعاينة الصور ومستندات الـ PDF المرفقة.
class ExpenseDetailsScreen extends GetView<ExpenseDetailsController> {
  const ExpenseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الهيكلي (Skeleton State)
      if (controller.isLoading.value && controller.expense.value == null) {
        return CustomAppScaffold(
          appBar: AppBar(
            title: const Text('تفاصيل المصروف'),
            centerTitle: true,
          ),
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

      // 2. حالة عدم العثور على المصروف
      if (expense == null) {
        return CustomAppScaffold(
          appBar: AppBar(
            title: const Text('تفاصيل المصروف'),
            centerTitle: true,
          ),
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

      // 3. عرض صفحة التفاصيل المتكاملة
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
                      shape: AppButtonShape.pill,
                      loading: controller.isPrinting.value,
                      onPressed: controller.printCurrentExpense,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: CustomButton.secondary(
                      text: 'مشاركة PDF',
                      icon: Icons.share_rounded,
                      size: AppButtonSize.medium,
                      shape: AppButtonShape.pill,
                      loading: controller.isSharing.value,
                      onPressed: controller.shareCurrentExpense,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  CustomButton.icon(
                    icon: Icons.download_rounded,
                    size: AppButtonSize.medium,
                    shape: AppButtonShape.circle,
                    tooltip: 'حفظ PDF في الجهاز',
                    loading: controller.isExporting.value,
                    onPressed: controller.saveCurrentExpense,
                  ),
                  if (controller.canEditExpense) ...[
                    SizedBox(width: AppSpacing.xs),
                    CustomButton.icon(
                      icon: Icons.edit_outlined,
                      size: AppButtonSize.medium,
                      shape: AppButtonShape.circle,
                      tooltip: 'تعديل المصروف',
                      onPressed: controller.onEditCurrentExpense,
                    ),
                  ],
                  if (controller.canDeleteExpense) ...[
                    SizedBox(width: AppSpacing.xs),
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
            AppSpacing.cardPadding,
            AppSpacing.cardPadding,
            AppSpacing.xl,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. الترويسة القيادية بالعمق اللوني المتكيف (CustomDocumentDetailsHero)
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

                  // 2. شريط المؤشرات المالية والتشغيلية الموحد (CustomDocumentMetricsStrip)
                  CustomDocumentMetricsStrip(
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

                  // 3. بطاقة بيانات أطراف سند المصروف (CustomDocumentPartiesCard)
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

                  // 4. جدول بنود المصروف التفصيلية (CustomDocumentItemCard)
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt_rounded,
                        size: 18.r,
                        color: colors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'بنود المصروف التفصيلية (${expense.items.length})',
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        AmountFormatter.formatValue(expense.expenseTotalAmount),
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vSm,

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
                  AppSpacing.vLg,

                  // 5. المرفقات والمستندات مع تكامل MediaGalleryViewer
                  if (expense.attachments.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.attach_file_rounded,
                          size: 18.r,
                          color: colors.primary,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            'المستندات والمرفقات (${expense.attachments.length})',
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          'اضغط للمعاينة',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vSm,

                    for (int j = 0; j < expense.attachments.length; j++) ...[
                      if (j > 0) AppSpacing.vSm,
                      ExpenseAttachmentTile(
                        attachment: expense.attachments[j],
                        onTap: () => controller.openAttachment(context, j),
                      ),
                    ],
                  ],

                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
