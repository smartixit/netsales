import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// سند فاتورة المبيعات السيادي الفاخر (SaleInvoiceLedgerTile)
/// ============================================================================
/// يجسد فاتورة المبيعات كسند مالي سيادي فاخر (Sovereign Financial Bond)،
/// يقسم البطاقة إلى ترويسة تنفيذية للهوية، وفاصل شعري ناعم، ورصيف مالي فخم،
/// مع تدرج محيطي دقيق ومرونة استثنائية عبر كافة الشاشات دون أي تكدس أو شارات مبعثرة.
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
    final dateStr = dt != null
        ? DateFormatter.dateTime(dt)
        : (invoice.invoiceDate ?? '');

    // اللون المحوري للحركة المالية (نقدي زمردي / آجل كهرماني)
    final themeColor = isCash ? colors.primary : colors.warning;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppElevation.level1(context),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.lgRadius,
          child: Stack(
            children: [
              // وعاء البطاقة الأساسي مع التوهج المحيطي الناعم
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      themeColor.withValues(alpha: 0.05),
                      colors.surface.withValues(alpha: 0.35),
                      colors.surfaceContainerLowest,
                    ],
                    stops: const [0.0, 0.40, 1.0],
                  ),
                  borderRadius: AppRadius.lgRadius,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.28),
                    width: 1.w,
                  ),
                ),
                padding: EdgeInsetsDirectional.only(
                  start: 16.w,
                  end: 14.w,
                  top: 12.h,
                  bottom: 12.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. الترويسة التنفيذية: هوية نقطة البيع وشارة الحالة الموحدة
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // أيقونة نقطة البيع بوعاء سكويركل ذو توهج لوني
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                themeColor.withValues(alpha: 0.16),
                                themeColor.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: themeColor.withValues(alpha: 0.25),
                              width: 0.8.w,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.storefront_rounded,
                            color: themeColor,
                            size: 19.r,
                          ),
                        ),
                        AppSpacing.hSm,
                        // اسم نقطة البيع وبيانات السند المرجعية
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice.posName ?? 'نقطة بيع #${invoice.posId}',
                                style: AppTypography.titleSmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AppSpacing.vXxs,
                              Row(
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: Text(
                                      '#${invoice.invoiceUuid}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'monospace',
                                        fontSize: 9.5.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (dateStr.isNotEmpty) ...[
                                    Text(
                                      ' • ',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.onSurfaceVariant
                                            .withValues(alpha: 0.5),
                                        fontSize: 9.5.sp,
                                      ),
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: Text(
                                        dateStr,
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: colors.onSurfaceVariant
                                                  .withValues(alpha: 0.7),
                                              fontSize: 9.5.sp,
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
                        AppSpacing.hXs,
                        // كبسولة حالة السداد الزجاجية الموحدة
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isFullyPaid ? colors.primary : colors.warning)
                                    .withValues(alpha: 0.1),
                            borderRadius: AppRadius.fullRadius,
                            border: Border.all(
                              color:
                                  (isFullyPaid
                                          ? colors.primary
                                          : colors.warning)
                                      .withValues(alpha: 0.25),
                              width: 0.8.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5.5.r,
                                height: 5.5.r,
                                decoration: BoxDecoration(
                                  color: isFullyPaid
                                      ? colors.primary
                                      : colors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppSpacing.hXxs,
                              Text(
                                isFullyPaid
                                    ? 'مسددة'
                                    : (invoice.remainingAmount > 0
                                          ? 'متبقي: $formattedRemaining'
                                          : 'آجل'),
                                style: AppTypography.labelSmall.copyWith(
                                  color: isFullyPaid
                                      ? colors.primary
                                      : colors.warning,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 2. الفاصل البصري الشعري الناعم
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      height: 0.8.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.outlineVariant.withValues(alpha: 0.35),
                            colors.outlineVariant.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),

                    // 3. الرصيف المالي والمكاني: المبلغ الإجمالي والمعلومات الفرعية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // الرقم المالي المحوري وتفاصيل البيع
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      formattedTotal,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18.sp,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    AppSpacing.hXxs,
                                    Text(
                                      'ر.ي',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSpacing.vXxs,
                              Text(
                                '${invoice.totalCardsCount > 0 ? "${invoice.totalCardsCount} كرت • " : ""}${isCash ? "بيع نقدي" : "بيع آجل"}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // مؤشر الانتقال للتفاصيل
                        Container(
                          width: 28.r,
                          height: 28.r,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.4,
                            ),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11.r,
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // شريط الهوية السيادي الجانبي ممتد على كامل الحافة وبنفس انحناء زوايا الكرت
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4.w, color: themeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
