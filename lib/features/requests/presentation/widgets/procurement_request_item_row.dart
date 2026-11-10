import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// سطر عرض بند كروت في جدول تفاصيل الطلب (Request Item Row)
class ProcurementRequestItemRow extends StatelessWidget {
  final RequestItemEntity item;
  final int index;

  const ProcurementRequestItemRow({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageName =
        item.voucherPackage?.packageName ?? 'باقة كروت #${item.packageId}';
    final sheetSize = item.voucherPackage?.packageVoucherCount ?? 0;
    final quantityDesc = sheetSize > 0
        ? VoucherSheetCalculator.describe(item.voucherCount, sheetSize)
        : null;
    final packageColor =
        CustomColorPicker.parseHex(item.voucherPackage?.packageColor);

    return Container(
      decoration: BoxDecoration(
        color: index.isEven
            ? colors.surfaceContainerLowest
            : colors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: packageColor,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      // عداد الفهرس
                      CircleAvatar(
                        radius: 12.r,
                        backgroundColor: packageColor.withValues(alpha: 0.15),
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.labelSmall.copyWith(
                            color: packageColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AppSpacing.hSm,

                      // اسم الباقة وعدد الكروت
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              packageName,
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              quantityDesc != null
                                  ? '$quantityDesc  •  ${item.voucherCount} كرت'
                                  : 'الكمية: ${item.voucherCount} كرت',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // السعر الأساسي والخصم
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'سعر: ${AmountFormatter.format(item.voucherPrice.toString())}',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            if (item.itemDiscount > 0)
                              Text(
                                'خصم: ${AmountFormatter.format(item.itemDiscount.toString())}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.success,
                                ),
                              ),
                          ],
                        ),
                      ),

                      AppSpacing.hSm,

                      // الإجمالي الصافي
                      Expanded(
                        flex: 2,
                        child: Text(
                          AmountFormatter.format(item.itemTotalAmount.toString()),
                          textAlign: TextAlign.end,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
