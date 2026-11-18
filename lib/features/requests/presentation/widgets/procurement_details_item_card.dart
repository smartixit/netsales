import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة الباقة التوريدية المفصلة بالمعايير التنفيذية
///
/// مصممة بهندسة تخطيط آمنة 100% وبدون أي IntrinsicHeight أو حدود غير متماثلة
/// تضمن ثبات العرض وسرعة الأداء وعدم حدوث أي استثناء أثناء الرسم.
class ProcurementDetailsItemCard extends StatelessWidget {
  const ProcurementDetailsItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  final RequestItemEntity item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final package = item.voucherPackage;

    // استخراج لون الباقة بأمان مع لون احتياطي معتمد
    final accentColor =
        CustomColorPicker.parseHex(package?.packageColor);

    final packageName = package?.packageName ?? 'باقة كروت #${item.packageId}';

    // حساب عدد الشيتات المقابلة
    final sheetSize = package?.packageVoucherCount ?? 100;
    final sheetsCount = sheetSize > 0 ? (item.voucherCount / sheetSize) : 0.0;
    final sheetsFormatted = sheetsCount.truncateToDouble() == sheetsCount
        ? sheetsCount.toInt().toString()
        : sheetsCount.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // الصف الأول: شارة الأيقونة وهوية الباقة + اسم الباقة + الإجمالي الصافي للبند
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // حاوية أيقونة الباقة الملونة
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.28),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${index + 1}',
                  style: AppTypography.labelSmall.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  packageName,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpacing.hSm,
              // الإجمالي المالي للبند
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
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Text(
                    'الإجمالي الصافي',
                    style: AppTypography.caption.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // مواصفات الباقة إن وجدت
          if (package != null) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: [
                if (package.packageBalance > 0)
                  _buildSpecBadge(
                    context,
                    label: PackageSpecFormatter.formatBalance(
                      package.packageBalance,
                    ),
                    icon: Icons.data_usage_rounded,
                  ),
                if (package.packageValidity != null)
                  _buildSpecBadge(
                    context,
                    label: PackageSpecFormatter.formatValidity(
                      package.packageValidity,
                    ),
                    icon: Icons.event_available_rounded,
                  ),
                if (package.packageUptime != null)
                  _buildSpecBadge(
                    context,
                    label: PackageSpecFormatter.formatUptime(
                      package.packageUptime,
                    ),
                    icon: Icons.timer_outlined,
                  ),
              ],
            ),
          ],

          SizedBox(height: 10.h),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
          SizedBox(height: 10.h),

          // الصف السفلي: تفاصيل الكميات والأسعار
          Row(
            children: [
              // الكمية
              Expanded(
                child: _buildDetailColumn(
                  context,
                  label: 'الكمية المطلوبة',
                  value: '${item.voucherCount} كرت',
                  subValue: '($sheetsFormatted شيت)',
                ),
              ),

              // سعر الكرت
              Expanded(
                child: _buildDetailColumn(
                  context,
                  label: 'سعر الكرت',
                  value: AmountFormatter.formatValue(item.voucherPrice),
                ),
              ),

              // الخصم إن وجد
              if (item.itemDiscount > 0)
                Expanded(
                  child: _buildDetailColumn(
                    context,
                    label: 'الخصم',
                    value: AmountFormatter.formatValue(item.itemDiscount),
                    isDiscount: true,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBadge(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: colors.onSurfaceVariant),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(
    BuildContext context, {
    required String label,
    required String value,
    String? subValue,
    bool isDiscount = false,
  }) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 2.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDiscount
                      ? const Color(0xFF10B981)
                      : colors.onSurface,
                ),
              ),
              if (subValue != null) ...[
                SizedBox(width: 3.w),
                Text(
                  subValue,
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
