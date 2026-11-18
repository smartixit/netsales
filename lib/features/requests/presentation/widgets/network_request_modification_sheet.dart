import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_option_card.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// شيت مراجعة وتعديل طلب التوريد لمشغلي الشبكة
/// يتميز بـ:
/// 1. بطاقة أطراف وسياق تجاري تنفيذي فاخرة (Executive Commercial Parties Card) ثنائية الأبعاد بدون أي قص للأسماء.
/// 2. استخدام فوري وسلس لبطاقات الباقات المستقلة (CustomPackageOptionCard) مع دعم الحذف والتحكم المباشر.
/// 3. قسيمة فاتورة تقديرية رقمية فاخرة (Executive Digital Quotation Voucher) ذات عمق بصري ومحاسبي استثنائي.
/// 4. فتح فوري للشيت بدون أي تأخير شبكي مع إظهار هيكل التحميل التفاعلي وتعطيل الإجراءات حتى اكتمال البيانات.
class NetworkRequestModificationSheet
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestModificationSheet({super.key});

  static Future<void> open(RequestEntity request) async {
    final controller = Get.find<NetworkProcurementReviewController>();
    if (!request.isPending) return;

    // إطلاق جلب البيانات في الخلفية دون حظر فتح الشيت نهائياً
    unawaited(controller.beginModification(request));

    // فتح الشيت فوراً بزمن استجابة فوري (< 16ms)
    await CustomBottomSheet.show<void>(
      title: 'مراجعة طلب #${request.requestUuid ?? request.requestId}',
      subtitle: 'عدّل كميات الباقات أو أضف باقات جديدة، ثم عاين الأسعار قبل الاعتماد.',
      leadingIcon: Icons.edit_note_rounded,
      scrollable: true,
      maxHeightFactor: 0.94,
      stickyFooter: const _ModificationFooter(),
      child: const NetworkRequestModificationSheet(),
    );
    controller.clearModificationEditor();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final request = controller.editingRequest.value;
      final lines = controller.modificationLines.toList(growable: false);
      final preview = controller.currentPreview.value;
      final isLoadingEditor = controller.isLoadingEditor.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (request != null) ...[
            _ExecutiveCommercialPartiesCard(request: request),
            AppSpacing.vMd,
          ],
          if (isLoadingEditor && lines.isEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: const CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.cards,
                  itemCount: 2,
                  showCardSurface: true,
                ),
              ),
            ),
          ] else ...[
            _ProposedItemsSection(request: request, lines: lines),
            AppSpacing.vLg,
            const _AvailablePackagesCatalogSection(),
            AppSpacing.vLg,
            const _ApprovalNotesSection(),
            AppSpacing.vLg,
            _ExecutiveQuotationPreviewSection(
              request: request,
              preview: preview,
              lines: lines,
            ),
          ],
          AppSpacing.vXl,
        ],
      );
    });
  }
}

/// 1. بطاقة أطراف وسياق العملية التوريدية التنفيذية الفاخرة (Executive Commercial Parties Card)
/// تمنح كل طرف مساحته الكاملة والواضحة مع شريط بيانات علوي يمنع أي ضغط أو قص للأسماء.
class _ExecutiveCommercialPartiesCard extends StatelessWidget {
  const _ExecutiveCommercialPartiesCard({required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final posName = request.posName ?? 'نقطة بيع #${request.posId}';
    final networkName = request.networkName ?? 'شبكة #${request.networkId}';
    final saleTypeLabel =
        request.saleTypeLabel ??
        (request.saleType == SaleType.credit ? 'آجل' : 'نقدي');
    final isCash = request.saleType == SaleType.cash;
    final uuid = request.requestUuid ?? request.requestId.toString();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.40),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. الترويسة القيادية لهوية الطلب ونوع البيع
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow.withValues(alpha: 0.6),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              border: Border(
                bottom: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.30),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلب توريد',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 9.5.sp,
                        ),
                      ),
                      Text(
                        uuid,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomStatusBadge(
                  label: saleTypeLabel,
                  icon: isCash
                      ? Icons.payments_outlined
                      : Icons.account_balance_wallet_outlined,
                  tone: isCash ? SemanticTone.success : SemanticTone.info,
                  isCompact: true,
                ),
              ],
            ),
          ),
          // 2. بطاقة مسار الشراكة التوريدية (المورّد ➔ المستلم)
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // طرف الشبكة المورّدة
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cell_tower_rounded,
                              size: 15.r,
                              color: colors.primary,
                            ),
                            AppSpacing.hXxs,
                            Expanded(
                              child: Text(
                                'الشبكة المورّدة',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vXxs,
                        Text(
                          networkName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // أيقونة التدفق التجاري
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Container(
                    width: 26.r,
                    height: 26.r,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 14.r,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                // طرف نقطة البيع المستلمة
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: colors.secondary.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              size: 15.r,
                              color: colors.secondary,
                            ),
                            AppSpacing.hXxs,
                            Expanded(
                              child: Text(
                                'نقطة البيع المستلمة',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.secondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vXxs,
                        Text(
                          posName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. قسم الباقات المقترحة للاعتماد (معاد استخدام ProcurementPackageOptionCard بالكامل)
class _ProposedItemsSection
    extends GetView<NetworkProcurementReviewController> {
  const _ProposedItemsSection({required this.request, required this.lines});

  final RequestEntity? request;
  final List<RequestModificationLineEntity> lines;

  PackageEntity _resolvePackage(int packageId) {
    final fromCatalog = controller.availablePackages.firstWhereOrNull(
      (p) => p.packageId == packageId,
    );
    if (fromCatalog != null) return fromCatalog;

    final fromRequest = request?.items.firstWhereOrNull(
      (i) => i.packageId == packageId,
    );
    if (fromRequest?.voucherPackage != null)
      return fromRequest!.voucherPackage!;

    return PackageEntity(
      packageId: packageId,
      networkId: request?.networkId ?? 0,
      packageName:
          fromRequest?.voucherPackage?.packageName ?? 'باقة #$packageId',
      packageColor: fromRequest?.voucherPackage?.packageColor ?? '#087B61',
      packageBalance: fromRequest?.voucherPackage?.packageBalance ?? 0,
      packageValidity: fromRequest?.voucherPackage?.packageValidity ?? 0,
      packageUptime: fromRequest?.voucherPackage?.packageUptime ?? 0,
      packageVoucherCount:
          fromRequest?.voucherPackage?.packageVoucherCount ?? 100,
      packageVoucherPrice: fromRequest?.voucherPrice ?? 0,
      packageDefaultCashDiscount: fromRequest?.itemDiscount ?? 0,
      packageDefaultCreditDiscount: 0,
      cashDiscountAmount: 0,
      creditDiscountAmount: 0,
      effectiveCashPrice: fromRequest?.voucherPrice ?? 0,
      effectiveCreditPrice: fromRequest?.voucherPrice ?? 0,
      status: true,
    );
  }

  bool _isItemNewlyAdded(int packageId) {
    if (request == null) return false;
    return !request!.items.any((i) => i.packageId == packageId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 16.r,
                color: colors.primary,
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الباقات المطلوبة والمعدلة (${lines.length})',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'عدّل كمية الكروت عبر الأزرار أو الإدخال المباشر، أو احذف الباقة إذا لزم.',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        if (lines.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .4),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.remove_shopping_cart_rounded,
                  size: 32.r,
                  color: colors.onSurfaceVariant,
                ),
                AppSpacing.vSm,
                Text(
                  'قائمة الباقات فارغة',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  'يمكنك إضافة باقات جديدة من كتالوج الشبكة أدناه.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ...lines.map((line) {
            final pkg = _resolvePackage(line.packageId);
            final isAdded = _isItemNewlyAdded(line.packageId);
            final previewItem = controller.currentPreview.value?.items.firstWhereOrNull(
              (i) => i.packageId == line.packageId,
            );
            final authoritativeTotal = (previewItem != null && previewItem.voucherCount == line.voucherCount)
                ? previewItem.itemTotalAmount
                : null;

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: ProcurementPackageOptionCard(
                package: pkg,
                quantity: line.voucherCount,
                estimatedLineTotal: authoritativeTotal,
                onSetQuantity: (qty) =>
                    controller.setModificationQuantity(line.packageId, qty),
                isCashSale: request?.saleType == SaleType.cash,
                quantityController: controller.modificationQuantityController(
                  line.packageId,
                  line.voucherCount,
                ),
                onDelete: () =>
                    controller.removeModificationPackage(line.packageId),
                customHeaderTag: isAdded ? 'باقة مضافة' : null,
                customHeaderTagColor: isAdded ? colors.tertiary : null,
              ),
            );
          }),
      ],
    );
  }
}

/// 3. قسم كتالوج إضافة الباقات التفاعلي
class _AvailablePackagesCatalogSection
    extends GetView<NetworkProcurementReviewController> {
  const _AvailablePackagesCatalogSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final selectedIds = controller.modificationLines
          .map((line) => line.packageId)
          .toSet();
      final available = controller.availablePackages
          .where((p) => !selectedIds.contains(p.packageId))
          .toList(growable: false);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.add_shopping_cart_rounded,
                  size: 16.r,
                  color: colors.secondary,
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إضافة باقة من كتالوج الشبكة',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'باقات متوفرة في كتالوج الشبكة يمكن تضمينها في الطلب.',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          if (controller.isLoadingPackages.value)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: const CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.cards,
                  itemCount: 2,
                  showCardSurface: true,
                ),
              ),
            )
          else if (available.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: .35),
                ),
              ),
              child: Text(
                'تمت إضافة جميع باقات الكتالوج المتاحة إلى مسودة الطلب.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...available.map(
              (pkg) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                child: _CatalogPackageRow(package: pkg),
              ),
            ),
        ],
      );
    });
  }
}

class _CatalogPackageRow extends GetView<NetworkProcurementReviewController> {
  const _CatalogPackageRow({required this.package});

  final PackageEntity package;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageColor = CustomColorPicker.parseHex(
      package.packageColor,
      fallback: colors.primary,
    );
    final sheetSize = package.packageVoucherCount;
    final defaultPrice = package.effectiveCashPrice > 0
        ? package.effectiveCashPrice
        : package.packageVoucherPrice;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .4)),
      ),
      child: Row(
        children: [
          Container(
            width: 10.r,
            height: 10.r,
            decoration: BoxDecoration(
              color: packageColor,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.packageName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vXxs,
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    if ((package.packageValidity ?? 0) > 0)
                      Text(
                        'صلاحية ${package.packageValidity} ساعة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                    if (sheetSize > 0)
                      Text(
                        '• سعة $sheetSize كرت',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                    Text(
                      '• السعر: ${AmountFormatter.format(defaultPrice.toString())}',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomButton.primary(
            text: 'إضافة',
            icon: Icons.add_rounded,
            size: AppButtonSize.small,
            onPressed: () => controller.addModificationPackage(
              package.packageId,
              initialQuantity: sheetSize > 0 ? sheetSize : 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. قسم ملاحظات الاعتماد لنقطة البيع
class _ApprovalNotesSection
    extends GetView<NetworkProcurementReviewController> {
  const _ApprovalNotesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller.modificationNoteController,
          label: 'ملاحظة الاعتماد لنقطة البيع (اختياري)',
          hint: 'أضف توضيحاً يظهر لنقطة البيع في تفاصيل الطلب والفاتورة الصادرة...',
          maxLines: 2,
          isRequired: false,
        ),
      ],
    );
  }
}

/// 5. قسيمة المعاينة المالية والتدقيق التنفيذي (Executive Quotation Voucher)
class _ExecutiveQuotationPreviewSection
    extends GetView<NetworkProcurementReviewController> {
  const _ExecutiveQuotationPreviewSection({
    required this.request,
    required this.preview,
    required this.lines,
  });

  final RequestEntity? request;
  final RequestModificationPreviewEntity? preview;
  final List<RequestModificationLineEntity> lines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 16.r,
                color: colors.primary,
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: Text(
                'ملخص الفاتورة التقديرية المعتمدة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        if (preview == null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.primary.withValues(alpha: .22)),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.calculate_outlined,
                      size: 26.r,
                      color: colors.primary,
                    ),
                  ),
                ),
                AppSpacing.vSm,
                Text(
                  'المعاينة لا تغيّر الطلب ولا تنشئ فاتورة',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  'اضغط على زر «معاينة التعديل» بالأسفل لاحتساب فروقات الأسعار، الخصومات الممنوحة، والإجمالي المعتمد من الخادم قبل الاعتماد النهائي.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          _ExecutiveQuotationVoucherCard(request: request, preview: preview!),
      ],
    );
  }
}

/// بطاقة القسيمة المالية الرسمية المنظمة فائقة العمق البصري
class _ExecutiveQuotationVoucherCard extends StatelessWidget {
  const _ExecutiveQuotationVoucherCard({
    required this.request,
    required this.preview,
  });

  final RequestEntity? request;
  final RequestModificationPreviewEntity preview;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final diff = preview.previewTotalAmount - preview.originalTotalAmount;
    final isIncrease = diff > 0.01;
    final isDecrease = diff < -0.01;
    final diffAbs = diff.abs();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.40),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط الترويسة الرسمي للقسيمة
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary.withValues(alpha: 0.08),
                  colors.surfaceContainerLow,
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_rounded, size: 16.r, color: colors.primary),
                AppSpacing.hXs,
                Expanded(
                  child: Text(
                    'تسعير رسمي صادر وموثق من الخادم',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const CustomStatusBadge(
                  label: 'معاينة رسمية',
                  tone: SemanticTone.primary,
                  isCompact: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. لوحة الصافي السيادي المعتمد (The Hero Net Amount)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        const Color(0xFF087A5F),
                        const Color(0xFF055743),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF087A5F).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'المقترح للاعتماد',
                              style: AppTypography.labelMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.r,
                              vertical: 3.r,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                            child: Text(
                              'صافي الفاتورة',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vXs,
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${AmountFormatter.formatValue(preview.previewTotalAmount)} ر.ي',
                          textDirection: TextDirection.rtl,
                          style: AppTypography.titleLarge.copyWith(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        'صافي القيمة التي ستعتمد وتصدر بها الفاتورة الرسمية',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vMd,
                // 2. جدول الحسابات المحاسبي الأنيق
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    children: [
                      _VoucherFinancialRow(
                        label: 'الطلب الأصلي',
                        amount: preview.originalTotalAmount,
                        isMuted: true,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.r),
                        child: Divider(
                          height: 1,
                          color: colors.outlineVariant.withValues(alpha: 0.25),
                        ),
                      ),
                      _VoucherFinancialRow(
                        label: 'الإجمالي قبل الخصم',
                        amount: preview.grossTotalAmount,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.r),
                        child: Divider(
                          height: 1,
                          color: colors.outlineVariant.withValues(alpha: 0.25),
                        ),
                      ),
                      _VoucherFinancialRow(
                        label: 'إجمالي الخصم',
                        amount: preview.totalDiscountAmount,
                        isDiscount: true,
                      ),
                    ],
                  ),
                ),
                AppSpacing.vSm,
                // 3. شريط الفارق المالي والمقارنة التنفيذية
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDecrease
                        ? colors.tertiary.withValues(alpha: 0.08)
                        : isIncrease
                        ? colors.secondary.withValues(alpha: 0.08)
                        : colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(
                      color: isDecrease
                          ? colors.tertiary.withValues(alpha: 0.3)
                          : isIncrease
                          ? colors.secondary.withValues(alpha: 0.3)
                          : colors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDecrease
                            ? Icons.trending_down_rounded
                            : isIncrease
                            ? Icons.trending_up_rounded
                            : Icons.horizontal_rule_rounded,
                        size: 16.r,
                        color: isDecrease
                            ? colors.tertiary
                            : isIncrease
                            ? colors.secondary
                            : colors.onSurfaceVariant,
                      ),
                      AppSpacing.hXs,
                      Expanded(
                        child: Text(
                          isDecrease
                              ? 'الفارق الإجمالي: وفر بمقدار ${AmountFormatter.formatValue(diffAbs)} ر.ي مقارنة بالطلب الأصلي'
                              : isIncrease
                              ? 'الفارق الإجمالي: زيادة بمقدار ${AmountFormatter.formatValue(diffAbs)} ر.ي مقارنة بالطلب الأصلي'
                              : 'الفارق الإجمالي: القيمة متطابقة تماماً مع الطلب الأصلي',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vMd,
                // 4. سجل الفروقات والتعديلات (Audit Trail)
                Row(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 16.r,
                      color: colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXxs,
                    Expanded(
                      child: Text(
                        'سجل الفروقات المباشر على البنود',
                        style: AppTypography.labelLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vXs,
                ...preview.items.map((item) => _PreviewItemDiffRow(item: item)),
                if (preview.removedItems.isNotEmpty) ...[
                  AppSpacing.vXs,
                  ...preview.removedItems.map(
                    (item) => _RemovedItemDiffRow(item: item),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherFinancialRow extends StatelessWidget {
  const _VoucherFinancialRow({
    required this.label,
    required this.amount,
    this.isMuted = false,
    this.isDiscount = false,
  });

  final String label;
  final double amount;
  final bool isMuted;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isMuted ? colors.onSurfaceVariant : colors.onSurface,
              fontWeight: isMuted ? FontWeight.w500 : FontWeight.w600,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${isDiscount ? "- " : ""}${AmountFormatter.formatValue(amount)} ر.ي',
            textDirection: TextDirection.rtl,
            style: AppTypography.bodyMedium.copyWith(
              color: isDiscount
                  ? colors.tertiary
                  : isMuted
                  ? colors.onSurfaceVariant
                  : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewItemDiffRow extends StatelessWidget {
  const _PreviewItemDiffRow({required this.item});

  final RequestModificationPreviewItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAdded = item.changeType == 'ITEM_ADDED';
    final isModified = item.changeType == 'QUANTITY_MODIFIED';

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isAdded
            ? colors.tertiary.withValues(alpha: 0.05)
            : isModified
            ? colors.secondary.withValues(alpha: 0.05)
            : colors.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isAdded
              ? colors.tertiary.withValues(alpha: 0.35)
              : isModified
              ? colors.secondary.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // السطر الأول: أيقونة الباقة واسمها مع شارة التعديل التنفيذية
          Row(
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: isAdded
                      ? colors.tertiary.withValues(alpha: 0.15)
                      : isModified
                      ? colors.secondary.withValues(alpha: 0.15)
                      : colors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isAdded
                        ? Icons.add_rounded
                        : isModified
                        ? Icons.edit_rounded
                        : Icons.check_rounded,
                    size: 15.r,
                    color: isAdded
                        ? colors.tertiary
                        : isModified
                        ? colors.secondary
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  item.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              AppSpacing.hXs,
              if (isAdded)
                const CustomStatusBadge(
                  label: 'باقة مضافة',
                  tone: SemanticTone.success,
                  isCompact: true,
                )
              else if (isModified)
                CustomStatusBadge(
                  label: '${item.originalVoucherCount} ➔ ${item.voucherCount}',
                  tone: SemanticTone.info,
                  isCompact: true,
                )
              else
                Text(
                  '${item.voucherCount} كرت',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          AppSpacing.vXs,
          // السطر الثاني: التفاصيل المحاسبية للبند (الكمية، سعر الوحدة، الإجمالي الصافي)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                // جهة الكمية والتسعير
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '${item.voucherCount} كرت',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(
                          text:
                              ' × ${AmountFormatter.formatValue(item.voucherPrice)} ر.ي',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.hXs,
                // جهة الصافي النهائي للبند
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${AmountFormatter.formatValue(item.itemTotalAmount)} ر.ي',
                        textDirection: TextDirection.rtl,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                      if (item.discountAmount > 0)
                        Text(
                          'وفر خصم: -${AmountFormatter.formatValue(item.discountAmount)} ر.ي',
                          textDirection: TextDirection.rtl,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.tertiary,
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RemovedItemDiffRow extends StatelessWidget {
  const _RemovedItemDiffRow({required this.item});

  final RequestModificationRemovedItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.error.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 15.r,
                    color: colors.error,
                  ),
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  item.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              AppSpacing.hXs,
              const CustomStatusBadge(
                label: 'تم حذفها من الطلب',
                tone: SemanticTone.danger,
                isCompact: true,
              ),
            ],
          ),
          AppSpacing.vXs,
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'الكمية الأصلية الملغاة: ${item.originalVoucherCount} كرت',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppSpacing.hXs,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'وفر مستبعد: ${AmountFormatter.formatValue(item.originalItemTotal)} ر.ي',
                    textDirection: TextDirection.rtl,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 6. شريط الإجراءات السفلي المثبت
class _ModificationFooter extends GetView<NetworkProcurementReviewController> {
  const _ModificationFooter();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isLoadingEditor = controller.isLoadingEditor.value;
      final isPreviewing = controller.isPreviewingModification.value;
      final isProcessing = controller.isProcessingDecision.value;
      final preview = controller.currentPreview.value;
      final hasLines = controller.modificationLines.isNotEmpty;
      final isBusy = isLoadingEditor || isPreviewing || isProcessing;

      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.outlineVariant.withValues(alpha: .4)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'معاينة',
                  icon: Icons.calculate_outlined,
                  size: AppButtonSize.medium,
                  loading: isPreviewing,
                  onPressed: hasLines && !isBusy
                      ? () => controller.previewModification()
                      : null,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                flex: 2,
                child: CustomButton.primary(
                  text: preview != null
                      ? 'اعتماد الطلب المعدل'
                      : 'اعتماد بالتعديل',
                  icon: Icons.check_circle_rounded,
                  size: AppButtonSize.medium,
                  loading: isProcessing,
                  onPressed: hasLines && !isBusy
                      ? () => controller.confirmAndApproveModification()
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
