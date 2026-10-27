import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// عنصر صف فاتورة المبيعات في السجل المالي (SaleInvoiceLedgerTile)
/// ============================================================================
/// يعرض حركة الفاتورة بسلاسة وتصميم تنفيذي مفتوح متوافق كلياً مع كافة أحجام الشاشات.
class SaleInvoiceLedgerTile extends StatelessWidget {
  final SaleInvoiceEntity invoice;
  final VoidCallback onTap;

  const SaleInvoiceLedgerTile({
    super.key,
    required this.invoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCash = invoice.isCash;
    final isFullyPaid = invoice.isFullyPaid;
    final formattedTotal = AmountFormatter.formatValue(
      invoice.invoiceTotalAmount,
    );
    final formattedRemaining = AmountFormatter.formatValue(
      invoice.remainingAmount,
    );

    final dt = invoice.invoiceDate != null
        ? DateTime.tryParse(invoice.invoiceDate!)
        : (invoice.createdAt != null
              ? DateTime.tryParse(invoice.createdAt!)
              : null);
    final timeStr = dt != null ? DateFormatter.time(dt) : '';

    final subtitleParts = [
      invoice.invoiceUuid,
      if (timeStr.isNotEmpty) timeStr,
      if (invoice.totalCardsCount > 0) '${invoice.totalCardsCount} كرت',
    ].join(' • ');

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12.h,
        ),
        color: Colors.transparent,
        child: Row(
          children: [
            // 1. أيقونة نقطة البيع بهالة لونية ناعمة وشارة نوع البيع
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.storefront_rounded,
                    color: colors.primary,
                    size: 19.r,
                  ),
                ),
                Positioned(
                  bottom: -1.r,
                  right: -1.r,
                  child: Container(
                    width: 13.r,
                    height: 13.r,
                    decoration: BoxDecoration(
                      color: isCash ? colors.primary : colors.warning,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 2.r),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isCash ? Icons.check_rounded : Icons.schedule_rounded,
                      color: colors.surface,
                      size: 7.r,
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.hSm,

            // 2. الهوية والمعلومات (نقطة البيع + الشبكة + رقم المرجع)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          invoice.posName ?? 'نقطة بيع #${invoice.posId}',
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppSpacing.hXs,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isCash
                              ? colors.primary.withValues(alpha: 0.09)
                              : colors.warning.withValues(alpha: 0.12),
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Text(
                          isCash ? 'نقدي' : 'آجل',
                          style: AppTypography.labelSmall.copyWith(
                            color: isCash ? colors.primary : colors.warning,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vXxs,
                  Text(
                    subtitleParts,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                      fontSize: 9.5.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            AppSpacing.hSm,

            // 3. الجزء المالي (المبلغ الإجمالي + كبسولة السداد)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 100.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formattedTotal,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        AppSpacing.hXxs,
                        Text(
                          'ر.ي',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.vXxs,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: isFullyPaid
                          ? colors.surfaceContainerHighest
                          : colors.warning.withValues(alpha: 0.12),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(
                      isFullyPaid ? 'خالصة' : 'متبقي: $formattedRemaining',
                      style: AppTypography.labelSmall.copyWith(
                        color: isFullyPaid
                            ? colors.onSurfaceVariant
                            : colors.warning,
                        fontWeight: FontWeight.w700,
                        fontSize: 9.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
