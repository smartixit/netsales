import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/procurement_request_details_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_action_row.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_notes_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_invoice_callout.dart';
import 'package:netsales/features/requests/presentation/widgets/request_modification_summary_panel.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/cards/custom_metric_card_data.dart';
import 'package:netsales/widgets/document_details/custom_document_action_bar.dart';
import 'package:netsales/widgets/document_details/custom_document_details_hero.dart';
import 'package:netsales/widgets/document_details/custom_document_item_card.dart';
import 'package:netsales/widgets/document_details/custom_document_metrics_strip.dart';
import 'package:netsales/widgets/document_details/custom_document_parties_card.dart';
import 'package:netsales/widgets/document_details/custom_document_timeline.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة تفاصيل طلب التوريد بالمعايير العالمية والعمق البصري الفاخر (ProcurementRequestDetailsScreen)
///
/// تجسد المعمارية المؤسسية النظيفة لشاشات التفاصيل المستندية:
/// - استهلاك مباشر للمكونات العامة الموحدة [CustomDocumentDetailsHero], [CustomDocumentMetricsStrip],
///   [CustomDocumentPartiesCard], [CustomDocumentTimeline], [CustomDocumentItemCard], [CustomDocumentActionBar].
/// - الحفاظ التام بنسبة 100% على كافة بكسلات التصميم، ألوان الهوية، الحسابات التدقيقية، والحركات الانسيابية.
class ProcurementRequestDetailsScreen
    extends GetView<ProcurementRequestDetailsController> {
  const ProcurementRequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الهيكلي (Skeleton State)
      if (controller.isLoading.value && controller.request.value == null) {
        return CustomAppScaffold(
          appBar: AppBar(
            title: const Text('تفاصيل طلب التوريد'),
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

      final request = controller.request.value;

      // 2. حالة عدم العثور على الطلب
      if (request == null) {
        return CustomAppScaffold(
          appBar: AppBar(
            title: const Text('تفاصيل طلب التوريد'),
            centerTitle: true,
          ),
          body: Center(
            child: CustomEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'الطلب غير موجود',
              subtitle: 'تعذر العثور على بيانات طلب التوريد المحدد أو تم حذفه.',
              actionLabel: 'العودة',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      final displayUuid = request.displayReference;
      final statusPres = EnumPresentationRegistry.resolveRequestStatus(
        request.status,
        serverLabel: request.statusLabel,
      );
      final saleTypePres = EnumPresentationRegistry.resolveSaleType(
        request.saleType,
        serverLabel: request.saleTypeLabel,
      );

      final hasPendingActions = request.isPending;
      final hasInvoiceAction =
          request.isApproved &&
          request.invoiceId != null &&
          request.invoiceId! > 0;

      // 3. عرض صفحة التفاصيل المتكاملة
      return CustomAppScaffold(
        appBarTitle: displayUuid,
        showBackButton: true,
        bottomNavigationBar: (hasPendingActions || hasInvoiceAction)
            ? CustomDocumentActionBar(
                child: Align(
                  alignment: Alignment.center,
                  heightFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ProcurementDetailsActionRow(
                      request: request,
                      controller: controller,
                      isNetwork: controller.isNetworkWorkspace,
                    ),
                  ),
                ),
              )
            : null,
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
                  // 1. الترويسة القيادية بالعمق اللوني المتكيف
                  CustomDocumentDetailsHero(
                    reference: displayUuid,
                    statusPresentation: statusPres,
                    typePresentation: saleTypePres,
                    dateLabel: request.formattedRequestDate,
                    heroTitle: 'طلب توريد كروت شبكة',
                    actorLabel:
                        request.isApproved &&
                            request.reviewedByName != null &&
                            request.reviewedByName!.isNotEmpty
                        ? 'اعتمد بواسطة: ${request.reviewedByName!.trim()}'
                        : (request.isRejected &&
                                  request.reviewedByName != null &&
                                  request.reviewedByName!.isNotEmpty
                              ? 'رُفض بواسطة: ${request.reviewedByName!.trim()}'
                              : (request.isCancelled
                                    ? 'أُلغي بواسطة: ${request.createdByName?.trim() ?? request.posName ?? 'نقطة البيع'}'
                                    : null)),
                    actorIcon: request.isApproved
                        ? Icons.verified_user_outlined
                        : (request.isRejected
                              ? Icons.cancel_outlined
                              : Icons.block_rounded),
                    actorColor: request.isApproved
                        ? colors.emeraldDark
                        : (request.isRejected
                              ? colors.error
                              : colors.onSurfaceVariant),
                    extraBadge:
                        request.modificationSummary?.hasModifications == true
                        ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.published_with_changes_rounded,
                                  size: 10.r,
                                  color: colors.primary,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'معدل بعد المراجعة',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9.5.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                  AppSpacing.vMd,

                  // 2. شريط المؤشرات المالية والتشغيلية
                  CustomDocumentMetricsStrip(
                    metrics: [
                      CustomMetricCardData(
                        label: 'إجمالي الطلب',
                        value: AmountFormatter.formatValue(
                          request.requestTotalAmount,
                        ),
                        unit: 'ر.ي',
                        icon: Icons.account_balance_wallet_rounded,
                        accentColor: colors.primary,
                        isPrimary: true,
                        caption: request.items.isNotEmpty ? 'صافي الطلب' : null,
                      ),
                      CustomMetricCardData(
                        label: 'عدد الكروت',
                        value: '${request.totalVouchers}',
                        unit: 'كرت',
                        icon: Icons.confirmation_number_rounded,
                        accentColor: colors.skyAccent,
                        caption: 'رصيد إجمالي',
                      ),
                      CustomMetricCardData(
                        label: 'إجمالي الأوراق',
                        value: request.formattedTotalSheets,
                        unit: 'ورقة',
                        icon: Icons.layers_rounded,
                        accentColor: colors.purpleAccent,
                        caption: 'أوراق A4',
                      ),
                      CustomMetricCardData(
                        label: 'الباقات المطلوبة',
                        value: '${request.items.length}',
                        unit: 'باقات',
                        icon: Icons.widgets_rounded,
                        accentColor: colors.warning,
                        caption: 'فئات مختلفة',
                      ),
                    ],
                  ),

                  // 3. ملخص المقارنة في حالة وجود تعديلات بعد المراجعة
                  if (request.hasModificationSummary) ...[
                    AppSpacing.vMd,
                    RequestModificationSummaryPanel(
                      summary: request.modificationSummary!,
                    ),
                  ],

                  // 4. بطاقة التنبيه للفاتورة المعتمدة
                  if (request.hasInvoice) ...[
                    AppSpacing.vMd,
                    ProcurementRequestInvoiceCallout(
                      onOpenInvoice: controller.openLinkedInvoice,
                    ),
                  ],
                  AppSpacing.vMd,

                  // 5. مسار التدقيق والتسلسل الزمني لمراحل الطلب
                  CustomDocumentTimeline(
                    title: 'مسار دورة حياة الطلب والتدقيق',
                    nodes: [
                      DocumentTimelineNodeData(
                        title: 'تقديم الطلب واعتماد عرض الأسعار',
                        subtitle:
                            request.createdByName != null &&
                                request.createdByName!.isNotEmpty
                            ? 'مقدم الطلب: ${request.createdByName} (${request.displayPosName})'
                            : request.displayPosName,
                        timestamp: request.formattedRequestDate,
                        icon: Icons.check_circle_rounded,
                        iconColor: colors.success,
                        isCompleted: true,
                        isLast: false,
                      ),
                      DocumentTimelineNodeData(
                        title: 'المراجعة والتدقيق الفني',
                        subtitle: request.isPending
                            ? 'جاري التدقيق من قبل إدارة شبكة ${request.displayNetworkName}'
                            : (request.reviewedByName != null &&
                                      request.reviewedByName!.isNotEmpty
                                  ? 'تم التدقيق بواسطة: ${request.reviewedByName}'
                                  : 'تم استكمال الفحص من إدارة الشبكة'),
                        timestamp:
                            !request.isPending &&
                                request.formattedReviewDate.isNotEmpty
                            ? request.formattedReviewDate
                            : null,
                        icon: request.isPending
                            ? Icons.hourglass_top_rounded
                            : Icons.check_circle_rounded,
                        iconColor: request.isPending
                            ? colors.warning
                            : colors.success,
                        isCompleted: !request.isPending,
                        isLast: false,
                      ),
                      DocumentTimelineNodeData(
                        title: request.timelineDecisionTitle,
                        subtitle: request.timelineDecisionSubtitle,
                        timestamp: request.formattedReviewDate.isNotEmpty
                            ? request.formattedReviewDate
                            : null,
                        icon: statusPres.icon ?? Icons.label_outline_rounded,
                        iconColor: statusPres.tone.color(context),
                        isCompleted: !request.isPending,
                        isLast: true,
                      ),
                    ],
                  ),
                  AppSpacing.vMd,

                  // 6. بطاقة أطراف العملية التوريدية (الشبكة ونقطة البيع)
                  CustomDocumentPartiesCard(
                    title: 'أطراف العملية التوريدية',
                    badgeText: 'طريقة السداد: ${saleTypePres.label}',
                    firstParty: DocumentPartyData(
                      roleLabel: 'الجهة المورّدة (مزود الشبكة)',
                      name:
                          request.networkName != null &&
                              request.networkName!.trim().isNotEmpty
                          ? request.networkName!
                          : 'شبكة #${request.networkId}',
                      phoneNumber: request.networkPhone,
                      logoUrl: request.networkLogo,
                      accentColor: colors.primary,
                    ),
                    flowLabel: 'توريد كروت باقات الإنترنت',
                    secondParty: DocumentPartyData(
                      roleLabel: 'الجهة الطالبة (نقطة البيع)',
                      name:
                          request.posName != null &&
                              request.posName!.trim().isNotEmpty
                          ? request.posName!
                          : 'نقطة بيع #${request.posId}',
                      phoneNumber: request.posPhone,
                      logoUrl: request.posLogo,
                      accentColor: colors.emeraldDeep,
                    ),
                  ),
                  AppSpacing.vLg,

                  // 7. عنوان قسم الباقات المفصلة
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 18.r,
                        color: colors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'تفاصيل الباقات المطلوبة (${request.items.length})',
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vSm,

                  // 8. قائمة بطاقات الباقات
                  for (int i = 0; i < request.items.length; i++) ...[
                    if (i > 0) AppSpacing.vSm,
                    CustomDocumentItemCard(
                      index: i,
                      title: request.items[i].packageName,
                      subtitle: 'سعة الورقة: ${request.items[i].sheetSize} كرت',
                      colorHex: request.items[i].voucherPackage?.packageColor,
                      totalAmountFormatted: AmountFormatter.formatValue(
                        request.items[i].itemTotalAmount,
                      ),
                      totalAmountSubtitle: 'الصافي',
                      specBadges: [
                        if (request.items[i].voucherPackage?.packageBalance !=
                                null &&
                            request.items[i].voucherPackage!.packageBalance > 0)
                          CustomChip(
                            label:
                                request.items[i].voucherPackage!.balanceDisplay,
                            icon: Icons.data_usage_rounded,
                            isCompact: true,
                          ),
                        if (request.items[i].voucherPackage?.packageValidity !=
                            null)
                          CustomChip(
                            label: request
                                .items[i]
                                .voucherPackage!
                                .validityDisplay,
                            icon: Icons.calendar_today_rounded,
                            isCompact: true,
                          ),
                        if (request.items[i].voucherPackage?.packageUptime !=
                            null)
                          CustomChip(
                            label:
                                request.items[i].voucherPackage!.uptimeDisplay,
                            icon: Icons.timer_outlined,
                            isCompact: true,
                          ),
                      ],
                      primaryMetric: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(
                              alpha: 0.30,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.filter_none_rounded,
                                  size: 12.r,
                                  color: colors.primary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'الكمية المطلوبة',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${request.items[i].voucherCount} كرت',
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '(${request.items[i].formattedSheetsCount} ورقة)',
                                    style: AppTypography.caption.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              request.items[i].sheetDescription,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 9.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      secondaryMetric: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(
                              alpha: 0.30,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.sell_outlined,
                                  size: 12.r,
                                  color: request.items[i].hasDiscount
                                      ? (request.items[i].isCustomDiscount
                                            ? colors.success
                                            : colors.skyAccent)
                                      : colors.primary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'سعر الكرت',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AmountFormatter.formatValue(
                                  request.items[i].voucherPrice,
                                ),
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            if (request.items[i].hasDiscount)
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (request.items[i].isCustomDiscount
                                                ? colors.success
                                                : colors.skyAccent)
                                            .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        request.items[i].isCustomDiscount
                                            ? Icons.storefront_rounded
                                            : Icons.auto_awesome_rounded,
                                        size: 10.r,
                                        color: request.items[i].isCustomDiscount
                                            ? colors.success
                                            : colors.skyAccent,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        '${request.items[i].isCustomDiscount ? 'خصم خاص' : 'خصم افتراضي'}: ${AmountFormatter.formatValue(request.items[i].itemDiscount)}',
                                        style: AppTypography.caption.copyWith(
                                          color:
                                              request.items[i].isCustomDiscount
                                              ? colors.success
                                              : colors.skyAccent,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 9.5.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Text(
                                'سعر أساسي بدون خصم',
                                style: AppTypography.caption.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 9.5.sp,
                                ),
                              ),
                          ],
                        ),
                      ),
                      isExpanded: controller.isItemExpanded(i),
                      onToggleExpand: () => controller.toggleItemExpansion(i),
                      auditRows: [
                        DocumentItemAuditRowData(
                          label: 'القيمة الإجمالية الأساسية',
                          formula:
                              '${request.items[i].voucherCount} كرت × ${AmountFormatter.formatValue(request.items[i].voucherPrice)}',
                          amount: AmountFormatter.formatValue(
                            request.items[i].grossAmount,
                          ),
                        ),
                        if (request.items[i].hasDiscount)
                          DocumentItemAuditRowData(
                            label: request.items[i].isCustomDiscount
                                ? 'الخصم الخاص الممنوح (مخصص لنقطتك)'
                                : 'الخصم الافتراضي للباقة (تعاقدي)',
                            amount:
                                '-${AmountFormatter.formatValue(request.items[i].itemDiscount)}',
                            isDiscount: true,
                          ),
                        DocumentItemAuditRowData(
                          label: 'صافي القيمة المستحقة للبند',
                          amount: AmountFormatter.formatValue(
                            request.items[i].itemTotalAmount,
                          ),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ],

                  // 9. بطاقة الملاحظات إن وجدت
                  if (request.hasNote) ...[
                    AppSpacing.vMd,
                    ProcurementDetailsNotesCard(
                      notes: request.requestNote!.trim(),
                    ),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
