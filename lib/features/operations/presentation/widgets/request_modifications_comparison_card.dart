import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// بطاقة مقارنة تعديلات طلب التوريد مع الفاتورة المعتمدة (RequestModificationsComparisonCard)
/// ============================================================================
/// تعرض للمستخدم (سواء في POS أو NETWORK) الفروقات بين الطلب الأصلي المحفوظ
/// بشكل دائم وغير القابل للتعديل، وبين الفاتورة المعتمدة النهائية المولدة.
class RequestModificationsComparisonCard extends StatelessWidget {
  final VoucherRequestEntity request;
  final OperationsController controller;

  const RequestModificationsComparisonCard({
    super.key,
    required this.request,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bool hasModifications = request.hasModifications;
    final double originalTotal = request.requestTotalAmount;
    final double? approvedTotal = request.approvedTotal;
    final int originalItemsCount = request.items.length;
    final int? approvedItemsCount = request.approvedItemsCount;

    final double diff = (approvedTotal != null) ? (approvedTotal - originalTotal) : 0.0;
    final bool hasPriceDiff = diff.abs() > 0.01;

    final Color statusColor = hasModifications ? colors.warning : colors.primary;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.2.w,
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── رأس البطاقة مع شارة الحالة ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        hasModifications
                            ? Icons.published_with_changes_rounded
                            : Icons.verified_rounded,
                        color: statusColor,
                        size: 16.r,
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Text(
                        'مطابقة الطلب مع الفاتورة المعتمدة',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hSm,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  hasModifications ? 'تم التعديل عند الاعتماد' : 'معتمد دون تعديل',
                  style: AppTypography.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.vSm,

          // ── توضيح سياق التعديل ──
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.06),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18.r,
                  color: statusColor,
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Text(
                    hasModifications
                        ? 'قام مزود الشبكة بمراجعة وتعديل هذا الطلب أثناء عملية الاعتماد، وتم إصدار فاتورة المبيعات بالبنود والقيم المعتمدة النهائية. يبقى الطلب الأصلي مسجلاً دون تغيير للشفافية والتدقيق.'
                        : 'تم اعتماد الطلب وتوليد فاتورة المبيعات بالبنود والكميات الأصلية دون أي تعديل.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurface,
                      height: 1.4,
                      fontSize: 11.5.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (hasModifications) ...[
            AppSpacing.vMd,

            // ── جدول مقارنة القيم بين الطلب الأصلي والفاتورة المعتمدة ──
            Row(
              children: [
                // عمود الطلب الأصلي
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: AppRadius.mdRadius,
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الطلب الأصلي المقدم',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                        AppSpacing.vXs,
                        Text(
                          '${AmountFormatter.formatValue(originalTotal)} ر.ي',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        AppSpacing.vXs,
                        Text(
                          '$originalItemsCount باقات مطلوبة',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                AppSpacing.hSm,

                // عمود الفاتورة المعتمدة النهائية
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.05),
                      borderRadius: AppRadius.mdRadius,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الفاتورة المعتمدة النهائية',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                        AppSpacing.vXs,
                        Text(
                          '${AmountFormatter.formatValue(approvedTotal ?? originalTotal)} ر.ي',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                        AppSpacing.vXs,
                        Text(
                          approvedItemsCount != null
                              ? '$approvedItemsCount باقات معتمدة'
                              : 'معتمد',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (hasPriceDiff) ...[
              AppSpacing.vSm,
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  diff > 0
                      ? 'فارق القيمة: زيادة قدرها +${AmountFormatter.formatValue(diff)} ر.ي'
                      : 'فارق القيمة: تخفيض قدره ${AmountFormatter.formatValue(diff)} ر.ي',
                  style: AppTypography.labelSmall.copyWith(
                    color: diff > 0 ? colors.warning : colors.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],

          if (request.invoiceId != null) ...[
            AppSpacing.vMd,
            CustomButton.outline(
              text: 'عرض بنود وتفاصيل الفاتورة المولدة',
              icon: Icons.receipt_long_rounded,
              onPressed: () => controller.openInvoiceDetails(request.invoiceId!),
            ),
          ],
        ],
      ),
    );
  }
}