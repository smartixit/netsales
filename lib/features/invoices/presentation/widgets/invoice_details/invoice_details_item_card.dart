import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة الباقة المالية في قائمة بنود تفاصيل الفاتورة
class InvoiceDetailsItemCard extends StatelessWidget {
  const InvoiceDetailsItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  final InvoiceItemEntity item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageColor = CustomColorPicker.parseHex(
      item.packageColor,
      fallback: colors.primary,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .28),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // رأس البند مع شارة الترقيم
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: packageColor.withValues(alpha: .06),
              border: Border(
                bottom: BorderSide(
                  color: packageColor.withValues(alpha: .15),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: packageColor.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: packageColor.withValues(alpha: .35),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#${index + 1}',
                    style: AppTypography.labelMedium.copyWith(
                      color: packageColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.packageName ?? 'باقة #${item.packageId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        'سعر الكرت المعتمد: ${item.formattedVoucherPrice}',
                        style: AppTypography.caption.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hSm,
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      item.formattedItemTotalAmount,
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // تفاصيل الكميات والأوراق والخصومات
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'توزيع الكميات',
                          style: AppTypography.caption.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.vXxs,
                        Text(
                          item.fullQuantityLabel,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (item.hasDiscount) ...[
                  AppSpacing.hSm,
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: .06),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'الخصم الممنوح',
                            style: AppTypography.caption.copyWith(
                              color: colors.error,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            item.formattedDiscount,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
