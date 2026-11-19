import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// بطاقة التنبيه والربط بطلب التوريد المعتمد الصادرة عنه الفاتورة
class InvoiceRequestCallout extends StatelessWidget {
  const InvoiceRequestCallout({
    super.key,
    required this.invoice,
    required this.onOpenRequest,
  });

  final InvoiceEntity invoice;
  final VoidCallback onOpenRequest;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.primary.withValues(alpha: .22),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: colors.primary,
              size: 20.r,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'طلب التوريد المرتبط',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.5.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'طلب ${invoice.displayRequestReference}',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          CustomButton.outline(
            text: 'عرض الطلب',
            size: AppButtonSize.small,
            icon: Icons.open_in_new_rounded,
            onPressed: onOpenRequest,
          ),
        ],
      ),
    );
  }
}
