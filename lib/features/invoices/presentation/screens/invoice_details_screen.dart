import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/presentation/controllers/invoice_details_controller.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_metric_card_data.dart';
import 'package:netsales/widgets/document_details/custom_document_action_bar.dart';
import 'package:netsales/widgets/document_details/custom_document_details_hero.dart';
import 'package:netsales/widgets/document_details/custom_document_metrics_strip.dart';
import 'package:netsales/widgets/document_details/custom_document_parties_card.dart';
import 'package:netsales/widgets/document_details/document_package_item_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة تفاصيل فاتورة المبيعات والمشتريات بالمعايير العالمية والعمق البصري الفاخر (InvoiceDetailsScreen)
///
/// تجسد المعمارية المؤسسية النظيفة لشاشات التفاصيل المستندية:
/// - استهلاك مباشر وموحد للمكونات القيادية العامة [CustomDocumentDetailsHero],
///   [CustomDocumentMetricsStrip], [CustomDocumentPartiesCard], [CustomDocumentItemCard], [CustomDocumentActionBar].
/// - مطابقة تامة 100% لتنظيم وترتيب وتجربة شاشة تفاصيل طلب التوريد [ProcurementRequestDetailsScreen].
class InvoiceDetailsScreen extends GetView<InvoiceDetailsController> {
  const InvoiceDetailsScreen({super.key, this.isNetworkPerspective = true});

  final bool isNetworkPerspective;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الهيكلي (Skeleton State)
      if (controller.isLoading.value && controller.invoice.value == null) {
        return CustomAppScaffold(
          appBar: AppBar(
            title: const Text('تفاصيل الفاتورة'),
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

      final invoice = controller.invoice.value;

      // 2. حالة عدم العثور على الفاتورة
      if (invoice == null) {
        return CustomAppScaffold(
          appBar: AppBar(
            title: const Text('تفاصيل الفاتورة'),
            centerTitle: true,
          ),
          body: Center(
            child: CustomEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'الفاتورة غير موجودة',
              subtitle: 'تعذر العثور على بيانات الفاتورة المحددة أو تم حذفها.',
              actionLabel: 'العودة',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      final displayReference = invoice.displayReference;
      final statusPres = EnumPresentationRegistry.resolveInvoicePaymentStatus(
        invoice.paymentStatus,
        serverLabel: invoice.paymentStatusLabel,
      );
      final saleTypePres = EnumPresentationRegistry.resolveSaleType(
        invoice.saleType,
        serverLabel: invoice.saleTypeLabel,
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
                      text: 'طباعة الفاتورة',
                      icon: Icons.print_rounded,
                      size: AppButtonSize.medium,
                      shape: AppButtonShape.pill,
                      loading: controller.isPrinting.value,
                      onPressed: controller.printCurrentInvoice,
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
                      onPressed: controller.shareCurrentInvoice,
                    ),
                  ),
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
                    typePresentation: saleTypePres,
                    dateLabel: invoice.formattedInvoiceDate,
                    heroTitle: isNetworkPerspective
                        ? 'فاتورة مبيعات كروت معتمدة'
                        : 'فاتورة مشتريات كروت معتمدة',
                    actorLabel:
                        invoice.createdByName != null &&
                            invoice.createdByName!.trim().isNotEmpty
                        ? 'أُصدرت بواسطة: ${invoice.createdByName!.trim()}'
                        : null,
                    actorIcon: Icons.verified_user_outlined,
                    actorColor: colors.emeraldDark,
                    extraBadge: invoice.hasLinkedRequest
                        ? CustomChip(
                            label: 'طلب #${invoice.requestId}',
                            icon: Icons.link_rounded,
                            isCompact: true,
                          )
                        : null,
                  ),
                  AppSpacing.vMd,

                  // 2. شريط المؤشرات المالية والتشغيلية الموحد (CustomDocumentMetricsStrip)
                  CustomDocumentMetricsStrip(
                    metrics: [
                      CustomMetricCardData(
                        label: 'إجمالي الفاتورة',
                        value: AmountFormatter.formatValue(
                          invoice.invoiceTotalAmount,
                        ),
                        unit: 'ر.ي',
                        icon: Icons.account_balance_wallet_rounded,
                        accentColor: colors.primary,
                        isPrimary: true,
                        caption: 'القيمة الإجمالية',
                      ),
                      CustomMetricCardData(
                        label: 'المبلغ المدفوع',
                        value: AmountFormatter.formatValue(invoice.paidAmount),
                        unit: 'ر.ي',
                        icon: Icons.payments_rounded,
                        accentColor: colors.emeraldDeep,
                        caption: 'سداد مقبوض',
                      ),
                      CustomMetricCardData(
                        label: 'المبلغ المتبقي',
                        value: AmountFormatter.formatValue(
                          invoice.remainingAmount,
                        ),
                        unit: 'ر.ي',
                        icon: Icons.pending_actions_rounded,
                        accentColor: invoice.remainingAmount > 0
                            ? colors.error
                            : colors.onSurfaceVariant,
                        caption: invoice.remainingAmount > 0
                            ? 'مستحق السداد'
                            : 'مسدد بالكامل',
                      ),
                      CustomMetricCardData(
                        label: 'عدد الكروت',
                        value: '${invoice.totalVouchers}',
                        unit: 'كرت',
                        icon: Icons.confirmation_number_rounded,
                        accentColor: colors.skyAccent,
                        caption: 'إجمالي الرصيد',
                      ),
                    ],
                  ),
                  AppSpacing.vMd,

                  // 3. بطاقة أطراف المعاملة المالية الرسمية (CustomDocumentPartiesCard)
                  CustomDocumentPartiesCard(
                    title: 'أطراف المعاملة المالية',
                    badgeText: 'طريقة السداد: ${saleTypePres.label}',
                    firstParty: DocumentPartyData(
                      roleLabel: 'الجهة المورّدة (مزود الشبكة)',
                      name: invoice.displayNetworkName,
                      phoneNumber: invoice.networkPhoneNumber,
                      logoUrl: invoice.networkLogo,
                      accentColor: colors.primary,
                    ),
                    flowLabel: 'توريد ومبيعات كروت الإنترنت',
                    secondParty: DocumentPartyData(
                      roleLabel: 'الجهة المستفيدة (نقطة البيع)',
                      name: invoice.displayPosName,
                      phoneNumber: invoice.posPhoneNumber,
                      logoUrl: invoice.posLogo,
                      accentColor: colors.emeraldDeep,
                    ),
                  ),
                  AppSpacing.vLg,

                  // 4. عنوان قسم الباقات المعتمدة
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
                          'تفاصيل الباقات المفوترة (${invoice.items.length})',
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${invoice.totalVouchers} كرت (${invoice.formattedTotalSheets} ورقة)',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vSm,

                  // 5. قائمة بطاقات الباقات المعتمدة الموحدة (DocumentPackageItemCard)
                  for (int i = 0; i < invoice.items.length; i++) ...[
                    if (i > 0) AppSpacing.vSm,
                    Obx(
                      () => DocumentPackageItemCard(
                        index: i,
                        title: invoice.items[i].packageName,
                        colorHex: invoice.items[i].packageColor,
                        totalAmount: invoice.items[i].itemTotalAmount,
                        voucherCount: invoice.items[i].voucherCount,
                        formattedSheetsCount:
                            invoice.items[i].formattedSheetsCount,
                        sheetDescription: invoice.items[i].sheetDescription,
                        sheetSize: invoice.items[i].sheetSize,
                        voucherPrice: invoice.items[i].voucherPrice,
                        hasDiscount: invoice.items[i].hasDiscount,
                        itemDiscount: invoice.items[i].itemDiscount,
                        balanceDisplay:
                            invoice.items[i].voucherPackage?.balanceDisplay,
                        validityDisplay:
                            invoice.items[i].voucherPackage?.validityDisplay,
                        uptimeDisplay:
                            invoice.items[i].voucherPackage?.uptimeDisplay,
                        quantityLabel: 'الكمية المفوترة',
                        isExpanded: controller.isItemExpanded(i),
                        onToggleExpand: () => controller.toggleItemExpansion(i),
                      ),
                    ),
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
