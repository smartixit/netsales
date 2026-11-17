import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة عرض طلب التوريد في القوائم التشغيلية (Procurement Request Card)
/// تدعم:
/// 1. الهيدر الفاخر الخالي تماماً من الـ Overflow مع شارة الحرف الأول للجهة.
/// 2. المؤشرات المالية المزدوجة (الكروت والأوراق) والسعر السيادي المعتمد.
/// 3. الـ Accordion التفاعلي الحصري لعرض وتفصيل الباقات والأسعار والخصومات دون ازدحام.
/// 4. أزرار العمليات المصرفية الذكية (تعديل، إلغاء، حذف للطلبات الملغية).
class ProcurementRequestCard extends StatelessWidget {
  final RequestEntity request;
  final bool isNetworkView;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback? onToggleAccordion;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onModify;
  final VoidCallback? onReject;

  const ProcurementRequestCard({
    super.key,
    required this.request,
    this.isNetworkView = false,
    this.isExpanded = false,
    required this.onTap,
    this.onToggleAccordion,
    this.onEdit,
    this.onCancel,
    this.onDelete,
    this.onApprove,
    this.onModify,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusPresentation = EnumPresentationRegistry.resolveRequestStatus(
      request.status,
      serverLabel: request.statusLabel,
    );

    final saleTypePresentation = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );

    final orgTitle = isNetworkView
        ? (request.posName ?? 'نقطة بيع #${request.posId}')
        : (request.networkName ?? 'شبكة #${request.networkId}');

    final initialChar = TextFormatter.avatarInitial(
      orgTitle,
      fallback: isNetworkView ? 'ن' : 'ش',
    );

    final hasItems = request.items.isNotEmpty;
    final totalVouchers = request.totalVouchers;
    final totalSheets = request.totalSheets;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isExpanded
                ? colors.primary.withValues(alpha: 0.35)
                : colors.outlineVariant.withValues(alpha: 0.4),
            width: isExpanded ? 1.5 : 1.0,
          ),
          boxShadow: AppElevation.level2(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. رأس البطاقة: شعار الحرف + اسم الجهة + المعرف المرجعي + شارة الحالة
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.cardPadding,
                AppSpacing.cardPadding,
                AppSpacing.cardPadding,
                AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomAvatarBadge(
                    initials: initialChar,
                    customDimension: 38.r,
                    hasPulse: false,
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                orgTitle,
                                style: AppTypography.titleSmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vXxs,
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                              ),
                              child: Text(
                                '#${request.requestUuid ?? request.requestId.toString()}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (request.requestDate != null) ...[
                              AppSpacing.hXs,
                              Flexible(
                                child: Text(
                                  request.requestDate!,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 10.sp,
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
                  AppSpacing.hSm,
                  CustomStatusBadge(
                    label: statusPresentation.label,
                    tone: statusPresentation.tone,
                    icon: statusPresentation.icon,
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.25),
            ),

            // 2. شريط المؤشرات المالية والكميات المعيارية (كروت + أوراق + السعر الإجمالي)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // نوع الدفع وحجم الطلب
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: request.saleTypeRaw == 'CREDIT'
                                    ? colors.warning.withValues(alpha: 0.12)
                                    : colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                              ),
                              child: Text(
                                saleTypePresentation.label,
                                style: AppTypography.labelSmall.copyWith(
                                  color: request.saleTypeRaw == 'CREDIT'
                                      ? colors.warning
                                      : colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (totalVouchers > 0) ...[
                              AppSpacing.hXs,
                              Flexible(
                                child: Text(
                                  '$totalVouchers كرت${totalSheets > 0 ? " • ${totalSheets.toStringAsFixed(totalSheets.truncateToDouble() == totalSheets ? 0 : 1)} ورقة" : ""}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
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

                  // قيمة الطلب الأصلية كما أرسلها صاحب الطلب
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'قيمة الطلب الأصلي',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                      Text(
                        AmountFormatter.format(
                          request.requestTotalAmount.toString(),
                        ),
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. زر طي/فتح الأكورديون الذكي لبنود الطلب
            if (hasItems) ...[
              InkWell(
                onTap: onToggleAccordion,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.cardPadding,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20.r,
                        color: colors.primary,
                      ),
                      AppSpacing.hXs,
                      Text(
                        isExpanded
                            ? 'إخفاء تفاصيل الباقات والكميات'
                            : 'تفاصيل الباقات (${request.items.length} ${request.items.length == 1 ? "باقة" : "باقات"})',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // محتوى الـ Accordion المنسدل (Exclusive Single Expansion)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(
                    AppSpacing.cardPadding,
                    AppSpacing.xxs,
                    AppSpacing.cardPadding,
                    AppSpacing.sm,
                  ),
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...request.items.map((item) {
                        final pkg = item.voucherPackage;
                        final pkgName =
                            pkg?.packageName ?? 'باقة #${item.packageId}';
                        final pkgColor = pkg?.packageColor != null
                            ? CustomColorPicker.parseHex(pkg!.packageColor)
                            : colors.primary;
                        final sheetCapacity = pkg?.packageVoucherCount ?? 100;
                        final sheetsDesc = VoucherSheetCalculator.describe(
                          item.voucherCount,
                          sheetCapacity,
                        );

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            children: [
                              Container(
                                width: 8.r,
                                height: 8.r,
                                decoration: BoxDecoration(
                                  color: pkgColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppSpacing.hSm,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pkgName,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${item.voucherCount} كرت ($sheetsDesc)',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    AmountFormatter.format(
                                      item.itemTotalAmount.toString(),
                                    ),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (item.itemDiscount > 0)
                                    Text(
                                      'خصم ${item.itemDiscount}%',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.success,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      if (request.requestNote != null &&
                          request.requestNote!.isNotEmpty) ...[
                        AppSpacing.vXs,
                        Divider(
                          height: 1,
                          color: colors.outlineVariant.withValues(alpha: 0.2),
                        ),
                        AppSpacing.vXs,
                        Row(
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              size: 14.r,
                              color: colors.onSurfaceVariant,
                            ),
                            AppSpacing.hXs,
                            Expanded(
                              child: Text(
                                request.requestNote!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
              ),
            ],

            // 4. أزرار العمليات المصرفية والتشغيلية (Context Actions)
            if (_hasActions) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.cardPadding,
                  AppSpacing.xxs,
                  AppSpacing.cardPadding,
                  AppSpacing.cardPadding,
                ),
                child: isNetworkView
                    ? _buildNetworkActions(context)
                    : _buildPosActions(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasActions {
    if (isNetworkView) {
      return request.isPending &&
          (onModify != null || onApprove != null || onReject != null);
    }
    return (request.isPending && (onEdit != null || onCancel != null)) ||
        (request.isCancelled && onDelete != null);
  }

  /// أزرار عمليات نقطة البيع (تعديل الطلب، إلغاء، حذف السجل الملغي)
  Widget _buildPosActions(BuildContext context) {
    final colors = context.colors;

    if (request.isPending) {
      return Row(
        children: [
          if (onEdit != null)
            Expanded(
              child: CustomButton.outline(
                text: 'تعديل الطلب',
                icon: Icons.edit_note_rounded,
                size: AppButtonSize.small,
                borderColor: colors.primary.withValues(alpha: 0.5),
                foregroundColor: colors.primary,
                onPressed: onEdit,
              ),
            ),
          if (onEdit != null && onCancel != null) AppSpacing.hSm,
          if (onCancel != null)
            Expanded(
              child: CustomButton.outline(
                text: 'إلغاء الطلب',
                icon: Icons.close_rounded,
                size: AppButtonSize.small,
                borderColor: colors.error.withValues(alpha: 0.5),
                foregroundColor: colors.error,
                onPressed: onCancel,
              ),
            ),
        ],
      );
    }

    if (request.isCancelled && onDelete != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: CustomButton.outline(
          text: 'حذف من السجل',
          icon: Icons.delete_outline_rounded,
          size: AppButtonSize.small,
          borderColor: colors.error.withValues(alpha: 0.4),
          foregroundColor: colors.error,
          onPressed: onDelete,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// أزرار عمليات مالك ومسؤول الشبكة الموردة (تعديل، اعتماد، رفض)
  Widget _buildNetworkActions(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        if (onModify != null) ...[
          SizedBox(
            width: double.infinity,
            child: CustomButton.outline(
              text: 'تعديل البنود ومعاينة التسعير',
              icon: Icons.edit_note_rounded,
              size: AppButtonSize.small,
              onPressed: onModify,
            ),
          ),
          AppSpacing.vXs,
        ],
        Row(
          children: [
            if (onApprove != null)
              Expanded(
                child: CustomButton(
                  text: 'اعتماد كما هو',
                  icon: Icons.check_circle_outline_rounded,
                  size: AppButtonSize.small,
                  backgroundColor: colors.success,
                  foregroundColor: colors.onSuccess,
                  onPressed: onApprove,
                ),
              ),
            if (onApprove != null && onReject != null) AppSpacing.hSm,
            if (onReject != null)
              Expanded(
                child: CustomButton.outline(
                  text: 'رفض',
                  icon: Icons.cancel_outlined,
                  size: AppButtonSize.small,
                  borderColor: colors.error.withValues(alpha: 0.5),
                  foregroundColor: colors.error,
                  onPressed: onReject,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
