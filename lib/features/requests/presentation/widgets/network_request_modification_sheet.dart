import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// شيت مراجعة وتعديل طلب التوريد لمشغلي الشبكة بعمق بصري وتجربة تفاعلية متكاملة
class NetworkRequestModificationSheet
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestModificationSheet({super.key});

  static Future<void> open(RequestEntity request) async {
    final controller = Get.find<NetworkProcurementReviewController>();
    if (!request.isPending) return;
    await controller.beginModification(request);
    if (controller.editingRequestId.value != request.requestId) return;
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (request != null) ...[
            _SheetHeroOverviewCard(request: request),
            AppSpacing.vLg,
          ],
          _ProposedItemsSection(lines: lines),
          AppSpacing.vLg,
          const _AvailablePackagesCatalogSection(),
          AppSpacing.vLg,
          const _ApprovalNotesSection(),
          AppSpacing.vLg,
          _FinancialPreviewSection(preview: preview),
          AppSpacing.vXl,
        ],
      );
    });
  }
}

/// بطاقة البانر الترحيبي الغنية بالعمق البصري في أعلى الشيت
class _SheetHeroOverviewCard extends StatelessWidget {
  const _SheetHeroOverviewCard({required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final posName = request.posName ?? 'نقطة بيع #${request.posId}';
    final networkName = request.networkName ?? 'شبكة #${request.networkId}';
    final saleTypeLabel =
        request.saleTypeLabel ??
        (request.saleType == SaleType.credit ? 'آجل' : 'نقدي');
    final uuid = request.requestUuid ?? request.requestId.toString();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF087F68), Color(0xFF075B55), Color(0xFF123F49)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: const Color(0xFFFFD98A).withValues(alpha: .32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF087F68).withValues(alpha: .22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -16,
            top: -24,
            child: Container(
              width: 96.r,
              height: 96.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: const Color(0xFFFFE7B0).withValues(alpha: .30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 13.r,
                            color: const Color(0xFFFFE7B0),
                          ),
                          AppSpacing.hXxs,
                          Text(
                            uuid.length > 14
                                ? '${uuid.substring(0, 14)}...'
                                : uuid,
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFFFFE7B0),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hXs,
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: uuid));
                        CustomSnackbar.show(
                          title: 'تم النسخ',
                          message: 'تم نسخ الرقم المرجعي للطلب',
                          type: SnackType.info,
                        );
                      },
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xxs),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 14.r,
                          color: Colors.white.withValues(alpha: .75),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE7B0).withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: const Color(0xFFFFE7B0).withValues(alpha: .40),
                        ),
                      ),
                      child: Text(
                        saleTypeLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: const Color(0xFFFFE7B0),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vSm,
                Row(
                  children: [
                    Expanded(
                      child: _CommercialPartyMiniCard(
                        roleLabel: 'نقطة البيع المستلمة',
                        name: posName,
                        logoUrl: request.posLogo,
                        icon: Icons.storefront_rounded,
                        initial: TextFormatter.avatarInitial(
                          posName,
                          fallback: 'ن',
                        ),
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: _CommercialPartyMiniCard(
                        roleLabel: 'الشبكة المورّدة',
                        name: networkName,
                        logoUrl: request.networkLogo,
                        icon: Icons.cell_tower_rounded,
                        initial: TextFormatter.avatarInitial(
                          networkName,
                          fallback: 'ش',
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vSm,
                Text(
                  'راجع كميات الباقات، أو أضف باقات إضافية من الكتالوج، ثم اضغط على «معاينة التعديل» لاحتساب الأسعار المعتمدة قبل الاعتماد النهائي.',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: .85),
                    fontSize: 11.5.sp,
                    height: 1.45,
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

class _CommercialPartyMiniCard extends StatelessWidget {
  const _CommercialPartyMiniCard({
    required this.roleLabel,
    required this.name,
    required this.logoUrl,
    required this.icon,
    required this.initial,
  });

  final String roleLabel;
  final String name;
  final String? logoUrl;
  final IconData icon;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: Row(
        children: [
          CustomCachedImage.logo(
            url: logoUrl,
            size: 28.r,
            borderRadius: 8.r,
            fallbackText: initial,
            fallbackTextStyle: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.hXs,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: .70),
                    fontSize: 9.5.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  name,
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// قسم بنود الطلب المقترحة للتعديل مع التحكم الذكي بالكميات
class _ProposedItemsSection
    extends GetView<NetworkProcurementReviewController> {
  const _ProposedItemsSection({required this.lines});

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
                Icons.tune_rounded,
                size: 16.r,
                color: colors.primary,
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: Text(
                'بنود الطلب المقترحة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            AppSpacing.hSm,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2.r,
              ),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: .4),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: colors.primary.withValues(alpha: .2)),
              ),
              child: Text(
                '${lines.length} باقات',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
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
              color: colors.errorContainer.withValues(alpha: .25),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.error.withValues(alpha: .3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colors.error,
                  size: 22.r,
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Text(
                    'يجب أن يحتوي الطلب على باقة واحدة على الأقل. اختر باقة من كتالوج الشبكة أدناه.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...lines.map(
            (line) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ModificationItemCard(line: line),
            ),
          ),
      ],
    );
  }
}

/// بطاقة الباقة المعدلة المتطورة بحاسبة الأوراق وأزرار التحكم الانسيابية
class _ModificationItemCard
    extends GetView<NetworkProcurementReviewController> {
  const _ModificationItemCard({required this.line});

  final RequestModificationLineEntity line;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final package = controller.availablePackages.firstWhereOrNull(
      (item) => item.packageId == line.packageId,
    );
    final packageName = package?.packageName ?? 'باقة #${line.packageId}';
    final sheetSize = package?.packageVoucherCount ?? 0;
    final halfSheet = sheetSize > 1 ? (sheetSize / 2).ceil() : 1;
    final packageColor = CustomColorPicker.parseHex(
      package?.packageColor,
      fallback: colors.primary,
    );
    final breakdown = sheetSize > 0
        ? VoucherSheetCalculator.describe(line.voucherCount, sheetSize)
        : '';
    final qtyController = controller.modificationQuantityController(
      line.packageId,
      line.voucherCount,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4.5.r, color: packageColor),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38.r,
                            height: 38.r,
                            decoration: BoxDecoration(
                              color: packageColor.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.wifi_tethering_rounded,
                              color: packageColor,
                              size: 19.r,
                            ),
                          ),
                          AppSpacing.hSm,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  packageName,
                                  style: AppTypography.titleSmall.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                AppSpacing.vXxs,
                                Row(
                                  children: [
                                    if (sheetSize > 0)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.r,
                                          vertical: 1.5.r,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.surfaceContainerHighest
                                              .withValues(alpha: .6),
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.xs,
                                          ),
                                        ),
                                        child: Text(
                                          'سعة الورقة: $sheetSize كرت',
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                                color: colors.onSurfaceVariant,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    if (breakdown.isNotEmpty) ...[
                                      AppSpacing.hXs,
                                      Expanded(
                                        child: Text(
                                          breakdown,
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                                color: colors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => controller.removeModificationPackage(
                              line.packageId,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            child: Container(
                              padding: EdgeInsets.all(7.r),
                              decoration: BoxDecoration(
                                color: colors.error.withValues(alpha: .10),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 18.r,
                                color: colors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vMd,
                      // شريط زيادة/نقصان وإدخال الكمية
                      Row(
                        children: [
                          _QuantityStepButton(
                            label: sheetSize > 0 ? '- ورقة' : '- 10',
                            icon: Icons.remove_rounded,
                            enabled: line.voucherCount > 1,
                            onTap: () => controller.stepModificationSheet(
                              line.packageId,
                              isIncrement: false,
                            ),
                          ),
                          AppSpacing.hSm,
                          Expanded(
                            child: Container(
                              height: 40.r,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withValues(alpha: .45),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(
                                    alpha: .45,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: qtyController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.titleSmall.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                    ),
                                    suffixText: 'كرت',
                                    suffixStyle: AppTypography.labelSmall
                                        .copyWith(
                                          color: colors.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  onChanged: (val) {
                                    final parsed = int.tryParse(val.trim());
                                    if (parsed != null && parsed >= 1) {
                                      controller.setModificationQuantity(
                                        line.packageId,
                                        parsed,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.hSm,
                          _QuantityStepButton(
                            label: sheetSize > 0 ? '+ ورقة' : '+ 10',
                            icon: Icons.add_rounded,
                            enabled: line.voucherCount < 1000000,
                            onTap: () => controller.stepModificationSheet(
                              line.packageId,
                              isIncrement: true,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      // شرائح سريعة
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        children: [
                          if (sheetSize > 1)
                            _QuickActionChip(
                              label: '+ نصف ورقة ($halfSheet)',
                              onTap: () => controller.stepModificationHalfSheet(
                                line.packageId,
                                isIncrement: true,
                              ),
                            ),
                          if (sheetSize > 0)
                            _QuickActionChip(
                              label: 'ورقة كاملة ($sheetSize)',
                              onTap: () => controller.setModificationQuantity(
                                line.packageId,
                                sheetSize,
                              ),
                            ),
                          _QuickActionChip(
                            label: 'كرت واحد (1)',
                            onTap: () => controller.setModificationQuantity(
                              line.packageId,
                              1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityStepButton extends StatelessWidget {
  const _QuantityStepButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 40.r,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: .5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.r, color: colors.primary),
              AppSpacing.hXxs,
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .4),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// قسم كتالوج إضافة الباقات التفاعلي الممتع
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
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: const CircularProgressIndicator.adaptive(),
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

/// قسم ملاحظات الاعتماد لنقطة البيع
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

/// قسم المعاينة والمقارنة المالية ذو العمق البصري الفائق
class _FinancialPreviewSection
    extends GetView<NetworkProcurementReviewController> {
  const _FinancialPreviewSection({required this.preview});

  final RequestModificationPreviewEntity? preview;

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
                color: colors.tertiary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 16.r,
                color: colors.tertiary,
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: Text(
                'معاينة الأسعار والخصومات المقترحة',
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
              gradient: LinearGradient(
                colors: [
                  colors.primaryContainer.withValues(alpha: .20),
                  colors.surfaceContainerLow,
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.primary.withValues(alpha: .25)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  size: 36.r,
                  color: colors.primary,
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
        else ...[
          // بطاقات المقارنة المالية الثلاث
          Row(
            children: [
              Expanded(
                child: _FinancialMetricCard(
                  label: 'الطلب الأصلي',
                  amount: preview!.originalTotalAmount,
                  isMuted: true,
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: _FinancialMetricCard(
                  label: 'المقترح للاعتماد',
                  amount: preview!.previewTotalAmount,
                  isPrimary: true,
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: _FinancialMetricCard(
                  label: 'إجمالي الخصم',
                  amount: preview!.totalDiscountAmount,
                  isDiscount: true,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          // شريط الفارق المالي
          _FinancialDiffBanner(
            original: preview!.originalTotalAmount,
            proposed: preview!.previewTotalAmount,
          ),
          AppSpacing.vMd,
          Text(
            'تفاصيل البنود والكميات بعد التعديل',
            style: AppTypography.labelLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.vSm,
          ...preview!.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs),
              child: _PreviewItemCard(item: item),
            ),
          ),
          if (preview!.removedItems.isNotEmpty) ...[
            AppSpacing.vSm,
            Text(
              'الباقات المحذوفة من الطلب',
              style: AppTypography.labelLarge.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w800,
              ),
            ),
            AppSpacing.vXs,
            ...preview!.removedItems.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                child: _RemovedItemCard(item: item),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _FinancialMetricCard extends StatelessWidget {
  const _FinancialMetricCard({
    required this.label,
    required this.amount,
    this.isPrimary = false,
    this.isMuted = false,
    this.isDiscount = false,
  });

  final String label;
  final double amount;
  final bool isPrimary;
  final bool isMuted;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = isPrimary
        ? colors.primary.withValues(alpha: .12)
        : isDiscount
        ? colors.tertiary.withValues(alpha: .10)
        : colors.surfaceContainerLow;
    final borderColor = isPrimary
        ? colors.primary.withValues(alpha: .35)
        : colors.outlineVariant.withValues(alpha: .35);
    final valueColor = isPrimary
        ? colors.primary
        : isDiscount
        ? colors.tertiary
        : colors.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.vXxs,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AmountFormatter.formatValue(amount),
              style: AppTypography.titleMedium.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialDiffBanner extends StatelessWidget {
  const _FinancialDiffBanner({required this.original, required this.proposed});

  final double original;
  final double proposed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final diff = proposed - original;
    final isIncrease = diff > 0.01;
    final isDecrease = diff < -0.01;

    final bannerColor = isIncrease
        ? colors.secondary.withValues(alpha: .10)
        : isDecrease
        ? colors.primary.withValues(alpha: .10)
        : colors.surfaceContainerLow;
    final borderColor = isIncrease
        ? colors.secondary.withValues(alpha: .25)
        : isDecrease
        ? colors.primary.withValues(alpha: .25)
        : colors.outlineVariant.withValues(alpha: .3);
    final iconColor = isIncrease
        ? colors.secondary
        : isDecrease
        ? colors.primary
        : colors.onSurfaceVariant;
    final icon = isIncrease
        ? Icons.trending_up_rounded
        : isDecrease
        ? Icons.trending_down_rounded
        : Icons.check_circle_outline_rounded;
    final text = isIncrease
        ? 'زيادة في إجمالي الطلب بمقدار ${AmountFormatter.formatValue(diff)}'
        : isDecrease
        ? 'تخفيض في إجمالي الطلب بمقدار ${AmountFormatter.formatValue(diff.abs())}'
        : 'إجمالي الطلب متطابق مع القيمة الأصلية تماماً';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17.r, color: iconColor),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              text,
              style: AppTypography.labelMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewItemCard extends GetView<NetworkProcurementReviewController> {
  const _PreviewItemCard({required this.item});

  final RequestModificationPreviewItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final package = controller.availablePackages.firstWhereOrNull(
      (p) => p.packageId == item.packageId,
    );
    final sheetSize = package?.packageVoucherCount ?? 0;
    final desc = sheetSize > 0
        ? VoucherSheetCalculator.describe(item.voucherCount, sheetSize)
        : null;
    final quantityLabel = desc != null
        ? '$desc (${item.voucherCount} كرت)'
        : '${item.voucherCount} كرت';
    final previousQuantity = item.originalVoucherCount;
    final isQuantityChanged = item.changeType == 'QUANTITY_CHANGED';
    final quantitySummary = isQuantityChanged && previousQuantity != null
        ? 'تعديل الكمية: من $previousQuantity إلى ${item.voucherCount} كرت'
        : quantityLabel;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.packageName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ModificationChangeBadge(changeType: item.changeType),
            ],
          ),
          AppSpacing.vXxs,
          Text(
            quantitySummary,
            style: AppTypography.labelSmall.copyWith(
              color: isQuantityChanged
                  ? colors.primary
                  : colors.onSurfaceVariant,
              fontWeight: isQuantityChanged
                  ? FontWeight.w700
                  : FontWeight.normal,
            ),
          ),
          AppSpacing.vXs,
          Row(
            children: [
              if (item.itemDiscount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                  decoration: BoxDecoration(
                    color: colors.tertiary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'خصم ${item.itemDiscount}%',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.tertiary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                AmountFormatter.format(item.itemTotalAmount.toString()),
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RemovedItemCard extends StatelessWidget {
  const _RemovedItemCard({required this.item});

  final RequestModificationRemovedItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.error.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.remove_circle_outline_rounded,
            size: 16.r,
            color: colors.error,
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.packageName,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'تم حذف ${item.originalVoucherCount} كرت',
                  style: AppTypography.labelSmall.copyWith(color: colors.error),
                ),
              ],
            ),
          ),
          Text(
            AmountFormatter.format(item.originalItemTotal.toString()),
            style: AppTypography.labelSmall.copyWith(
              color: colors.error,
              decoration: TextDecoration.lineThrough,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModificationChangeBadge extends StatelessWidget {
  const _ModificationChangeBadge({required this.changeType});

  final String changeType;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (changeType) {
      'ITEM_ADDED' => ('باقة مضافة', SemanticTone.success),
      'QUANTITY_CHANGED' => ('تعديل الكمية', SemanticTone.warning),
      'ITEM_REMOVED' => ('محذوف', SemanticTone.danger),
      _ => ('بدون تغيير', SemanticTone.info),
    };

    return CustomStatusBadge(label: label, tone: tone);
  }
}

/// الشريط السفلي العائم للشيت
class _ModificationFooter extends GetView<NetworkProcurementReviewController> {
  const _ModificationFooter();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final preview = controller.currentPreview.value;
      final canApprove =
          preview != null &&
          preview.hasModifications &&
          !controller.isPreviewingModification.value &&
          !controller.isProcessingDecision.value;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (preview != null) ...[
              Row(
                children: [
                  Text(
                    'الصافي المقترح:',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.hXs,
                  Text(
                    AmountFormatter.formatValue(preview.previewTotalAmount),
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  CustomStatusBadge(
                    label: 'جاهز للاعتماد',
                    tone: SemanticTone.success,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
              AppSpacing.vSm,
            ],
            Row(
              children: [
                Expanded(
                  child: CustomButton.outline(
                    text: preview == null ? 'معاينة التعديل' : 'إعادة المعاينة',
                    icon: Icons.calculate_outlined,
                    loading: controller.isPreviewingModification.value,
                    onPressed:
                        controller.modificationLines.isEmpty ||
                            controller.isPreviewingModification.value
                        ? null
                        : controller.previewModification,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: CustomButton.primary(
                    text: 'اعتماد التعديل',
                    icon: Icons.verified_outlined,
                    enabled: canApprove,
                    loading: controller.isProcessingDecision.value,
                    onPressed: !canApprove
                        ? null
                        : controller.confirmAndApproveModification,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
