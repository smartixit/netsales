import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// بطاقة طلب التوريد المتطورة بنظام الأكورديون الأنيق (Procurement Order Card V2 - Executive Edition)
///
/// تجسد نفس العمق البصري للبطاقات الزمردية في شاشة إنشاء الطلب:
/// حواف 24.r، ظلال مزدوجة بمسحة زمردية، شريط ترويسة بهوية الطلب يعرض الـ UUID كاملاً بدون انقطاع
/// مع نقل شارة الحالة للسطر المساعد، أكورديون تفاعلي أنيق لاستعراض بنود الطلب والكميات والأوراق،
/// وسكة القياس ثلاثية الأعمدة، وأزرار الإجراءات التفاعلية السلسة.
class PosProcurementOrderCard extends StatelessWidget {
  const PosProcurementOrderCard({
    super.key,
    required this.request,
    required this.onDetails,
    this.isExpanded = false,
    this.onToggleExpand,
    this.onEdit,
    this.onCancel,
    this.onDelete,
  });

  final RequestEntity request;
  final VoidCallback onDetails;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  Future<void> _showActions() async {
    final actions = <CustomBottomSheetActionItem>[
      CustomBottomSheetActionItem(
        title: 'عرض تفاصيل الطلب الكاملة',
        icon: Icons.visibility_outlined,
        onTap: onDetails,
      ),
      if (onEdit != null)
        CustomBottomSheetActionItem(
          title: 'تعديل كميات الطلب',
          icon: Icons.edit_note_rounded,
          onTap: onEdit!,
        ),
      if (onCancel != null)
        CustomBottomSheetActionItem(
          title: 'إلغاء طلب التوريد',
          icon: Icons.cancel_outlined,
          isDestructive: true,
          onTap: onCancel!,
        ),
      if (onDelete != null)
        CustomBottomSheetActionItem(
          title: 'حذف سجل الطلب',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onTap: onDelete!,
        ),
    ];

    await CustomBottomSheet.showActions<void>(
      title: 'إجراءات طلب التوريد #${request.requestId}',
      leadingIcon: Icons.receipt_long_rounded,
      items: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = EnumPresentationRegistry.resolveRequestStatus(
      request.status,
      serverLabel: request.statusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );
    final packages = request.items
        .map((item) => item.voucherPackage)
        .whereType<PackageEntity>()
        .toList(growable: false);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: colors.primary.withValues(alpha: .15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064F43).withValues(alpha: .065),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. ترويسة هوية الطلب (عرض الـ UUID كاملاً بدون كلمة "طلب توريد" مع نقل شارة الحالة للسطر الثاني)
          _OrderCardHeader(
            request: request,
            status: status,
            saleType: saleType,
          ),

          // 2. المحتوى الداخلي للطلب
          Padding(
            padding: EdgeInsets.fromLTRB(14.r, 12.r, 14.r, 14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // لوحة الباقات المضمنة في الطلب بنظام الأكورديون الأنيق
                _OrderItemsAccordion(
                  request: request,
                  packages: packages,
                  isExpanded: isExpanded,
                  onToggle: onToggleExpand,
                ),
                AppSpacing.vSm,

                // سكة القياسات الثلاثية (باقات، كمية، إجمالي القيمة)
                _OrderMetricsRail(
                  itemCount: request.items.length,
                  totalQuantity: request.totalVouchers,
                  totalAmount: request.requestTotalAmount,
                ),
                AppSpacing.vSm,

                // شريط أزرار الإجراءات
                Row(
                  children: [
                    Expanded(
                      child: CustomButton.outline(
                        text: 'عرض التفاصيل',
                        icon: Icons.chevron_right_rounded,
                        iconPosition: AppButtonIconPosition.end,
                        size: AppButtonSize.small,
                        foregroundColor: colors.primary,
                        borderColor: colors.primary.withValues(alpha: .6),
                        onPressed: onDetails,
                      ),
                    ),
                    if (onEdit != null) ...[
                      AppSpacing.hXs,
                      CustomButton.icon(
                        icon: Icons.edit_note_rounded,
                        tooltip: 'تعديل الطلب',
                        dimension: 38.r,
                        backgroundColor: colors.surfaceContainerHigh,
                        foregroundColor: colors.primary,
                        borderColor: colors.primary.withValues(alpha: .3),
                        onPressed: onEdit,
                      ),
                    ],
                    if (onCancel != null) ...[
                      AppSpacing.hXs,
                      CustomButton.icon(
                        icon: Icons.cancel_outlined,
                        tooltip: 'إلغاء الطلب',
                        dimension: 38.r,
                        backgroundColor: colors.error.withValues(alpha: .08),
                        foregroundColor: colors.error,
                        borderColor: colors.error.withValues(alpha: .25),
                        onPressed: onCancel,
                      ),
                    ],
                    AppSpacing.hXs,
                    CustomButton.icon(
                      icon: Icons.more_horiz_rounded,
                      tooltip: 'المزيد من الخيارات',
                      dimension: 38.r,
                      backgroundColor: colors.surfaceContainer,
                      foregroundColor: colors.onSurfaceVariant,
                      borderColor: colors.outlineVariant.withValues(alpha: .6),
                      onPressed: _showActions,
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

class _OrderCardHeader extends StatelessWidget {
  const _OrderCardHeader({
    required this.request,
    required this.status,
    required this.saleType,
  });

  final RequestEntity request;
  final EnumPresentation status;
  final EnumPresentation saleType;

  String _dateLabel() {
    final raw = request.requestDate ?? request.createdAt;
    if (raw == null || raw.isEmpty) return 'التاريخ غير متاح';
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? raw : DateFormatter.fullDate(parsed);
  }

  String _timeLabel() {
    final raw = request.requestDate ?? request.createdAt;
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? '' : DateFormatter.time(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayUuid = request.requestUuid?.isNotEmpty == true
        ? request.requestUuid!
        : '#${request.requestId}';
    final timeStr = _timeLabel();
    final dateTimeText = timeStr.isNotEmpty
        ? '${_dateLabel()} • $timeStr'
        : _dateLabel();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colors.primary.withValues(alpha: .06),
            colors.primary.withValues(alpha: .015),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: colors.primary.withValues(alpha: .08),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── الجهة الأولى (اليمين): الأيقونة الزمردية الفاخرة بهوية التطبيق ──
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF087F68), Color(0xFF075B55)],
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFFFD98A).withValues(alpha: .40),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF087F68).withValues(alpha: .22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 22.r,
            ),
          ),
          AppSpacing.hSm,

          // ── الجهة الثانية (اليسار): العمود الذي يحتوي على 3 أسطر متناسقة ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // السطر 1: رقم الطلب كاملاً مع زر النسخ السريع بكامل العرض المتاح دون أي تزاحم
                Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          displayUuid,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.hXxs,
                    CustomInteractiveBounce(
                      onTap: () {
                        UrlLauncherService.copyToClipboard(
                          displayUuid,
                          confirmationMessage: 'تم نسخ معرف الطلب',
                        );
                        CustomSnackbar.show(
                          title: 'تم النسخ',
                          message: 'تم نسخ المعرف $displayUuid إلى الحافظة',
                          type: SnackType.info,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: .4),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 12.r,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vXxs,

                // السطر 2: الشارات مع إمكانية التمرير الأفقي لمنع أي تجاوز أو قص مهما زاد عددها أو طولها
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomStatusBadge.fromPresentation(
                        status,
                        isCompact: true,
                      ),
                      AppSpacing.hXs,
                      CustomStatusBadge.fromPresentation(
                        saleType,
                        isCompact: true,
                      ),
                    ],
                  ),
                ),
                AppSpacing.vXxs,

                // السطر 3: الوقت والتاريخ كاملاً وبوضوح تام
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 11.5.r,
                      color: colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXxs,
                    Flexible(
                      child: Text(
                        dateTimeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
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

/// أكورديون بنود طلب التوريد المتطور (Items Accordion)
class _OrderItemsAccordion extends StatelessWidget {
  const _OrderItemsAccordion({
    required this.request,
    required this.packages,
    required this.isExpanded,
    this.onToggle,
  });

  final RequestEntity request;
  final List<PackageEntity> packages;
  final bool isExpanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final itemCount = request.items.length;
    final visibleNames = packages.take(3).map((p) => p.packageName).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isExpanded
              ? colors.primary.withValues(alpha: .35)
              : colors.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط النقر لفتح أو إغلاق الأكورديون (باستخدام InkWell لضمان استجابة كل البكسلات للنقر)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 10.r),
                child: Row(
                  children: [
                    // شريط ألوان الباقات التوضيحي
                    if (packages.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (
                            var i = 0;
                            i < packages.length.clamp(0, 4);
                            i++
                          ) ...[
                            if (i > 0) AppSpacing.hXxs,
                            Container(
                              width: 5.r,
                              height: 32.r,
                              decoration: BoxDecoration(
                                color: CustomColorPicker.parseHex(
                                  packages[i].packageColor,
                                  fallback: colors.primary,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    if (packages.isNotEmpty) AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            itemCount == 0
                                ? 'لا توجد باقات محددة'
                                : '$itemCount ${itemCount == 1 ? 'باقة' : 'باقات'} • ${request.totalVouchers} كرت',
                            style: AppTypography.labelLarge.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (visibleNames.isNotEmpty && !isExpanded) ...[
                            AppSpacing.vXxs,
                            Text(
                              visibleNames.join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'إخفاء البنود' : 'عرض البنود',
                          style: AppTypography.caption.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.hXxs,
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOutCubic,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colors.primary,
                            size: 20.r,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // المحتوى المتمدد للأكورديون بحركة انسيابية فائقة (AnimatedSize + ClipRect)
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Divider(
                          height: 1,
                          color: colors.outlineVariant.withValues(alpha: .4),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.r, 8.r, 12.r, 10.r),
                          child: Column(
                            children: [
                              for (
                                var i = 0;
                                i < request.items.length;
                                i++
                              ) ...[
                                if (i > 0)
                                  Divider(
                                    height: 12.h,
                                    color: colors.outlineVariant.withValues(
                                      alpha: .25,
                                    ),
                                  ),
                                _AccordionItemRow(item: request.items[i]),
                              ],
                              if (request.requestNote != null &&
                                  request.requestNote!.trim().isNotEmpty) ...[
                                AppSpacing.vSm,
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.r,
                                    vertical: 6.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest
                                        .withValues(alpha: .5),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.sticky_note_2_outlined,
                                        size: 13.r,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      AppSpacing.hXxs,
                                      Expanded(
                                        child: Text(
                                          'ملاحظات: ${request.requestNote}',
                                          style: AppTypography.caption.copyWith(
                                            color: colors.onSurfaceVariant,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// سطر البند الفردي داخل الأكورديون مع تفاصيل الكميات والأوراق والقيمة
class _AccordionItemRow extends StatelessWidget {
  const _AccordionItemRow({required this.item});

  final RequestItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final package = item.voucherPackage;
    final packageName = package?.packageName ?? 'باقة #${item.packageId}';
    final sheetSize = (package?.packageVoucherCount ?? 0) > 0
        ? package!.packageVoucherCount
        : 1;
    final sheetDescription = VoucherSheetCalculator.describe(
      item.voucherCount,
      sheetSize,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // علامة لون الباقة
        Container(
          width: 4.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: CustomColorPicker.parseHex(
              package?.packageColor,
              fallback: colors.primary,
            ),
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
                packageName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.vXxs,
              Text(
                '${item.voucherCount} كرت ($sheetDescription)',
                style: AppTypography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.hSm,
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                AmountFormatter.formatValue(item.itemTotalAmount),
                style: AppTypography.labelLarge.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (item.itemDiscount > 0)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  'خصم: ${AmountFormatter.formatValue(item.itemDiscount)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _OrderMetricsRail extends StatelessWidget {
  const _OrderMetricsRail({
    required this.itemCount,
    required this.totalQuantity,
    required this.totalAmount,
  });

  final int itemCount;
  final int totalQuantity;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OrderMetricItem(
              label: 'عدد البنود',
              value: '$itemCount',
              icon: Icons.format_list_numbered_rounded,
            ),
          ),
          _MetricDivider(),
          Expanded(
            child: _OrderMetricItem(
              label: 'إجمالي الكروت',
              value: '$totalQuantity',
              icon: Icons.confirmation_number_outlined,
            ),
          ),
          _MetricDivider(),
          Expanded(
            child: _OrderMetricItem(
              label: 'إجمالي القيمة',
              value: AmountFormatter.formatValue(totalAmount),
              icon: Icons.payments_outlined,
              isHighlighted: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMetricItem extends StatelessWidget {
  const _OrderMetricItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15.r,
          color: isHighlighted ? colors.primary : colors.onSurfaceVariant,
        ),
        AppSpacing.vXxs,
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vXxs,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleSmall.copyWith(
              color: isHighlighted ? colors.primary : colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 36.h,
    color: context.colors.outlineVariant.withValues(alpha: .4),
  );
}
