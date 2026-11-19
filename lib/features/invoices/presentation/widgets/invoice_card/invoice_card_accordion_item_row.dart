import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// سطر عرض بند الفاتورة المنفرد داخل درج الأكورديون التفاعلي
class InvoiceCardAccordionItemRow extends StatelessWidget {
  const InvoiceCardAccordionItemRow({super.key, required this.item});

  final InvoiceItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageColor = CustomColorPicker.parseHex(
      item.packageColor,
      fallback: colors.primary,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .25),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // شريط لون الباقة المعتمد
          Container(
            width: 3.5.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: packageColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(width: 8.w),

          // اسم الباقة وسعر الكرت المفرد
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: 2.h),
                Text(
                  'سعر الكرت: ${item.formattedVoucherPrice}',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),

          // كبسولة الكمية الموحدة (ورقة وكروت)
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.20),
                ),
              ),
              child: Text(
                item.fullQuantityLabel,
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.formattedItemTotalAmount,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.hasDiscount)
                  Text(
                    'خصم: ${item.formattedDiscount}',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.error,
                      fontSize: 9.5.sp,
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
