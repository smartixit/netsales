import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_item_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_removed_item_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_option_card.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// شيت مراجعة وتعديل طلب التوريد لمشغلي الشبكة
class NetworkRequestModificationSheet
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestModificationSheet({super.key});

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
            _NetworkRequestCommercialPartiesCard(request: request),
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
            _NetworkRequestProposedItemsSection(request: request, lines: lines),
            AppSpacing.vLg,
            const _NetworkRequestCatalogSection(),
            AppSpacing.vLg,
            const _NetworkRequestApprovalNotesSection(),
            AppSpacing.vLg,
            _NetworkRequestQuotationPreviewSection(
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

/// شريط الإجراءات السفلي المثبت في شيت تعديل طلب التوريد
class NetworkRequestModificationFooter
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestModificationFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isLoadingEditor = controller.isLoadingEditor.value;
      final isPreviewing = controller.isPreviewingModification.value;
      final isProcessing = controller.isProcessingDecision.value;
      final preview = controller.currentPreview.value;
      final hasLines = controller.modificationLines.isNotEmpty;
      final hasChanges = controller.hasModificationChanges;
      final isBusy = isLoadingEditor || isPreviewing || isProcessing;
      final canSubmit = hasLines && hasChanges && !isBusy;

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
                  onPressed: canSubmit
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
                  onPressed: canSubmit
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

// ─────────────────────────────────────────────────────────────────────────────
// Private Sub-Widgets for NetworkRequestModificationSheet
// ─────────────────────────────────────────────────────────────────────────────

class _NetworkRequestCommercialPartiesCard extends StatelessWidget {
  const _NetworkRequestCommercialPartiesCard({required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final posName = request.displayPosName;
    final networkName = request.displayNetworkName;
    final saleTypePres = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );
    final uuid = request.displayReference;

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
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.primary.withValues(alpha: 0.82),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
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
                        'طلب توريد كروت',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              uuid,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          AppSpacing.hXxs,
                          CustomInteractiveBounce(
                            onTap: () {
                              UrlLauncherService.copyToClipboard(
                                uuid,
                                confirmationMessage: 'تم نسخ رقم الطلب',
                              );
                              CustomSnackbar.show(
                                title: 'تم النسخ',
                                message: 'تم نسخ $uuid للحافظة',
                                type: SnackType.info,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(3.r),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 13.r,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomStatusBadge(
                  label: saleTypePres.label,
                  icon: saleTypePres.icon,
                  tone: saleTypePres.tone,
                  isCompact: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomAvatarBadge(
                      imageUrl: request.networkLogo,
                      initials: TextFormatter.avatarInitial(networkName),
                      size: AvatarBadgeSize.sm,
                      customDimension: 36.r,
                      borderRadius: BorderRadius.circular(9.r),
                      gradientColors: [colors.skyAccent, colors.primary],
                      hasPulse: false,
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الشبكة المورّدة',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            networkName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: 17.r, top: 4.r, bottom: 4.r),
                  child: Row(
                    children: [
                      Container(
                        width: 2.r,
                        height: 18.r,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                      AppSpacing.hSm,
                      Icon(
                        Icons.south_rounded,
                        size: 13.r,
                        color: colors.primary.withValues(alpha: 0.7),
                      ),
                      AppSpacing.hXxs,
                      Text(
                        'توريد واعتماد كميات الكروت',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 9.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    CustomAvatarBadge(
                      imageUrl: request.posLogo,
                      initials: TextFormatter.avatarInitial(posName),
                      size: AvatarBadgeSize.sm,
                      customDimension: 36.r,
                      borderRadius: BorderRadius.circular(9.r),
                      gradientColors: [colors.emeraldDark, colors.emeraldDeep],
                      hasPulse: false,
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نقطة البيع المستلمة',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.secondary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            posName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkRequestProposedItemsSection
    extends GetView<NetworkProcurementReviewController> {
  const _NetworkRequestProposedItemsSection({
    required this.request,
    required this.lines,
  });

  final RequestEntity? request;
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
            final pkg = controller.resolvePackageForModification(
              line.packageId,
            );
            // final isAdded = controller.isItemNewlyAdded(line.packageId);
            final authoritativeTotal = controller
                .authoritativeTotalForModificationLine(line);

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
              //   customHeaderTag: isAdded ? 'باقة مضافة' : null,
              //   customHeaderTagColor: isAdded ? colors.tertiary : null,
              ),
            );
          }),
      ],
    );
  }
}

class _NetworkRequestCatalogSection
    extends GetView<NetworkProcurementReviewController> {
  const _NetworkRequestCatalogSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final available = controller.unselectedAvailablePackages;

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
                child: _NetworkRequestCatalogPackageRow(package: pkg),
              ),
            ),
        ],
      );
    });
  }
}

class _NetworkRequestCatalogPackageRow
    extends GetView<NetworkProcurementReviewController> {
  const _NetworkRequestCatalogPackageRow({required this.package});

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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: packageColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  package.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                AppSpacing.vXxs,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$sheetSize كرت/ورقة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${AmountFormatter.formatValue(defaultPrice)} ر.ي',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hSm,
          CustomButton.outline(
            text: 'إضافة',
            icon: Icons.add_rounded,
            size: AppButtonSize.small,
            onPressed: () =>
                controller.addModificationPackage(package.packageId),
          ),
        ],
      ),
    );
  }
}

class _NetworkRequestApprovalNotesSection
    extends GetView<NetworkProcurementReviewController> {
  const _NetworkRequestApprovalNotesSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCredit =
          controller.editingRequest.value?.saleType == SaleType.credit;
      final maxAmount =
          controller.currentPreview.value?.previewTotalAmount ??
          controller.editingRequest.value?.requestTotalAmount;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCredit) ...[
            CustomTextField(
              controller: controller.modificationPaidAmountController,
              label: 'الدفعة النقدية المقبوضة كاش (اختياري)',
              hint: 'أدخل المبلغ المسلَّم نقداً يداً بيد (0 إن لم يُدفع شيء)',
              isRequired: false,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefixIcon: const Icon(Icons.payments_outlined),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: FormValidators.amountValidator(
                fieldName: 'المبلغ المقبوض كاش',
                isRequired: false,
                minValue: 0,
                maxValue: maxAmount,
              ),
            ),
            AppSpacing.vSm,
          ],
          CustomTextField(
            controller: controller.modificationNoteController,
            label: 'ملاحظة الاعتماد لنقطة البيع (اختياري)',
            hint: 'أضف توضيحاً يظهر لنقطة البيع في تفاصيل الطلب والفاتورة الصادرة...',
            maxLines: 2,
            isRequired: false,
            validator: FormValidators.descriptionValidator(isRequired: false),
          ),
        ],
      );
    });
  }
}

class _NetworkRequestQuotationPreviewSection
    extends GetView<NetworkProcurementReviewController> {
  const _NetworkRequestQuotationPreviewSection({
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
        if (controller.isPreviewingModification.value)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: const CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.detail,
                itemCount: 1,
                showCardSurface: true,
              ),
            ),
          )
        else if (preview == null)
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
          _NetworkRequestQuotationVoucherCard(
            request: request,
            preview: preview!,
          ),
      ],
    );
  }
}

class _NetworkRequestQuotationVoucherCard extends StatelessWidget {
  const _NetworkRequestQuotationVoucherCard({
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
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [colors.emeraldDark, colors.emeraldDeep],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: colors.emeraldDark.withValues(alpha: 0.25),
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
                      _NetworkRequestVoucherFinancialRow(
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
                      _NetworkRequestVoucherFinancialRow(
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
                      _NetworkRequestVoucherFinancialRow(
                        label: 'إجمالي الخصم',
                        amount: preview.totalDiscountAmount,
                        isDiscount: true,
                      ),
                    ],
                  ),
                ),
                AppSpacing.vSm,
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
                _NetworkRequestDiffAuditSection(
                  items: preview.items,
                  removedItems: preview.removedItems,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkRequestDiffAuditSection extends StatelessWidget {
  const _NetworkRequestDiffAuditSection({
    required this.items,
    required this.removedItems,
  });

  final List<RequestModificationPreviewItemEntity> items;
  final List<RequestModificationRemovedItemEntity> removedItems;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        ...items.map((item) => _NetworkRequestPreviewItemDiffCard(item: item)),
        if (removedItems.isNotEmpty) ...[
          AppSpacing.vXs,
          ...removedItems.map(
            (item) => _NetworkRequestRemovedItemDiffCard(item: item),
          ),
        ],
      ],
    );
  }
}

class _NetworkRequestPreviewItemDiffCard extends StatelessWidget {
  const _NetworkRequestPreviewItemDiffCard({required this.item});

  final RequestModificationPreviewItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAdded = item.isAdded;
    final isModified = item.isModified;

    final Color accentColor = isAdded
        ? colors.tertiary
        : isModified
        ? colors.secondary
        : colors.outlineVariant;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isAdded
            ? colors.tertiary.withValues(alpha: 0.04)
            : isModified
            ? colors.secondary.withValues(alpha: 0.04)
            : colors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accentColor.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: isAdded
                      ? colors.tertiary.withValues(alpha: 0.12)
                      : isModified
                      ? colors.secondary.withValues(alpha: 0.12)
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
                    size: 14.r,
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
                  style: AppTypography.labelLarge.copyWith(
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
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6.r,
            ),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
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
                          'وفر: -${AmountFormatter.formatValue(item.discountAmount)} ر.ي',
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

class _NetworkRequestRemovedItemDiffCard extends StatelessWidget {
  const _NetworkRequestRemovedItemDiffCard({required this.item});

  final RequestModificationRemovedItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.error.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 14.r,
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
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              AppSpacing.hXs,
              const CustomStatusBadge(
                label: 'تم استبعادها',
                tone: SemanticTone.danger,
                isCompact: true,
              ),
            ],
          ),
          AppSpacing.vXs,
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6.r,
            ),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'الكمية المستبعدة: ${item.originalVoucherCount} كرت',
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

class _NetworkRequestVoucherFinancialRow extends StatelessWidget {
  const _NetworkRequestVoucherFinancialRow({
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
