import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_diff_audit_section.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_voucher_financial_row.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// بطاقة القسيمة المالية الرسمية المنظمة فائقة العمق البصري
class NetworkRequestQuotationVoucherCard extends StatelessWidget {
  const NetworkRequestQuotationVoucherCard({
    super.key,
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
                // 1. لوحة الصافي السيادي المعتمد
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFF087A5F),
                        Color(0xFF055743),
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

                // 2. جدول الحسابات المحاسبي
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
                      NetworkRequestVoucherFinancialRow(
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
                      NetworkRequestVoucherFinancialRow(
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
                      NetworkRequestVoucherFinancialRow(
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

                // 4. سجل الفروقات والتعديلات
                NetworkRequestDiffAuditSection(
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
