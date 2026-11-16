import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة عرض الفاتورة المالية المتنقلة بنظام الـ VIP والـ Accordion الأحادي الانسيابي
class InvoiceCard extends StatelessWidget {
  final InvoiceEntity invoice;
  final VoidCallback onTap;
  final bool isExpanded;
  final VoidCallback? onToggleExpansion;
  final bool isNetworkView;
  final VoidCallback? onPrint;
  final VoidCallback? onRepay;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
    this.isExpanded = false,
    this.onToggleExpansion,
    this.isNetworkView = true,
    this.onPrint,
    this.onRepay,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final paymentPresentation =
        EnumPresentationRegistry.resolveInvoicePaymentStatus(
          invoice.paymentStatus,
        );
    final saleTypePresentation = EnumPresentationRegistry.resolveSaleType(
      invoice.saleType,
    );

    final partyLabel = isNetworkView ? 'نقطة البيع:' : 'المزود (الشبكة):';
    final partyName = isNetworkView
        ? (invoice.posName ?? 'نقطة بيع #${invoice.posId}')
        : (invoice.networkName ?? 'شبكة #${invoice.networkId}');

    final paidPct = invoice.invoiceTotalAmount > 0
        ? (invoice.paidAmount / invoice.invoiceTotalAmount).clamp(0.0, 1.0)
        : (invoice.isPaid ? 1.0 : 0.0);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppElevation.level1(context),
        border: Border.all(
          color: isExpanded
              ? colors.primary.withValues(alpha: 0.5)
              : colors.outlineVariant.withValues(alpha: 0.4),
          width: isExpanded ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. رأس البطاقة القابل للنقر للانتقال للتفاصيل ──
          CustomInteractiveBounce(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // سطر المعرف وشارة الحالة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Icon(
                                Icons.receipt_outlined,
                                color: colors.primary,
                                size: 20,
                              ),
                            ),
                            AppSpacing.hSm,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'فاتورة #${invoice.invoiceUuid ?? invoice.invoiceId}',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (invoice.invoiceDate != null)
                                    Text(
                                      invoice.invoiceDate!.length >= 10
                                          ? invoice.invoiceDate!.substring(0, 10)
                                          : invoice.invoiceDate!,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.hSm,
                      CustomStatusBadge(
                        label: invoice.paymentStatusLabel ??
                            paymentPresentation.label,
                        tone: paymentPresentation.tone,
                        icon: paymentPresentation.icon,
                      ),
                    ],
                  ),

                  AppSpacing.vSm,
                  Divider(
                    color: colors.outlineVariant.withValues(alpha: 0.3),
                    height: 1,
                  ),
                  AppSpacing.vSm,

                  // معلومات الطرف التجاري ونوع البيع
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              partyLabel,
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            AppSpacing.hXs,
                            Expanded(
                              child: Text(
                                partyName,
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          invoice.saleTypeLabel ?? saleTypePresentation.label,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.vSm,

                  // شريط الملخص والتقدم المالي
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'إجمالي الفاتورة',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  AmountFormatter.format(
                                    invoice.invoiceTotalAmount.toString(),
                                  ),
                                  style: AppTypography.titleMedium.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (invoice.remainingAmount > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'المتبقي للسداد',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: colors.error,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    AmountFormatter.format(
                                      invoice.remainingAmount.toString(),
                                    ),
                                    style: AppTypography.titleMedium.copyWith(
                                      color: colors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: colors.primary,
                                    size: 16,
                                  ),
                                  AppSpacing.hXs,
                                  Text(
                                    'مسددة بالكامل',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        AppSpacing.vXs,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            value: paidPct,
                            minHeight: 5,
                            backgroundColor:
                                colors.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              invoice.isPaid
                                  ? colors.primary
                                  : (invoice.isPartiallyPaid
                                      ? colors.warning
                                      : colors.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 2. شريط زر التوسيع والطي الأحادي (Accordion Toggle Bar) ──
          InkWell(
            onTap: onToggleExpansion,
            borderRadius: BorderRadius.vertical(
              bottom: isExpanded ? Radius.zero : Radius.circular(AppRadius.card),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                border: Border(
                  top: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.layers_outlined,
                          size: 16,
                          color: colors.primary,
                        ),
                        AppSpacing.hXs,
                        Flexible(
                          child: Text(
                            'الباقات والكميات (${invoice.items.length})',
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (invoice.totalVouchersCount > 0) ...[
                          AppSpacing.hXs,
                          Text(
                            '• ${invoice.totalVouchersCount} كرت',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AppSpacing.hSm,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isExpanded ? 'إخفاء البنود' : 'عرض التفاصيل',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── 3. درج بنود الفاتورة بالكميات الموحدة (Animated Accordion Drawer) ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildAccordionItemsDrawer(context, colors),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }

  /// بناء درج بنود الفاتورة الموسعة مع الكميات الموحدة والإجراءات السريعة
  Widget _buildAccordionItemsDrawer(BuildContext context, AppColors colors) {
    if (invoice.items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        color: colors.surfaceContainerLowest,
        child: Center(
          child: Text(
            'لا توجد بنود إضافية مخزنة، انقر على الفاتورة لفتح سجل التدقيق الكامل.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      color: colors.surfaceContainerLowest.withValues(alpha: 0.5),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // قائمة البنود بالكميات الموحدة وفق محرك VoucherSheetCalculator
          ...invoice.items.map((item) => _buildInvoiceItemTile(context, item, colors)),

          AppSpacing.vSm,

          // أزرار الإجراءات السريعة للموبايل
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onPrint != null)
                CustomButton.outline(
                  text: 'إيصال حراري',
                  size: AppButtonSize.small,
                  icon: Icons.print_outlined,
                  onPressed: onPrint,
                ),
              if (invoice.remainingAmount > 0 && onRepay != null) ...[
                AppSpacing.hSm,
                CustomButton.primary(
                  text: 'سداد آجل',
                  size: AppButtonSize.small,
                  icon: Icons.payments_outlined,
                  onPressed: onRepay,
                ),
              ],
              AppSpacing.hSm,
              CustomButton.outline(
                text: 'تفاصيل كاملة',
                size: AppButtonSize.small,
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// سطر بند الفاتورة المتنقل بالأسلوب الموحد للمشروع
  Widget _buildInvoiceItemTile(
    BuildContext context,
    InvoiceItemEntity item,
    AppColors colors,
  ) {
    final packageColor = CustomColorPicker.parseHex(item.packageColor);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // شريط لون الباقة المعتمد
          Container(
            width: 4,
            height: 38,
            decoration: BoxDecoration(
              color: packageColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          AppSpacing.hSm,

          // اسم الباقة وسعر الكرت المفرد
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.packageName ?? 'باقة #${item.packageId}',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vXxs,
                Text(
                  'سعر الكرت: ${AmountFormatter.format(item.voucherPrice.toString())}',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // كبسولة الكمية الموحدة (VoucherSheetCalculator Dual-Unit Standard)
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.xs),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                item.fullQuantityLabel,
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AppSpacing.hSm,

          // إجمالي البند المالي
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AmountFormatter.format(item.itemTotalAmount.toString()),
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.itemDiscount > 0)
                  Text(
                    'خصم: ${AmountFormatter.format(item.itemDiscount.toString())}',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.error,
                      fontSize: 10,
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
